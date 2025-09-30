# Demo Services Overview

The admin console runs fully offline by leaning on `LightweightDemoDataService`. It seeds
predictable datasets so features behave consistently without Firebase or a backend.

## Seeded Collections

| Dataset | Description | Primary Consumers |
| --- | --- | --- |
| `allProducts` | Catalog items across categories with materials/specs | Admin product management, seller onboarding |
| `heroSections` | Landing hero cards with priority + scheduling data | CMS/hero section editor |
| `allLeads` | Procurement leads with industry/material metadata | Leads management, analytics |
| `allConversations` | Messaging threads for moderation demos | Messaging admin tools |
| `allCategories` | Taxonomy nodes with industries/materials | Category manager, filters |
| `allUsers` | Admin user roster with roles/plans/status | Users Management, RBAC, authentication |
| `allPayments` | Billing transactions (status, method, totals) | Billing dashboard, refunds |
| `allInvoices` | Invoice records with GST breakdown & overdue flags | Billing + dunning flows |
| `billingSnapshot` | Aggregated revenue/collection stats | Billing overview cards |
| `notificationTemplates` | Multi-channel notification templates | Notifications composer |
| `allPowerGenerators` | State-info generator profiles | Power/state info flows |

Each dataset is deterministic so snapshot tests and QA scripts remain stable. When a
feature mutates the demo store, call `notifyListeners()` on the service to propagate
changes to listening widgets.

## Persistence

Long-lived admin preferences (flags, RBAC mappings, hero timers, plan cards, etc.) go
through `AdminPersistence`, a thin wrapper over `SharedPreferences`. This keeps the
stores decoupled from the exact storage mechanism and makes it easy to swap in-memory
persistence during tests.

## Adding New Demo Data

1. Extend `LightweightDemoDataService` with the collection + getters you need.
2. Seed deterministic fixtures inside `_initializeDemoDataAsync` (or the synchronous
   `_initializeDemoData` fallback).
3. Surface the dataset through whichever store consumes it (e.g. `EnhancedAdminStore`).
4. Update this document with the new contract so future phases know what already exists.
