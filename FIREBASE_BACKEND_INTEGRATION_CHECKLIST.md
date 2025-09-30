# Firebase Backend Integration Checklist for Vidyut App

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Firebase Services Setup](#firebase-services-setup)
3. [Database Schema Design](#database-schema-design)
4. [Feature-by-Feature Integration](#feature-by-feature-integration)
5. [Riverpod Integration Patterns](#riverpod-integration-patterns)
6. [Security Rules](#security-rules)
7. [Performance Optimization](#performance-optimization)
8. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

### Separation of Concerns

```
UI Layer (Flutter Widgets)
    ↓
Riverpod State Management
    ↓
Firebase Services Layer
    ↓
Firebase Backend (Firestore, Auth, Storage, Functions)
```

### Core Principles

- **Single Source of Truth**: Firebase as the authoritative data source
- **Reactive Updates**: Real-time synchronization via Riverpod providers
- **Offline Support**: Local caching with Riverpod for offline functionality
- **Type Safety**: Strong typing with Dart models and Firestore converters
- **Error Handling**: Comprehensive error states in Riverpod providers

---

## Firebase Services Setup

### 1. Firebase Project Configuration

- [ ] Create Firebase project
- [ ] Enable Authentication (Email/Password, Phone, Google)
- [ ] Enable Firestore Database
- [ ] Enable Cloud Storage
- [ ] Enable Cloud Functions
- [ ] Configure Firebase Security Rules
- [ ] Set up Firebase Analytics
- [ ] Configure Firebase Crashlytics
- [ ] Set up Firebase Performance Monitoring

### 2. Flutter Firebase Integration

- [ ] Add Firebase SDK dependencies
- [ ] Configure `firebase_options.dart`
- [ ] Set up platform-specific configurations
- [ ] Initialize Firebase services in `main.dart`

---

## Database Schema Design

### Firestore Collections Structure

```
vidyut_app/
├── users/                          # User profiles and authentication data
├── seller_profiles/                # Seller-specific information
├── products/                       # Product catalog
├── categories/                     # Product categories and subcategories
├── reviews/                        # Product reviews and ratings
├── conversations/                  # Messaging system
├── leads/                          # B2B lead management
├── orders/                         # Order management (if implemented)
├── subscriptions/                  # Subscription plans and billing
├── state_info/                     # State electricity board information
├── admin/                          # Admin-specific data
│   ├── notifications/              # Broadcast notifications
│   ├── kyc_submissions/           # KYC verification data
│   ├── hero_sections/             # Homepage hero sections
│   └── product_designs/           # Product design schemas
├── analytics/                      # Analytics and tracking data
└── system/                         # System configuration and feature flags
```

---

## Feature-by-Feature Integration

### 1. Authentication & User Management

#### Firestore Collections

```typescript
// users/{userId}
{
  id: string,
  name: string,
  email: string,
  phone?: string,
  profileImageUrl?: string,
  role: 'buyer' | 'seller' | 'admin' | 'guest',
  status: 'active' | 'pending' | 'suspended' | 'inactive',
  subscriptionPlan: 'free' | 'plus' | 'pro' | 'enterprise',
  isEmailVerified: boolean,
  isPhoneVerified: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastActive: Timestamp,
  location?: {
    city: string,
    state: string,
    coordinates: GeoPoint
  },
  industry?: string,
  materials: string[],
  preferences: object,
  isSeller: boolean,
  sellerProfileId?: string,
  sellerActivatedAt?: Timestamp,
  currentPlanCode?: string
}
```

#### Riverpod Integration

- [ ] `firebaseAuthServiceProvider` - Firebase Auth state
- [ ] `sessionProvider` - Derived session with user data
- [ ] `userProfileProvider` - User profile management
- [ ] `userStoreProvider` - User state management

#### Firebase Services

- [ ] Email/Password authentication
- [ ] Phone number authentication with OTP
- [ ] Google Sign-In integration
- [ ] Email verification
- [ ] Password reset functionality
- [ ] User profile CRUD operations

### 2. Product Management

#### Firestore Collections

```typescript
// products/{productId}
{
  id: string,
  title: string,
  brand: string,
  subtitle: string,
  category: string,
  description: string,
  images: string[],
  documents: string[],
  price: number,
  moq: number,
  gstRate: number,
  materials: string[],
  customValues: object,
  status: 'active' | 'inactive' | 'pending' | 'rejected',
  createdAt: Timestamp,
  updatedAt: Timestamp,
  rating: number,
  location: {
    latitude: number,
    longitude: number,
    city: string,
    state: string,
    area?: string,
    pincode?: string
  },
  sellerId: string,
  sellerProfileId: string,
  viewCount: number,
  inquiryCount: number,
  isFeatured: boolean,
  tags: string[]
}

// categories/{categoryId}
{
  id: string,
  name: string,
  description: string,
  imageUrl: string,
  parentId?: string,
  level: number,
  path: string[],
  isActive: boolean,
  priority: number,
  industries: string[],
  materials: string[],
  productCount: number,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Riverpod Integration

- [ ] `productsProvider` - Paginated product listings
- [ ] `productDetailProvider` - Individual product details
- [ ] `categoriesProvider` - Product categories tree
- [ ] `categoriesStoreProvider` - Categories management

#### Firebase Services

- [ ] Product CRUD operations
- [ ] Product search and filtering
- [ ] Category management
- [ ] Product image upload to Cloud Storage
- [ ] Product document management
- [ ] Product analytics tracking

### 3. Messaging System

#### Firestore Collections

```typescript
// conversations/{conversationId}
{
  id: string,
  participants: string[], // userIds
  lastMessage?: {
    text: string,
    senderId: string,
    timestamp: Timestamp,
    type: 'text' | 'image' | 'document'
  },
  isActive: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  productId?: string, // If conversation is about a product
  leadId?: string, // If conversation is about a lead
  unreadCount: { [userId: string]: number }
}

// messages/{messageId}
{
  id: string,
  conversationId: string,
  senderId: string,
  text: string,
  type: 'text' | 'image' | 'document',
  attachments: {
    url: string,
    type: string,
    name: string,
    size: number
  }[],
  timestamp: Timestamp,
  isRead: boolean,
  readBy: { [userId: string]: Timestamp }
}
```

#### Riverpod Integration

- [ ] `threadsProvider` - Message threads list
- [ ] `threadMessagesProvider` - Messages in a thread
- [ ] `unreadCountProvider` - Unread message count
- [ ] `messagingStoreProvider` - Messaging state management

#### Firebase Services

- [ ] Real-time message synchronization
- [ ] File attachment handling
- [ ] Message status tracking
- [ ] Push notifications for new messages

### 4. Reviews & Ratings

#### Firestore Collections

```typescript
// reviews/{reviewId}
{
  id: string,
  productId: string,
  userId: string,
  authorDisplay: string,
  rating: number, // 1-5
  title?: string,
  body: string,
  images: {
    url: string,
    thumbnailUrl: string,
    alt: string
  }[],
  createdAt: Timestamp,
  updatedAt?: Timestamp,
  helpfulVotes: { [userId: string]: boolean },
  reported: boolean,
  attributes: { [key: string]: string },
  isVerified: boolean,
  sellerResponse?: {
    text: string,
    timestamp: Timestamp
  }
}
```

#### Riverpod Integration

- [ ] `reviewsProvider` - Product reviews
- [ ] `reviewComposerProvider` - Review composition state
- [ ] `reviewsRepositoryProvider` - Reviews repository

#### Firebase Services

- [ ] Review submission and validation
- [ ] Image upload for reviews
- [ ] Review moderation system
- [ ] Rating aggregation and calculation

### 5. Lead Management

#### Firestore Collections

```typescript
// leads/{leadId}
{
  id: string,
  productId: string,
  sellerId: string,
  buyerId: string,
  status: 'new' | 'contacted' | 'qualified' | 'proposal' | 'negotiation' | 'closed_won' | 'closed_lost',
  priority: 'low' | 'medium' | 'high',
  source: 'product_inquiry' | 'direct_contact' | 'referral',
  inquiry: {
    message: string,
    quantity: number,
    budget?: number,
    timeline?: string,
    requirements?: string
  },
  contactInfo: {
    name: string,
    email: string,
    phone: string,
    company?: string
  },
  notes: string[],
  attachments: string[],
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastContactAt?: Timestamp,
  expectedCloseDate?: Timestamp,
  actualCloseDate?: Timestamp,
  value: number
}
```

#### Riverpod Integration

- [ ] `leadsProvider` - Paginated leads with role scoping
- [ ] `leadDetailProvider` - Individual lead details

#### Firebase Services

- [ ] Lead creation and management
- [ ] Lead status tracking
- [ ] Lead analytics and reporting
- [ ] Lead assignment and routing

### 6. State Information System

#### Firestore Collections

```typescript
// state_info/{stateInfoId}
{
  id: string,
  title: string,
  content: string,
  type: 'article' | 'video' | 'infographic' | 'document',
  state: string,
  sector: 'generation' | 'transmission' | 'distribution',
  tags: string[],
  media: {
    url: string,
    type: string,
    thumbnailUrl?: string
  }[],
  author: string,
  publishedAt: Timestamp,
  updatedAt: Timestamp,
  isActive: boolean,
  viewCount: number,
  priority: number
}

// product_designs/{designId}
{
  id: string,
  title: string,
  description: string,
  category: string,
  stateId: string,
  sectorId: string,
  sectorType: string,
  author: string,
  uploadDate: Timestamp,
  tags: string[],
  files: {
    url: string,
    name: string,
    type: string,
    size: number
  }[],
  thumbnailUrl?: string,
  isActive: boolean,
  guidelines?: string,
  specifications?: string
}
```

#### Riverpod Integration

- [ ] `stateInfoProvider` - State information feed
- [ ] `stateInfoCompareProvider` - Region comparison
- [ ] `stateInfoNavProvider` - Navigation state
- [ ] `stateInfoStoreProvider` - State info store
- [ ] `stateInfoEditStoreProvider` - State info edit store

#### Firebase Services

- [ ] State information CRUD operations
- [ ] File upload for documents and media
- [ ] Content moderation and approval workflow
- [ ] Analytics for content engagement

### 7. Admin Management

#### Firestore Collections

```typescript
// admin/notifications/{notificationId}
{
  id: string,
  title: string,
  message: string,
  type: 'broadcast' | 'targeted' | 'system',
  targetAudience: {
    roles: string[],
    locations: string[],
    industries: string[]
  },
  status: 'draft' | 'scheduled' | 'sent' | 'failed',
  scheduledAt?: Timestamp,
  sentAt?: Timestamp,
  createdBy: string,
  createdAt: Timestamp,
  deliveryStats: {
    total: number,
    delivered: number,
    failed: number,
    opened: number
  }
}

// admin/kyc_submissions/{submissionId}
{
  id: string,
  userId: string,
  status: 'pending' | 'approved' | 'rejected',
  documents: {
    type: string,
    url: string,
    status: 'pending' | 'verified' | 'rejected'
  }[],
  submittedAt: Timestamp,
  reviewedAt?: Timestamp,
  reviewedBy?: string,
  rejectionReason?: string,
  notes: string
}

// admin/hero_sections/{sectionId}
{
  id: string,
  title: string,
  subtitle: string,
  imageUrl: string,
  ctaText: string,
  ctaUrl: string,
  isActive: boolean,
  priority: number,
  targetAudience: {
    roles: string[],
    locations: string[]
  },
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Riverpod Integration

- [ ] `notificationsProvider` - Broadcast center
- [ ] `kycSubmissionsProvider` - KYC submissions
- [ ] `heroSectionsProvider` - Hero sections management
- [ ] `productDesignsProvider` - Product design schemas
- [ ] `adminStoreProvider` - Admin store for management
- [ ] `enhancedAdminStoreProvider` - Enhanced admin store

#### Firebase Services

- [ ] Admin dashboard data aggregation
- [ ] User management and role assignment
- [ ] Content moderation workflows
- [ ] System analytics and reporting
- [ ] KYC verification process

### 8. Subscription & Billing

#### Firestore Collections

```typescript
// subscriptions/{subscriptionId}
{
  id: string,
  userId: string,
  planId: string,
  status: 'active' | 'cancelled' | 'expired' | 'pending',
  startDate: Timestamp,
  endDate: Timestamp,
  autoRenew: boolean,
  paymentMethod: string,
  amount: number,
  currency: string,
  billingCycle: 'monthly' | 'yearly',
  features: string[],
  limits: {
    products: number,
    leads: number,
    storage: number
  },
  usage: {
    products: number,
    leads: number,
    storage: number
  }
}

// invoices/{invoiceId}
{
  id: string,
  subscriptionId: string,
  userId: string,
  amount: number,
  currency: string,
  status: 'draft' | 'pending' | 'paid' | 'overdue' | 'cancelled',
  dueDate: Timestamp,
  paidAt?: Timestamp,
  paymentMethod?: string,
  items: {
    description: string,
    amount: number,
    quantity: number
  }[],
  createdAt: Timestamp
}
```

#### Riverpod Integration

- [ ] `subscriptionPlansProvider` - Available plans
- [ ] `billingProvider` - Billing snapshot

#### Firebase Services

- [ ] Subscription plan management
- [ ] Payment processing integration
- [ ] Invoice generation and management
- [ ] Usage tracking and limits enforcement

### 9. Analytics & Tracking

#### Firestore Collections

```typescript
// analytics/events/{eventId}
{
  id: string,
  userId: string,
  eventType: string,
  eventData: object,
  timestamp: Timestamp,
  sessionId: string,
  platform: 'web' | 'mobile',
  version: string,
  location?: {
    city: string,
    state: string,
    country: string
  }
}

// analytics/metrics/{metricId}
{
  id: string,
  metricType: string,
  value: number,
  dimensions: object,
  timestamp: Timestamp,
  period: 'daily' | 'weekly' | 'monthly'
}
```

#### Riverpod Integration

- [ ] `analyticsProvider` - Analytics data
- [ ] `analyticsServiceProvider` - Analytics service

#### Firebase Services

- [ ] Event tracking and analytics
- [ ] Custom metrics and KPIs
- [ ] Real-time dashboard data
- [ ] Export and reporting capabilities

---

## Riverpod Integration Patterns

### 1. Data Fetching Pattern

```dart
// AsyncNotifier for data fetching
class ProductsNotifier extends FamilyAsyncNotifier<List<Product>, ProductFilters> {
  @override
  Future<List<Product>> build(ProductFilters filters) async {
    return await _fetchProducts(filters);
  }

  Future<void> _fetchProducts(ProductFilters filters) async {
    // Firebase query implementation
  }
}
```

### 2. Real-time Updates Pattern

```dart
// StreamProvider for real-time data
final productsStreamProvider = StreamProvider.family<List<Product>, ProductFilters>(
  (ref, filters) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
  },
);
```

### 3. State Management Pattern

```dart
// Notifier for local state
class ProductFormNotifier extends Notifier<ProductFormState> {
  @override
  ProductFormState build() => ProductFormState.initial();

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  Future<void> saveProduct() async {
    // Save to Firebase
  }
}
```

### 4. Error Handling Pattern

```dart
// Comprehensive error handling
class ProductRepository {
  Future<List<Product>> getProducts(ProductFilters filters) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw ProductException('Failed to fetch products: ${e.message}');
    } catch (e) {
      throw ProductException('Unexpected error: $e');
    }
  }
}
```

---

## Security Rules

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Products are readable by all, writable by sellers
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null &&
        (resource.data.sellerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }

    // Reviews are readable by all, writable by authenticated users
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        (resource.data.userId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }

    // Admin collections
    match /admin/{document=**} {
      allow read, write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Cloud Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Product images
    match /products/{productId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Review images
    match /reviews/{reviewId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Performance Optimization

### 1. Database Optimization

- [ ] Implement proper indexing for all query patterns
- [ ] Use composite indexes for complex queries
- [ ] Optimize document structure for minimal reads
- [ ] Implement pagination for large datasets
- [ ] Use subcollections for hierarchical data

### 2. Caching Strategy

- [ ] Implement local caching with Riverpod
- [ ] Use Firestore offline persistence
- [ ] Cache frequently accessed data
- [ ] Implement cache invalidation strategies

### 3. Real-time Updates

- [ ] Use Firestore listeners efficiently
- [ ] Implement connection state management
- [ ] Handle offline/online transitions
- [ ] Optimize listener subscriptions

---

## Testing Strategy

### 1. Unit Tests

- [ ] Test Riverpod providers in isolation
- [ ] Mock Firebase services
- [ ] Test data transformation logic
- [ ] Test error handling scenarios

### 2. Integration Tests

- [ ] Test Firebase service integration
- [ ] Test real-time updates
- [ ] Test offline functionality
- [ ] Test authentication flows

### 3. End-to-End Tests

- [ ] Test complete user journeys
- [ ] Test cross-platform functionality
- [ ] Test performance under load
- [ ] Test error recovery scenarios

---

## Implementation Priority

### Phase 1: Core Infrastructure

1. Firebase project setup
2. Authentication system
3. Basic user management
4. Core data models

### Phase 2: Product Management

1. Product CRUD operations
2. Category management
3. Search and filtering
4. Image upload

### Phase 3: Communication

1. Messaging system
2. Reviews and ratings
3. Lead management
4. Notifications

### Phase 4: Advanced Features

1. State information system
2. Admin management
3. Analytics and reporting
4. Subscription management

### Phase 5: Optimization

1. Performance optimization
2. Advanced caching
3. Real-time features
4. Testing and monitoring

---

## Monitoring and Maintenance

### 1. Firebase Monitoring

- [ ] Set up Firebase Performance Monitoring
- [ ] Configure Firebase Crashlytics
- [ ] Monitor Firestore usage and costs
- [ ] Set up alerts for errors and performance issues

### 2. Data Management

- [ ] Implement data backup strategies
- [ ] Plan for data migration and versioning
- [ ] Set up data retention policies
- [ ] Monitor data quality and consistency

### 3. Security Monitoring

- [ ] Monitor authentication attempts
- [ ] Track suspicious activities
- [ ] Regular security rule reviews
- [ ] Implement audit logging

---

This comprehensive checklist provides a structured approach to integrating Firebase backend services with your Riverpod state management architecture, ensuring proper separation of concerns and maintainable code structure.
