# Admin Console Offline Architecture

This document records the baseline for running the Vidyut admin console without Firebase
or any backend service. Phase 0 focuses on getting the shell, stores, and demo data
into a fully deterministic state so every subsequent feature can build on the same
assumptions.

## High-level Flow

```text
LightweightDemoDataService ─┐
                            ├─> EnhancedAdminStore ──> Admin pages/widgets
AdminPersistence (SharedPrefs)
                            └─> AdminStore (RBAC, Geo, Flags, Templates)
```

* `LightweightDemoDataService` seeds products, sellers, billing transactions,
  notifications, and state-info data at start-up. The service is a `ChangeNotifier`
  so UI surfaces can observe updates during mutations.
* `AdminPersistence` wraps `SharedPreferences` and is injected into `AdminStore`. Stores
  no longer talk to `SharedPreferences` directly which makes it trivial to plug in an
  in-memory adapter for widget tests.
* `EnhancedAdminStore` falls back to the demo data service whenever the backend flag is
  disabled. Filtering, pagination, and exports now operate on seeded lists so the billing
  dashboard and other controls fully work offline.

## Phase 0 Deliverables

* Centralised async feedback via `AdminActionResult` + `AdminAsyncFeedback` so pages share
  consistent messaging.
* Demo data covers billing (payments, invoices, stats) and notifications, enabling later
  phases to focus on behaviour rather than scaffolding.
* Architecture & service documentation (`docs/admin_offline_overview.md`,
  `lib/services/README.md`).
* Smoke/visual validations:
  * `test/admin/admin_shell_navigation_test.dart` ensures routing/auth wiring holds.
  * `test/admin/golden/admin_shell_default_golden_test.dart` captures the baseline shell
    layout for regression tracking.

## Next Steps

With Phase 0 complete, subsequent phases can focus on specific feature areas (users,
products, billing, etc.) knowing:

1. Navigation + auth guard work on top of deterministic data.
2. Each store can be exercised in unit/widget tests without ad-hoc stubbing.
3. Visual regressions are caught via the golden harness introduced in this phase.

Keep this document updated as we introduce more offline capabilities or change the data
contracts exposed by the demo service.
