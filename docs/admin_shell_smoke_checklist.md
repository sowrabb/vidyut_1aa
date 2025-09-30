# Admin Shell Smoke Checklist

Follow this quick sequence whenever validating the offline admin demo build:

1. Launch the app and sign in as the seeded demo admin (auto-login in offline mode).
2. Confirm the header shows **Admin Console** and the navigation rail lists the
   five main categories (Dashboard → Media & Storage).
3. Tap **User Controls ▸ Users** – verify the user table hydrates with seeded data.
4. Tap **User Controls ▸ Billing** – confirm the Billing Management page renders the
   overview stats cards.
5. On the Billing page, toggle between the **Payments** and **Invoices** tabs and
   confirm filters render without errors.
6. Return to Dashboard and ensure hero cards display without missing assets.
7. Log out via the profile menu (if available) and ensure the auth guard redirects to
   the unauthorised screen.

Record any deviations in the release notes so later phases know where to focus.
