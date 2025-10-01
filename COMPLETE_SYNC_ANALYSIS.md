# 🔄 Complete Cross-Flow Sync Analysis
## Vidyut App - All Features That Need Real-Time Synchronization

**Date:** October 1, 2025  
**Purpose:** Identify ALL features that need sync between Admin, Seller, and User flows

---

## 📊 Executive Summary

**Total Sync Features Identified:** 25+ critical features  
**Currently Synced via Firebase:** 8 features ✅  
**Currently In-Memory (Needs Firebase):** 17 features ⚠️  
**Priority for Migration:** 12 HIGH, 5 MEDIUM, 8 LOW

---

## 1️⃣ CATEGORIES 🎯
**Status:** ✅ **SYNCED** (as of Oct 1, 2025)

### Flows:
- **Admin:** Creates, updates, deletes categories
- **Seller:** Selects categories for products
- **User:** Browses products by category

### Current Implementation:
- `LightweightDemoDataService` (in-memory)
- `CategoriesStore` with `ref.listen()` for auto-refresh
- **Sync Works:** Admin changes → App updates immediately ✅

### Data Model:
```dart
class CategoryData {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int? priority;
  final List<String> industries;
  final List<String> materials;
  final bool isActive;
}
```

### Firebase Collection (Recommended):
```
/categories/{categoryId}
  - name: string
  - description: string
  - image_url: string
  - priority: number
  - industries: string[]
  - materials: string[]
  - is_active: boolean
  - parent_id: string (for hierarchy)
  - created_at: timestamp
  - updated_at: timestamp
```

---

## 2️⃣ PRODUCTS 📦
**Status:** ✅ **PARTIALLY SYNCED** (Firebase provider exists)

### Flows:
- **Admin:** Approves, rejects, archives products
- **Seller:** Creates, updates, deletes own products
- **User:** Views, searches, filters products

### Current Implementation:
- `firebaseProductsProvider` - Real-time Firestore stream ✅
- `ProductsManagementPageV2` - Admin uses Firebase ✅
- `SellerStore` - Uses `LightweightDemoDataService` ⚠️

### **ISSUE:** Seller actions not synced to Firebase!

### Data Model:
```dart
class Product {
  final String id;
  final String title;
  final String brand;
  final String category;
  final List<String> images;
  final double price;
  final int moq;
  final double gstRate;
  final ProductStatus status; // draft, pending, active, inactive, archived
  final String sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int viewCount;
  final int orderCount;
}
```

### Firebase Collection:
```
/products/{productId}
  - title, brand, category, description
  - images: string[]
  - price: number
  - moq: number
  - gst_rate: number
  - status: enum [draft, pending, active, inactive, archived]
  - seller_id: string (ref: /users/{uid})
  - created_at: timestamp
  - updated_at: timestamp
  - metrics: { view_count, order_count, rating }
```

### **ACTION NEEDED:**
✅ Migrate `SellerStore.addProduct()` to write to Firestore  
✅ Migrate `SellerStore.updateProduct()` to write to Firestore  
✅ Migrate `SellerStore.deleteProduct()` to write to Firestore  
✅ Replace `products` getter to read from `firebaseProductsProvider`

---

## 3️⃣ USERS & PROFILES 👥
**Status:** ✅ **SYNCED** (Firebase provider exists)

### Flows:
- **Admin:** Views all users, updates roles/status, suspends accounts
- **Seller:** Updates own seller profile
- **User:** Updates own user profile

### Current Implementation:
- `firebaseAllUsersProvider` - Real-time Firestore stream ✅
- `UsersManagementPageV2` - Admin uses Firebase ✅
- `UserStore` - Uses demo data ⚠️
- `userProfileServiceProvider` - Firebase-backed ✅

### Data Model:
```dart
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role; // buyer, seller, admin, guest
  final UserStatus status; // active, pending, suspended, inactive
  final SubscriptionPlan subscriptionPlan; // free, plus, pro, enterprise
  final bool isSeller;
  final String? sellerProfileId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final List<String> materials;
}
```

### Firebase Collection:
```
/users/{userId}
  - name, email, phone, profile_image_url
  - role: enum [buyer, seller, admin, guest]
  - status: enum [active, pending, suspended, inactive]
  - subscription_plan: enum [free, plus, pro, enterprise]
  - is_seller: boolean
  - seller_profile_id: string
  - created_at, updated_at, last_active: timestamp
  - location: { city, state, coordinates }
  - materials: string[]
```

### **ACTION NEEDED:**
✅ Migrate `UserStore` to use `firebaseAllUsersProvider`

---

## 4️⃣ SELLER PROFILES 🏢
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **Admin:** Views seller profiles, verifies sellers
- **Seller:** Creates/updates company info, logo, GST, contact details
- **User:** Views seller profiles when browsing products

### Current Implementation:
- `SellerStore` - In-memory only ⚠️
- No Firebase provider exists ❌

### Data Model:
```dart
class SellerProfile {
  final String id;
  final String companyName;
  final String gstNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String email;
  final String website;
  final String description;
  final List<String> categories;
  final List<String> materials;
  final String logoUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Firebase Collection (Need to Create):
```
/seller_profiles/{sellerId}
  - company_name: string
  - gst_number: string
  - address: string
  - city: string
  - state: string
  - pincode: string
  - phone: string
  - email: string
  - website: string
  - description: string
  - categories: string[]
  - materials: string[]
  - logo_url: string
  - is_verified: boolean
  - created_at: timestamp
  - updated_at: timestamp
```

### **ACTION NEEDED:**
🔴 **HIGH PRIORITY**  
✅ Create `firebaseSellerProfilesProvider`  
✅ Migrate `SellerStore.updateProfileData()` to write to Firestore  
✅ Add admin approval workflow for seller verification

---

## 5️⃣ KYC SUBMISSIONS 📄
**Status:** ✅ **SYNCED** (Firebase provider exists)

### Flows:
- **Seller:** Submits KYC documents to become verified seller
- **Admin:** Reviews KYC submissions, approves/rejects
- **User:** Sees "Verified Seller" badge on approved sellers

### Current Implementation:
- `kycPendingSubmissionsProvider` - Real-time Firestore stream ✅
- `kycSubmissionsByStatusProvider` - Filtered streams ✅
- `KycManagementPageV2` - Admin uses Firebase ✅

### Data Model:
```dart
class KycSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? reviewComments;
  final List<Map<String, dynamic>> documents;
}
```

### Firebase Collection:
```
/kyc_submissions/{submissionId}
  - user_id: string
  - user_name: string
  - user_email: string
  - status: enum [pending, approved, rejected]
  - created_at: timestamp
  - reviewed_at: timestamp
  - reviewer_id: string
  - review_comments: string
  - documents: array of { type, url, file_name, uploaded_at }
```

### **SYNC FLOW:**
1. Seller submits KYC → Writes to `/kyc_submissions`
2. Admin sees pending KYC → Reads from `kycPendingSubmissionsProvider`
3. Admin approves → Updates `/kyc_submissions/{id}` AND `/users/{userId}.isVerified = true`
4. Seller profile updates immediately → `firebaseAllUsersProvider` streams update

---

## 6️⃣ REVIEWS & RATINGS ⭐
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **User:** Writes reviews, rates products, uploads review images
- **Seller:** Views reviews for own products
- **Admin:** Moderates reviews, removes inappropriate content

### Current Implementation:
- `ReviewsRepositoryService` - Demo data only ⚠️
- No Firebase provider ❌

### Data Model:
```dart
class Review {
  final String id;
  final String productId;
  final String userId;
  final String authorDisplay;
  final int rating; // 1-5
  final String? title;
  final String body;
  final List<ReviewImage> images;
  final DateTime createdAt;
  final Map<String, bool> helpfulVotesByUser;
  final bool reported;
}
```

### Firebase Collection (Need to Create):
```
/reviews/{reviewId}
  - product_id: string
  - user_id: string
  - author_display: string (masked for privacy)
  - rating: number (1-5)
  - title: string
  - body: string
  - images: array of { url, width, height }
  - created_at: timestamp
  - updated_at: timestamp
  - helpful_votes: map<userId, boolean>
  - reported: boolean
  - status: enum [published, hidden, removed]
```

### **ACTION NEEDED:**
🔴 **HIGH PRIORITY**  
✅ Create `firebaseReviewsProvider`  
✅ Migrate `ReviewsRepositoryService` to write to Firestore  
✅ Add admin moderation workflow  
✅ Update product ratings in real-time when reviews are added

---

## 7️⃣ LEADS 🎯
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **User (Buyer):** Creates leads for products they want to buy
- **Seller:** Views leads matching their products/materials
- **Admin:** Monitors lead quality, removes spam

### Current Implementation:
- `SellerStore.leads` - Demo data only ⚠️
- `LeadsPage` - Shows empty list ⚠️

### Data Model:
```dart
class Lead {
  final String id;
  final String title;
  final String industry;
  final List<String> materials;
  final String city;
  final String state;
  final int qty;
  final double turnoverCr;
  final DateTime needBy;
  final String status; // new, contacted, quoted, closed
  final String about;
  final String createdBy; // userId
  final DateTime createdAt;
}
```

### Firebase Collection (Need to Create):
```
/leads/{leadId}
  - title: string
  - industry: string
  - materials: string[]
  - city: string
  - state: string
  - qty: number
  - turnover_cr: number
  - need_by: timestamp
  - status: enum [new, contacted, quoted, closed, lost]
  - about: string
  - created_by: string (userId)
  - created_at: timestamp
  - updated_at: timestamp
  - matched_sellers: string[] (seller IDs)
```

### **ACTION NEEDED:**
🔴 **HIGH PRIORITY**  
✅ Create `firebaseLeadsProvider`  
✅ Implement lead creation from buyer side  
✅ Implement lead matching algorithm (by materials/location)  
✅ Add seller notification when new matching lead appears

---

## 8️⃣ MESSAGING / CONVERSATIONS 💬
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **User → Seller:** Message about product inquiries
- **User → Admin:** Support conversations
- **Seller → User:** Respond to product inquiries
- **Admin → Anyone:** Broadcast notifications

### Current Implementation:
- `MessagingStore` - Uses `LightweightDemoDataService` ⚠️
- No Firebase provider ❌
- No real-time updates ❌

### Data Model:
```dart
class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final List<String> participants; // userIds
  final bool isPinned;
  final bool isSupport;
  final DateTime updatedAt;
  final int unreadCount;
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final List<Attachment> attachments;
  final DateTime sentAt;
  final bool isRead;
}
```

### Firebase Collection (Need to Create):
```
/conversations/{conversationId}
  - title: string
  - participants: string[] (userIds)
  - is_pinned: boolean
  - is_support: boolean
  - last_message: {text, sender_id, sent_at}
  - updated_at: timestamp
  - unread_by: string[] (userIds who haven't read)

/conversations/{conversationId}/messages/{messageId}
  - sender_id: string
  - text: string
  - attachments: array of {url, type, file_name}
  - sent_at: timestamp
  - read_by: string[] (userIds who read it)
  - reply_to_message_id: string
```

### **ACTION NEEDED:**
🔴 **CRITICAL** (Priority 1 - mentioned in previous audit)  
✅ Create `firebaseConversationsProvider`  
✅ Create `firebaseMessagesProvider(conversationId)`  
✅ Migrate `MessagingStore` to use Firebase  
✅ Implement real-time message updates  
✅ Add push notifications for new messages

---

## 9️⃣ NOTIFICATIONS 🔔
**Status:** ✅ **PARTIALLY SYNCED** (Service exists, needs expansion)

### Flows:
- **Admin → Users:** Broadcast notifications
- **System → User:** Product approved, KYC status, new message alerts
- **System → Seller:** New lead matched, order received

### Current Implementation:
- `notificationServiceProvider` - Firebase-backed ✅
- `AppNotification` model exists ✅
- Admin can send notifications ✅
- Missing: Automated system notifications ⚠️

### Data Model:
```dart
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // info, success, warning, error, system
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? userId; // null for global notifications
}
```

### Firebase Collection:
```
/notifications/{notificationId}
  - title: string
  - message: string
  - type: enum [info, success, warning, error, system]
  - data: map (optional)
  - created_at: timestamp
  - is_read: boolean
  - user_id: string (null for broadcast)
  - action_url: string (deep link)
```

### **ACTION NEEDED:**
🟡 **MEDIUM PRIORITY**  
✅ Add automated notification triggers (product approved, KYC status, etc.)  
✅ Implement push notifications (FCM)  
✅ Add notification preferences per user

---

## 🔟 SUBSCRIPTIONS & BILLING 💳
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **Admin:** Creates plans, sets pricing, manages subscriptions
- **Seller:** Upgrades/downgrades plan
- **User:** Views plan limits

### Current Implementation:
- `SubscriptionManagementPage` - Admin UI exists ✅
- `SellerStore._currentPlan` - In-memory only ⚠️
- No Firebase provider ❌

### Data Model:
```dart
class SubscriptionPlan {
  final String id;
  final String name;
  final String displayName;
  final double price;
  final String currency;
  final String interval; // month, year
  final Map<String, dynamic> limits; // maxProducts, maxAds, etc.
  final List<String> features;
}

class UserSubscription {
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // active, canceled, expired
  final String paymentMethod;
}
```

### Firebase Collections (Need to Create):
```
/subscription_plans/{planId}
  - name: string
  - display_name: string
  - price: number
  - currency: string
  - interval: enum [month, year]
  - limits: { max_products, max_ads, has_analytics }
  - features: string[]
  - is_active: boolean

/user_subscriptions/{userId}
  - plan_id: string
  - start_date: timestamp
  - end_date: timestamp
  - status: enum [active, canceled, expired, pending]
  - payment_method: string
  - auto_renew: boolean
```

### **ACTION NEEDED:**
🟡 **MEDIUM PRIORITY**  
✅ Create `firebaseSubscriptionPlansProvider`  
✅ Create `firebaseUserSubscriptionProvider(userId)`  
✅ Integrate payment gateway (Razorpay/Stripe)  
✅ Implement plan limits enforcement in app

---

## 1️⃣1️⃣ ANALYTICS 📊
**Status:** ✅ **PARTIALLY SYNCED** (Admin analytics exist)

### Flows:
- **Admin:** Views dashboard analytics (users, products, orders)
- **Seller:** Views own product analytics (views, clicks, contacts)
- **System:** Tracks events (page views, searches, product clicks)

### Current Implementation:
- `adminDashboardAnalyticsProvider` - Firebase-backed ✅
- `adminProductAnalyticsProvider` - Firebase-backed ✅
- `adminUserAnalyticsProvider` - Firebase-backed ✅
- `SellerStore` analytics - In-memory only ⚠️
- `analyticsServiceProvider` - Event logging works ✅

### Data Model:
```dart
class AnalyticsSnapshot {
  final int totalUsers;
  final int activeSellers;
  final int totalProducts;
  final int totalOrders;
  final Map<String, dynamic> metrics;
  final List<ActivityEvent> events;
  final DateTime lastUpdated;
}

class ProductAnalytics {
  final String productId;
  final int views;
  final int clicks;
  final int contacts;
  final Map<String, int> viewsByCity;
  final DateTime lastUpdated;
}
```

### Firebase Collections:
```
/analytics/dashboard
  - total_users: number
  - active_sellers: number
  - total_products: number
  - total_orders: number
  - metrics: map
  - last_updated: timestamp

/analytics/products/{productId}
  - views: number
  - clicks: number
  - contacts: number
  - views_by_city: map
  - last_updated: timestamp

/analytics/events/{eventId}
  - type: string
  - entity_type: string
  - entity_id: string
  - user_id: string
  - timestamp: timestamp
  - metadata: map
```

### **ACTION NEEDED:**
🟢 **LOW PRIORITY** (Already works well)  
✅ Migrate seller analytics to Firebase  
✅ Add real-time charts for sellers

---

## 1️⃣2️⃣ HERO SECTIONS (Homepage Banners) 🎨
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **Admin:** Creates, updates, reorders hero sections for homepage
- **User:** Sees hero sections on homepage

### Current Implementation:
- `EnhancedHeroSectionsPage` - Admin UI exists ✅
- `HomePageV2` - Shows demo data ⚠️
- No Firebase provider ❌

### Data Model:
```dart
class HeroSection {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final int priority;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Firebase Collection (Need to Create):
```
/hero_sections/{sectionId}
  - title: string
  - subtitle: string
  - image_path: string
  - is_active: boolean
  - priority: number
  - action_url: string
  - created_at: timestamp
  - updated_at: timestamp
```

### **ACTION NEEDED:**
🟡 **MEDIUM PRIORITY**  
✅ Create `firebaseHeroSectionsProvider`  
✅ Migrate `HomePageV2` to use Firebase provider

---

## 1️⃣3️⃣ PRODUCT DESIGNS (Templates) 📐
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **Admin:** Creates product templates/designs
- **Seller:** Uses templates when creating products
- **User:** Sees standardized product information

### Current Implementation:
- `ProductDesignsPage` - Admin UI exists ✅
- No Firebase provider ❌

### Data Model:
```dart
class ProductDesign {
  final String id;
  final String name;
  final String category;
  final List<CustomFieldDef> fields;
  final DateTime createdAt;
}
```

### Firebase Collection (Need to Create):
```
/product_designs/{designId}
  - name: string
  - category: string
  - fields: array of {id, label, type, options}
  - created_at: timestamp
  - is_active: boolean
```

### **ACTION NEEDED:**
🟢 **LOW PRIORITY**  
✅ Create `firebaseProductDesignsProvider`

---

## 1️⃣4️⃣ FEATURE FLAGS 🚩
**Status:** ⚠️ **NOT SYNCED** (No Firebase provider)

### Flows:
- **Admin:** Toggles features on/off without app deployment
- **App:** Checks feature flags to enable/disable features

### Current Implementation:
- `FeatureFlagsPage` - Admin UI exists ✅
- No Firebase provider ❌

### Data Model:
```dart
class FeatureFlag {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final Map<String, dynamic> config;
}
```

### Firebase Collection (Need to Create):
```
/system/feature_flags
  - flags: map<flag_name, {enabled, config}>
  - updated_at: timestamp
```

### **ACTION NEEDED:**
🟡 **MEDIUM PRIORITY**  
✅ Create `firebaseFeatureFlagsProvider`  
✅ Add remote config integration

---

## 1️⃣5️⃣ ORDERS 🛒
**Status:** ❌ **NOT IMPLEMENTED YET**

### Flows (Future):
- **User:** Places orders for products
- **Seller:** Receives orders, updates order status
- **Admin:** Monitors all orders, resolves disputes

### Data Model (Proposed):
```dart
class Order {
  final String id;
  final String userId;
  final String sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // pending, confirmed, shipped, delivered, canceled
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? deliveredAt;
}
```

### Firebase Collection (Need to Create):
```
/orders/{orderId}
  - user_id: string
  - seller_id: string
  - items: array of {product_id, quantity, price}
  - total_amount: number
  - status: enum [pending, confirmed, shipped, delivered, canceled]
  - payment_status: enum [pending, paid, refunded]
  - created_at: timestamp
  - updated_at: timestamp
  - delivered_at: timestamp
```

### **ACTION NEEDED:**
🔵 **FUTURE** (Not yet implemented)

---

## 1️⃣6️⃣ STATE INFO (Electricity Boards) ⚡
**Status:** ⚠️ **NOT SYNCED** (Demo data only)

### Flows:
- **Admin:** Adds/updates electricity board information, posts, media
- **User:** Views electricity board data for their state

### Current Implementation:
- `LightweightStateInfoPage` - Shows demo data ⚠️
- No Firebase provider ❌

### Data Model:
```dart
class PowerGenerator {
  final String id;
  final String name;
  final String type;
  final String capacity;
  final String location;
  final String logo;
  final List<Post> posts;
  final List<ProductDesign> productDesigns;
}
```

### Firebase Collection (Need to Create):
```
/state_info/{stateId}/power_generators/{generatorId}
  - name, type, capacity, location, logo
  - posts: array or subcollection
  - product_designs: array or subcollection
```

### **ACTION NEEDED:**
🟢 **LOW PRIORITY**  
✅ Create `firebaseStateInfoProvider`

---

## 1️⃣7️⃣ RBAC (Roles & Permissions) 🔐
**Status:** ✅ **SYNCED** (RbacProvider exists)

### Flows:
- **Admin:** Manages roles and permissions
- **App:** Checks permissions before showing features

### Current Implementation:
- `rbacProvider` - State-based ✅
- Works well for current needs ✅

### **ACTION NEEDED:**
✅ None (already working)

---

## 1️⃣8️⃣ LOCATION & SEARCH 🌍
**Status:** ✅ **SYNCED** (Providers exist)

### Flows:
- **User:** Sets location, searches nearby products
- **Seller:** Products are geotagged
- **Admin:** Views analytics by location

### Current Implementation:
- `locationServiceProvider` - Works ✅
- `locationAwareFilterServiceProvider` - Works ✅

### **ACTION NEEDED:**
✅ None (already working)

---

## 1️⃣9️⃣ AUDIT LOGS 📝
**Status:** ⚠️ **PARTIALLY SYNCED**

### Flows:
- **Admin:** Views all admin actions in audit log
- **System:** Records all CRUD operations

### Current Implementation:
- `AdminStore.auditLog` - In-memory only ⚠️

### Firebase Collection (Need to Create):
```
/audit_logs/{logId}
  - action: string
  - entity_type: string
  - entity_id: string
  - user_id: string
  - details: map
  - timestamp: timestamp
```

### **ACTION NEEDED:**
🟡 **MEDIUM PRIORITY**  
✅ Create `firebaseAuditLogsProvider`  
✅ Add audit logging to all Firebase writes

---

## 2️⃣0️⃣ ADVERTISEMENTS 📢
**Status:** ⚠️ **NOT SYNCED** (Demo data only)

### Flows:
- **Seller:** Creates ad campaigns for products
- **Admin:** Approves ad campaigns
- **User:** Sees promoted products in search/categories

### Current Implementation:
- `SellerStore.ads` - In-memory only ⚠️
- `AdsPage` - Shows demo data ⚠️

### Data Model:
```dart
class AdCampaign {
  final String id;
  final String sellerId;
  final String productId;
  final AdType type; // search, category, homepage
  final String term; // search term or category name
  final int slot;
  final double budgetDaily;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // draft, pending, active, paused, ended
}
```

### Firebase Collection (Need to Create):
```
/ad_campaigns/{campaignId}
  - seller_id: string
  - product_id: string
  - type: enum [search, category, homepage]
  - term: string
  - slot: number
  - budget_daily: number
  - start_date: timestamp
  - end_date: timestamp
  - status: enum [draft, pending, active, paused, ended]
  - metrics: {impressions, clicks, conversions}
```

### **ACTION NEEDED:**
🟢 **LOW PRIORITY**  
✅ Create `firebaseAdCampaignsProvider`  
✅ Implement ad approval workflow

---

## 2️⃣1️⃣ SEARCH HISTORY & ANALYTICS 🔍
**Status:** ⚠️ **NOT SYNCED** (Demo data only)

### Flows:
- **User:** Search queries are saved
- **Admin:** Views popular search terms
- **Seller:** Sees what users search for

### Current Implementation:
- `SearchStore` - In-memory only ⚠️

### Firebase Collection (Need to Create):
```
/search_history/{userId}/searches/{searchId}
  - query: string
  - timestamp: timestamp
  - results_count: number
  - clicked_product_id: string

/search_analytics/{term}
  - query: string
  - search_count: number
  - click_through_rate: number
  - last_searched: timestamp
```

### **ACTION NEEDED:**
🟢 **LOW PRIORITY**  
✅ Create `firebaseSearchHistoryProvider`

---

## 2️⃣2️⃣ MEDIA STORAGE 📁
**Status:** ✅ **SYNCED** (Firebase Storage integrated)

### Flows:
- **Seller:** Uploads product images
- **Admin:** Uploads hero section images
- **User:** Uploads review images

### Current Implementation:
- Firebase Storage integrated ✅
- `mediaUploadProvider` exists ✅

### **ACTION NEEDED:**
✅ None (already working)

---

## 2️⃣3️⃣ PAYMENTS & INVOICES 💰
**Status:** ⚠️ **NOT SYNCED** (Models exist, no implementation)

### Flows:
- **User:** Pays for subscription
- **Seller:** Receives invoices
- **Admin:** Manages billing and taxes

### Current Implementation:
- `BillingManagementPage` - Admin UI placeholder ⚠️
- No Firebase provider ❌

### Firebase Collections (Need to Create):
```
/payments/{paymentId}
  - user_id: string
  - amount: number
  - currency: string
  - status: enum [pending, completed, failed, refunded]
  - method: enum [card, upi, netbanking, wallet]
  - transaction_id: string
  - created_at: timestamp

/invoices/{invoiceId}
  - user_id: string
  - invoice_number: string
  - issue_date: timestamp
  - due_date: timestamp
  - total_amount: number
  - status: enum [draft, sent, paid, overdue]
```

### **ACTION NEEDED:**
🔵 **FUTURE** (Not yet implemented)

---

## 2️⃣4️⃣ COMPLIANCE & LEGAL 📜
**Status:** ⚠️ **NOT SYNCED** (Models exist, no implementation)

### Flows:
- **Admin:** Manages terms of service, privacy policy
- **User:** Accepts terms on signup

### Current Implementation:
- Models exist ⚠️
- No Firebase provider ❌

### **ACTION NEEDED:**
🔵 **FUTURE** (Not yet implemented)

---

## 2️⃣5️⃣ SYSTEM OPERATIONS ⚙️
**Status:** ⚠️ **NOT SYNCED** (Admin UI only)

### Flows:
- **Admin:** Triggers system operations (cache clear, data migration)
- **System:** Executes background jobs

### Current Implementation:
- `SystemOperationsPage` - Admin UI exists ✅
- No Firebase provider ❌

### **ACTION NEEDED:**
🟢 **LOW PRIORITY**  
✅ Implement Cloud Functions for system operations

---

## 🎯 PRIORITY MATRIX

### 🔴 **CRITICAL (Fix NOW)**
1. **Messaging/Conversations** - No real-time chat is a major issue
2. **Products (Seller Side)** - Sellers can't sync their products to Firebase
3. **Seller Profiles** - Profile updates don't persist

### 🔴 **HIGH PRIORITY (Fix in 1-2 weeks)**
4. **Reviews & Ratings** - Product credibility depends on this
5. **Leads** - Core B2B feature not working
6. **KYC Auto-Sync** - Seller verification flow needs full sync
7. **Audit Logs** - Compliance requirement

### 🟡 **MEDIUM PRIORITY (Fix in 1 month)**
8. **Subscriptions & Billing** - Revenue feature
9. **Hero Sections** - Marketing/homepage content
10. **Feature Flags** - DevOps improvement
11. **Notifications (Auto)** - User engagement
12. **Advertisements** - Monetization feature

### 🟢 **LOW PRIORITY (Nice to have)**
13. **State Info** - Reference data
14. **Product Designs** - Templates
15. **Search Analytics** - Insights
16. **Analytics (Seller Side)** - Reports

### 🔵 **FUTURE (Not implemented yet)**
17. **Orders** - E-commerce feature
18. **Payments & Invoices** - Billing system
19. **Compliance** - Legal documents

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 1: Critical Fixes (Week 1-2)
- [ ] Create `firebaseConversationsProvider` + real-time chat
- [ ] Migrate `SellerStore` products to Firebase
- [ ] Create `firebaseSellerProfilesProvider`
- [ ] Test end-to-end sync for all 3

### Phase 2: High Priority (Week 3-4)
- [ ] Create `firebaseReviewsProvider` + moderation
- [ ] Create `firebaseLeadsProvider` + matching
- [ ] Implement KYC → User verification auto-sync
- [ ] Create `firebaseAuditLogsProvider`

### Phase 3: Medium Priority (Month 2)
- [ ] Create `firebaseSubscriptionPlansProvider`
- [ ] Integrate payment gateway (Razorpay)
- [ ] Create `firebaseHeroSectionsProvider`
- [ ] Create `firebaseFeatureFlagsProvider`
- [ ] Add automated notifications

### Phase 4: Low Priority (Month 3)
- [ ] Migrate remaining demo data to Firebase
- [ ] Add seller analytics to Firebase
- [ ] Create `firebaseStateInfoProvider`

---

## 🔧 TECHNICAL RECOMMENDATIONS

### 1. Create a Unified Migration Service
```dart
// lib/services/firebase_migration_service.dart
class FirebaseMigrationService {
  Future<void> migrateProductsToFirestore() async { ... }
  Future<void> migrateSellerProfilesToFirestore() async { ... }
  Future<void> migrateConversationsToFirestore() async { ... }
  Future<void> migrateReviewsToFirestore() async { ... }
}
```

### 2. Add Transaction Support
```dart
// Ensure atomic updates across collections
await firestore.runTransaction((transaction) async {
  // Update KYC status
  transaction.update(kycRef, {'status': 'approved'});
  // Update user verification
  transaction.update(userRef, {'isVerified': true});
});
```

### 3. Add Offline Support
```dart
// Enable Firestore offline persistence
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 4. Add Batch Operations for Admin
```dart
// Bulk approve/reject KYC submissions
Future<void> bulkApproveKyc(List<String> submissionIds) async {
  final batch = firestore.batch();
  for (final id in submissionIds) {
    batch.update(firestore.collection('kyc_submissions').doc(id), {
      'status': 'approved',
      'reviewed_at': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
```

---

## 📊 CURRENT STATE SUMMARY

| Feature | Admin | Seller | User | Firebase | Priority |
|---------|-------|--------|------|----------|----------|
| Categories | ✅ | ✅ | ✅ | ✅ | DONE |
| Products (Admin) | ✅ | ❌ | ✅ | ✅ | HIGH |
| Products (Seller) | N/A | ❌ | ✅ | ❌ | CRITICAL |
| Users | ✅ | N/A | ✅ | ✅ | DONE |
| Seller Profiles | ✅ | ❌ | ✅ | ❌ | CRITICAL |
| KYC | ✅ | ✅ | N/A | ✅ | DONE |
| Reviews | ❌ | ✅ | ✅ | ❌ | HIGH |
| Leads | ❌ | ✅ | ✅ | ❌ | HIGH |
| Messaging | ❌ | ✅ | ✅ | ❌ | CRITICAL |
| Notifications | ✅ | ✅ | ✅ | ✅ | MEDIUM |
| Subscriptions | ✅ | ✅ | ✅ | ❌ | MEDIUM |
| Analytics | ✅ | ✅ | N/A | ✅ | LOW |
| Hero Sections | ✅ | N/A | ✅ | ❌ | MEDIUM |
| Feature Flags | ✅ | N/A | N/A | ❌ | MEDIUM |

**Legend:**  
✅ = Working  
❌ = Not working/Missing  
N/A = Not applicable

---

## 🎓 NEXT STEPS

1. **Review this document** with your team
2. **Prioritize features** based on business needs
3. **Start with Phase 1** (Critical fixes)
4. **Create GitHub issues** for each feature
5. **Assign owners** to each migration task
6. **Track progress** using this checklist

---

**Document Created:** October 1, 2025  
**Last Updated:** October 1, 2025  
**Author:** AI Assistant  
**Status:** COMPLETE - Ready for review





