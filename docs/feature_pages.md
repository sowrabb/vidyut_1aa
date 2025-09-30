## Feature Breakdown by Page (Information Platform)

Notes:
- Platform is information-only (no cart/orders/checkout). Reviews are open to any signed-up user.
- Pages are grouped by role flows (Buyer, Seller, Admin) and Shared app shell.

### Buyer

- features/auth/firebase_auth_page.dart
  - Email/password login form (validators, error banners, loading state)
  - Sign-up toggle with name and optional phone fields
  - Google sign-in action (if available)
  - Email verification prompt handling
  - Role selection default state (buyer) to personalize post-login
  - Success/failure snackbars

- features/auth/phone_login_page.dart
  - Phone input with country code format validation
  - Password input with visibility toggle
  - Continue as guest action
  - Link to phone-based sign-up
  - Non-blocking login flow with progress indicator

- features/auth/otp_login_page.dart
  - Phone input, OTP code input fields
  - Send/resend OTP with countdown timer
  - Verify OTP and error handling
  - Fallback to password login link

- features/auth/simple_phone_auth_page.dart
  - Minimal phone + OTP login flow
  - Compact UI for quick auth in embedded contexts

- features/auth/phone_signup_page.dart
  - Phone, name, password fields with validation
  - Terms/privacy acceptance checkbox
  - Success confirmation and redirect to auth wrapper

- features/home/home_page.dart
  - Hero slideshow/banner with callouts
  - Location picker (modal/sheet) and saved location display
  - Categories grid (top categories)
  - Featured product cards (image, title, key specs, share)
  - Trusted brands/logo strip
  - Responsive product cards (mobile/desktop variants)
  - Links to Search, Categories, State Info

- features/search/search_page.dart
  - Search bar with suggestions/autocomplete
  - Filters panel: category, brand, material, price range (as info), attributes
  - Sort controls: relevance, newest, alphabetical
  - Results list/grid with product cards
  - Empty state with helpful prompts
  - Persisted recent searches link

- features/search/enhanced_search_page.dart
  - Advanced filters (multi-select facets, toggles)
  - Saved filter presets
  - Inline facet counts and active filter chips
  - Sticky header for query and actions

- features/search/comprehensive_search_page.dart
  - Combined free-text + structured form inputs
  - Federated results sections (products, state info posts)
  - Cross-section quick filters

- features/search/search_history_page.dart
  - List of recent queries with timestamps
  - One-tap re-run, clear history

- features/search/search_analytics_page.dart
  - Personal insight widgets: most used filters, top categories viewed
  - Trends over time (sparkline, simple charts)
  - Export/share summary (image or text)

- features/categories/categories_page.dart
  - Category tree/grid with icons
  - Quick search within categories
  - Jump links to popular subcategories

- features/categories/category_detail_page.dart
  - Subcategory list and breadcrumb
  - Featured products in the category
  - Category description and guidelines

- features/location/comprehensive_location_page.dart
  - Map or region selector (list-based on web)
  - Saved locations manager
  - Radius/area preference controls
  - Location-based recommendations preview

- features/stateinfo/state_info_page.dart
  - State/region picker
  - List of information posts (compliance, wiring, safety)
  - Filters: topic, date, relevance
  - Post detail preview drawer

- features/stateinfo/enhanced_state_info_page.dart
  - Advanced filters and multi-select topics
  - Statistics/summary cards for selected region
  - Quick compare between states (two-column view)

- features/stateinfo/clean_state_info_page.dart
  - Minimal list of curated state info posts
  - Simple search and tag filters

- features/stateinfo/pages/comprehensive_state_info_page.dart
  - Full-page view with hierarchical navigation
  - Content sections with anchors and table of contents

- features/about/about_page.dart
  - Static content: mission, contact, policies
  - Links to terms/privacy

- features/sell/products_list_page.dart
  - Read-only product catalog view (as buyer): image, title, key specs
  - Filters and sort consistent with Search
  - Pagination or infinite scroll

- features/sell/product_detail_page.dart
  - Image carousel with zoom/lightbox
  - Product title, subtitle/short description
  - Attributes/specifications table (materials, dimensions, ratings where applicable)
  - Availability/lead time info (informational)
  - Seller/brand info card with contact action
  - Actions: share, copy link, save to favorites (if implemented)
  - CTA: Message seller / Submit inquiry (opens Messaging or Lead creation)
  - Reviews section (read) and button to open Review composer
  - Related products carousel/grid

- features/reviews/reviews_page.dart
  - Aggregate rating (if present) and count
  - Review list with filters (recent, most helpful)
  - Photo-only reviews tab (if images present)
  - Write a review button (opens composer)

- features/reviews/review_composer.dart
  - Rating selector (stars or slider)
  - Text input with character counter
  - Optional image upload
  - Post review action with validation and feedback

- features/messaging/messaging_pages.dart
  - Conversation list with unread badges, timestamps
  - Thread view with message bubbles, time, read status
  - Composer: text input, attachments (image/file), send button
  - Quick replies/templates (if enabled)
  - Report conversation option

- features/leads/lead_detail_page.dart
  - Lead metadata: product, created time, source
  - Status chips (new, contacted, in discussion, closed)
  - Notes/timeline of interactions
  - Link to open conversation in Messaging
  - Attachments preview (quotes, images)

- features/profile/profile_page.dart
  - Profile overview: avatar, name, email/phone
  - Preferences: notifications, theme, language
  - Saved locations and interests
  - Privacy and security links

- features/profile/user_profile_page.dart
  - Detailed profile editor
  - Contact details, company info (if seller later)
  - Change password or linked accounts

### Seller

- features/sell/sell_hub_page.dart
  - Entry tiles: Products, Leads, Messages, Analytics, Ads, Settings
  - KPIs summary (views, inquiries) with quick links

- features/sell/hub_shell.dart
  - Shell navigation for seller subsections
  - Keeps context/state across tabs

- features/sell/dashboard_page.dart
  - Metrics cards: listing views, inquiries, top products
  - Trends chart (views over time)
  - Tasks checklist (complete profile, add media)

- features/sell/analytics_page.dart
  - Product performance table (views, clicks, inquiries)
  - Filters: time range, category, material
  - Export/share analytics snapshot

- features/sell/products_list_page.dart
  - Seller list of own listings with status (published/draft)
  - Bulk select and quick actions (publish/unpublish)
  - Filters by category, tag, status

- features/sell/product_form_page.dart
  - Form sections: Basics (title, description), Media (images), Specs (attributes), Compliance notes
  - Materials selector and custom fields
  - Validation and draft/publish actions
  - Preview mode

- features/sell/product_detail_page.dart
  - Seller-focused detail: quick edit affordances
  - Visibility status, publish toggle
  - Inline analytics (views, inquiries)
  - Lead shortcuts and share link

- features/sell/profile_settings_page.dart
  - Business profile: logo, address, GST/registration (as applicable)
  - Contact preferences and response SLAs
  - Team members (if supported) and roles

- features/sell/subscription_page.dart
  - Current plan info (informational)
  - Feature comparison and upgrade CTA
  - Billing contact details

- features/sell/leads_page.dart
  - Leads table/list with search and filters
  - Sorting by recency/priority
  - Bulk assign labels or status

- features/leads/lead_detail_page.dart
  - Lead status management (seller side)
  - Notes, next steps, reminders
  - Message thread link and attachments

- features/messaging/messaging_pages.dart
  - Same as Buyer; includes quick templates for seller

- features/sell/ads_page.dart
  - Existing promotions overview
  - Status, impressions, clicks (informational)
  - Create new ad CTA

- features/sell/ads_create_page.dart
  - Campaign setup: objective, audience, placements
  - Creative upload/selection
  - Budget/schedule (informational; save config)
  - Preview and publish (informational action)

- features/sell/signup_page.dart
  - Seller onboarding steps checklist
  - Business info form
  - Terms acknowledgement and submit

### Admin

- features/admin/auth/admin_login_page.dart
  - Admin credentials form
  - Error feedback and lockout hints (if any)

- features/admin/admin_shell.dart
  - Sidebar/rail navigation for all admin sections
  - Header with environment indicators and feature flag badge
  - Content area with breadcrumbs and search

- features/admin/rbac/rbac_page.dart
  - Roles list and details
  - Assign/revoke permissions
  - Audit logs for RBAC changes

- features/admin/pages/enhanced_rbac_management_page.dart
  - Role templates gallery
  - Permission grid with wildcard support
  - Diff/preview before apply

- features/admin/pages/enhanced_users_management_page.dart
  - Users table with filters (role, status, activity)
  - Activate/suspend, change role
  - User detail drawer with history and notes

- features/admin/pages/seller_management_page.dart
  - Sellers overview (verification, activity)
  - KYC status shortcuts
  - Contact seller action

- features/admin/pages/enhanced_products_management_page.dart
  - Product moderation queue and history
  - Approve/reject with reasons
  - Bulk actions and pagination

- features/admin/pages/product_designs_page.dart
  - Manage attribute schemas/templates
  - Preview product cards/layouts

- features/admin/pages/hero_sections_page.dart
  - List and order of hero sections
  - Toggle visibility per platform

- features/admin/pages/enhanced_hero_sections_page.dart
  - Advanced controls for hero content variants
  - A/B flags and scheduling (informational)

- features/admin/pages/hero_section_editor.dart
  - Rich text/media editor
  - Live preview and versioning

- features/admin/pages/media_storage_page.dart
  - Media library with search and filters
  - Upload, replace, delete assets
  - Usage references (where used)

- features/admin/pages/categories_management_page.dart
  - Category tree editor
  - Add/rename/move categories
  - Validation for duplicates and SEO slugs

- features/admin/pages/kyc_management_page.dart
  - KYC submissions list and filters
  - Review viewer (images/docs)
  - Approve/reject with notes

- features/admin/pages/notifications_page.dart
  - Compose broadcast notification
  - Audience filters
  - Delivery report (informational)

- features/admin/pages/feature_flags_page.dart
  - Flags list with search
  - Toggle switches and description tooltips
  - Audit notes

- features/admin/pages/system_operations_page.dart
  - Maintenance tasks (reindex, clear caches)
  - Job status and logs

- features/admin/pages/subscription_management_page.dart
  - Plans overview and user assignments (informational)
  - Change plan actions (admin-driven configuration)

- features/admin/pages/subscriptions_tab.dart
  - Tabbed view for plan details, features, limits

- features/admin/pages/billing_management_page.dart
  - Billing contacts and invoices (informational)
  - Export statements

- features/admin/pages/analytics_dashboard_page.dart
  - Global metrics: users, listings, inquiries
  - Segment/filters (time range, role, category)
  - Charts and top entities tables

### Shared App Shell

- app/auth_wrapper.dart
  - Loading state while checking auth
  - Route to main app vs auth page

- app/layout/responsive_scaffold.dart
  - Nav destinations: Home, Search, Messages (desktop), Categories (desktop), Sell, State Info, Profile
  - Index mapping for mobile vs desktop
  - Preserves current index when switching breakpoints

- app/routes.dart
  - Route name map to scaffold/pages
  - Deep-link indices for tabs


