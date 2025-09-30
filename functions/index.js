/**
 * Notifications Functions: estimate audience, create job, run job fan-out
 */
const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

try {
  admin.initializeApp();
} catch (e) {
  // no-op if already initialized
}

const db = admin.firestore();

function requireAdminAuth(req) {
  const auth = req.headers.authorization || "";
  if (!auth.startsWith("Bearer ")) return null;
  const token = auth.substring(7);
  return admin
    .auth()
    .verifyIdToken(token)
    .then((decoded) => {
      const roles = decoded.roles || [];
      if (!roles.includes("admin")) {
        throw new Error("forbidden");
      }
      return decoded;
    });
}

function parseJson(req) {
  try {
    return typeof req.body === "object" ? req.body : JSON.parse(req.body || "{}");
  } catch (e) {
    return {};
  }
}

async function queryAudience(audience) {
  const userIds = new Set();
  const explicitIds = Array.isArray(audience.userIds) ? audience.userIds : [];
  explicitIds.forEach((id) => userIds.add(id));

  const roles = Array.isArray(audience.roles) ? audience.roles : [];
  const states = Array.isArray(audience.states) ? audience.states : [];
  const isSeller = typeof audience.isSeller === "boolean" ? audience.isSeller : null;

  // Build queries based on available filters
  const queries = [];
  if (roles.length > 0) {
    // roles is an array on user doc
    queries.push(db.collection("users").where("roles", "array-contains-any", roles));
  }
  if (states.length > 0) {
    queries.push(db.collection("users").where("state", "in", states.slice(0, 10)));
  }
  if (isSeller !== null) {
    queries.push(db.collection("users").where("isSeller", "==", isSeller));
  }

  if (queries.length === 0 && explicitIds.length === 0) {
    // No filters provided: target all users (estimate via count aggregation)
    const snap = await db.collection("users").count().get();
    return { ids: [], estimated: snap.data().count || 0, isEstimatedOnly: true };
  }

  // Run queries and union user IDs
  for (const q of queries) {
    let next = q.limit(1000);
    // Paginate up to 100k for safety
    for (let i = 0; i < 100; i++) {
      const snap = await next.get();
      snap.docs.forEach((d) => userIds.add(d.id));
      if (snap.size < 1000) break;
      next = q.startAfter(snap.docs[snap.docs.length - 1]).limit(1000);
    }
  }

  return { ids: Array.from(userIds), estimated: userIds.size, isEstimatedOnly: false };
}

exports.notificationsEstimate = onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") return res.status(405).send({ error: "method_not_allowed" });
    await requireAdminAuth(req);
    const body = parseJson(req);
    const audience = body.audience || {};
    const result = await queryAudience(audience);
    logger.info("notificationsEstimate", {
      audience,
      estimated: result.estimated,
    });
    return res.status(200).send({ count: result.estimated });
  } catch (e) {
    const code = e && e.message === "forbidden" ? 403 : 500;
    logger.error("notificationsEstimate failed", e);
    return res.status(code).send({ error: e.message || "internal" });
  }
});

exports.notificationsSend = onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") return res.status(405).send({ error: "method_not_allowed" });
    const decoded = await requireAdminAuth(req);
    const body = parseJson(req);
    const draft = body.draft || body; // accept raw draft for compatibility

    const channels = Array.isArray(draft.channels) ? draft.channels : [];
    const hasOnlyInAppOrPush = channels.every((c) => c === "inApp" || c === "push");
    if (!hasOnlyInAppOrPush || channels.length === 0 || !channels.includes("inApp")) {
      return res.status(400).send({ error: "invalid_channels" });
    }

    const audience = draft.audience || {};
    const estimate = await queryAudience(audience);

    const jobRef = db.collection("notification_jobs").doc();
    const now = admin.firestore.FieldValue.serverTimestamp();
    await jobRef.set({
      draft,
      audienceFilter: audience,
      createdBy: decoded.uid,
      scheduledAt: draft.scheduledAt || null,
      status: "queued",
      counts: { estimated: estimate.estimated, targeted: 0, succeeded: 0, failed: 0 },
      errors: [],
      createdAt: now,
      startedAt: null,
      finishedAt: null,
    });
    logger.info("notificationsSend: job queued", { jobId: jobRef.id, estimated: estimate.estimated });

    return res.status(200).send({ jobId: jobRef.id });
  } catch (e) {
    const code = e && e.message === "forbidden" ? 403 : 500;
    logger.error("notificationsSend failed", e);
    return res.status(code).send({ error: e.message || "internal" });
  }
});

exports.notificationJobRunner = onDocumentCreated(
  { document: "notification_jobs/{jobId}" },
  async (event) => {
    const { document } = event.data;
    if (!document) return;
    const jobRef = db.doc(document.ref.path);
    const job = document.data();
    if (job.status !== "queued") return;

    const now = admin.firestore.FieldValue.serverTimestamp();
    await jobRef.update({ status: "running", startedAt: now });
    logger.info("notificationJobRunner: started", { jobId: event.params.jobId });

    try {
      const audience = job.audienceFilter || {};
      const { ids, isEstimatedOnly } = await queryAudience(audience);
      let targeted = isEstimatedOnly ? 0 : ids.length;
      let succeeded = 0;
      let failed = 0;

      // Fan-out in batches
      const batchSize = 500;
      for (let i = 0; i < ids.length; i += batchSize) {
        const slice = ids.slice(i, i + batchSize);
        const batch = db.batch();
        for (const uid of slice) {
          const notifId = `${event.params.jobId}-${uid}`;
          const inboxRef = db.collection("users").doc(uid).collection("inbox").doc(notifId);
          const payload = {
            title: job.draft?.templates?.inApp?.title || job.draft?.templates?.inapp?.title || job.draft?.templates?.inAPP?.title || job.draft?.templates?.in_app?.title || job.draft?.templates?.inApp?.title || job.draft?.templates?.inapp?.title,
            body: job.draft?.templates?.inApp?.body || job.draft?.templates?.inapp?.body,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            readAt: null,
            meta: job.draft?.meta || {},
            jobId: event.params.jobId,
          };
          batch.set(inboxRef, payload, { merge: true });
        }
        await batch.commit();
        logger.info("notificationJobRunner: batch committed", {
          jobId: event.params.jobId,
          batchIndex: Math.floor(i / batchSize),
          processed: slice.length,
        });
        succeeded += slice.length;
        await jobRef.update({
          counts: admin.firestore.FieldValue.increment(0), // placeholder to ensure update
        });
      }

      await jobRef.update({
        status: "succeeded",
        counts: { estimated: job.counts?.estimated || targeted, targeted, succeeded, failed },
        finishedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      logger.info("notificationJobRunner: succeeded", { jobId: event.params.jobId, targeted, succeeded, failed });
    } catch (e) {
      logger.error("notificationJobRunner error", e);
      await jobRef.update({
        status: "failed",
        errors: admin.firestore.FieldValue.arrayUnion(String(e?.message || e)),
        finishedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);
