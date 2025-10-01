/// KYC submission providers for admin dashboard
///
/// Provides real-time streams of KYC submissions filtered by status,
/// backed by Firestore repository for testability.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/admin/models/kyc_models.dart';
import '../core/firebase_providers.dart';

part 'kyc_providers.g.dart';

/// Stream of pending KYC submissions awaiting review
@riverpod
Stream<List<KycSubmission>> kycPendingSubmissions(KycPendingSubmissionsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('kyc_submissions')
      .where('status', isEqualTo: 'pending')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => KycSubmission.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
}

/// Stream of all KYC submissions with optional status filter
@riverpod
Stream<List<KycSubmission>> kycSubmissionsByStatus(
  KycSubmissionsByStatusRef ref,
  String? status,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  Query query = firestore
      .collection('kyc_submissions')
      .orderBy('created_at', descending: true);
  
  if (status != null && status.isNotEmpty && status != 'all') {
    query = query.where('status', isEqualTo: status);
  }
  
  return query.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => KycSubmission.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
      .toList());
}

/// Get a single KYC submission by ID
@riverpod
Future<KycSubmission?> kycSubmissionDetail(
  KycSubmissionDetailRef ref,
  String submissionId,
) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final doc = await firestore.collection('kyc_submissions').doc(submissionId).get();
  if (!doc.exists) return null;
  return KycSubmission.fromJson({...doc.data()!, 'id': doc.id});
}

/// Count of pending KYC submissions for dashboard badge
@riverpod
Stream<int> kycPendingCount(KycPendingCountRef ref) {
  return ref.watch(kycPendingSubmissionsProvider).when(
    data: (submissions) => Stream.value(submissions.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
}