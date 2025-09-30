## All Pages by Role

Note: Platform is information-only (no orders/cart/checkout). Reviews are allowed for any signed-up user.

### Buyer (information seeker)
- Authentication
  - features/auth/firebase_auth_page.dart
  - features/auth/phone_login_page.dart
  - features/auth/otp_login_page.dart
  - features/auth/simple_phone_auth_page.dart
  - features/auth/phone_signup_page.dart
  - features/auth/auth_page.dart
- Landing and discovery
  - features/home/home_page.dart
  - features/search/search_page.dart
  - features/search/enhanced_search_page.dart
  - features/search/comprehensive_search_page.dart
  - features/search/search_history_page.dart
  - features/search/search_analytics_page.dart
  - features/categories/categories_page.dart
  - features/categories/category_detail_page.dart
  - features/location/comprehensive_location_page.dart
  - features/stateinfo/state_info_page.dart
  - features/stateinfo/enhanced_state_info_page.dart
  - features/stateinfo/clean_state_info_page.dart
  - features/stateinfo/pages/comprehensive_state_info_page.dart
  - features/about/about_page.dart
- Product exploration
  - features/sell/product_detail_page.dart
  - features/sell/products_list_page.dart
- Reviews (any signed-up user)
  - features/reviews/reviews_page.dart
  - features/reviews/review_composer.dart
- Contact and follow-ups (information exchange)
  - features/messaging/messaging_pages.dart
  - features/leads/lead_detail_page.dart
- Profile
  - features/profile/profile_page.dart
  - features/profile/user_profile_page.dart

### Seller (publisher of information/listings)
- Authentication and profile
  - features/auth/firebase_auth_page.dart
  - features/auth/phone_login_page.dart
  - features/auth/otp_login_page.dart
  - features/sell/signup_page.dart
  - features/profile/profile_page.dart
  - features/profile/user_profile_page.dart
- Seller workspace hub
  - features/sell/sell_hub_page.dart
  - features/sell/hub_shell.dart
  - features/sell/dashboard_page.dart
  - features/sell/analytics_page.dart
- Catalog/listings management
  - features/sell/products_list_page.dart
  - features/sell/product_form_page.dart
  - features/sell/product_detail_page.dart
  - features/sell/profile_settings_page.dart
  - features/sell/subscription_page.dart
- Leads and conversations
  - features/sell/leads_page.dart
  - features/leads/lead_detail_page.dart
  - features/messaging/messaging_pages.dart
- Promotion
  - features/sell/ads_page.dart
  - features/sell/ads_create_page.dart
- Discovery context
  - features/search/search_page.dart
  - features/search/enhanced_search_page.dart
  - features/search/comprehensive_search_page.dart
  - features/categories/categories_page.dart
  - features/categories/category_detail_page.dart
  - features/stateinfo/state_info_page.dart

### Admin (moderation, RBAC, content/system oversight)
- Admin auth and shell
  - features/admin/auth/admin_login_page.dart
  - features/admin/admin_shell.dart
- RBAC and permissions
  - features/admin/rbac/rbac_page.dart
  - features/admin/pages/enhanced_rbac_management_page.dart
- Users and sellers
  - features/admin/pages/enhanced_users_management_page.dart
  - features/admin/pages/seller_management_page.dart
- Products/content moderation and design
  - features/admin/pages/enhanced_products_management_page.dart
  - features/admin/pages/product_designs_page.dart
  - features/admin/pages/hero_sections_page.dart
  - features/admin/pages/enhanced_hero_sections_page.dart
  - features/admin/pages/hero_section_editor.dart
  - features/admin/pages/media_storage_page.dart
  - features/admin/pages/categories_management_page.dart
- Compliance and KYC
  - features/admin/pages/kyc_management_page.dart
- Announcements and notifications
  - features/admin/pages/notifications_page.dart
- Operational controls
  - features/admin/pages/feature_flags_page.dart
  - features/admin/pages/system_operations_page.dart
- Subscriptions and billing
  - features/admin/pages/subscription_management_page.dart
  - features/admin/pages/subscriptions_tab.dart
  - features/admin/pages/billing_management_page.dart
- Analytics/insight
  - features/admin/pages/analytics_dashboard_page.dart

### Shared app shell/navigation
- app/layout/responsive_scaffold.dart
- app/routes.dart
- app/auth_wrapper.dart

