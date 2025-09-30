# Model Analysis Report - Vidyut App

## Executive Summary

This report provides a comprehensive analysis of all data models in the Vidyut app, their relationships, usage patterns, and any issues found. The analysis identified and resolved duplicate enum definitions and established proper model linkages.

## Model Inventory

### Core Domain Models

#### 1. Product Models
- **Sell Product** (`lib/features/sell/models.dart::Product`)
  - **Fields**: id, title, brand, subtitle, category, description, images, documents, price, moq, gstRate, materials, customValues, status, createdAt, rating, location
  - **Usage**: 15+ UI pages, 5+ services/stores
  - **Relationships**: Uses `ProductLocation`, `ProductStatus`

- **Admin Product** (`lib/features/admin/models/product_models.dart::Product`)
  - **Fields**: id, title, brand, subtitle, category, description, images, price, moq, gstRate, materials, customValues, status, createdAt, updatedAt, rating, viewCount, orderCount
  - **Usage**: Admin UI pages, admin services
  - **Relationships**: Uses `ProductStatus`

#### 2. User & Profile Models
- **UserProfile** (`lib/features/profile/models/user_models.dart`)
  - **Fields**: id, name, email, phone, profileImageUrl, createdAt, updatedAt, isEmailVerified, isPhoneVerified
  - **Usage**: Profile settings, user management

- **SellerProfile** (`lib/features/sell/models.dart`)
  - **Fields**: id, companyName, gstNumber, address, city, state, pincode, phone, email, website, description, categories, materials, logoUrl, isVerified, createdAt, updatedAt
  - **Usage**: Seller pages, admin user management
  - **Relationships**: Referenced by `AdminUser`

- **AdminUser** (`lib/features/admin/models/admin_user.dart`)
  - **Fields**: id, name, email, phone, role, status, subscription, joinDate, lastActive, location, industry, materials, createdAt, plan, isSeller, sellerProfile
  - **Usage**: Admin user management
  - **Relationships**: References `SellerProfile`

#### 3. Business Models
- **Lead** (`lib/features/sell/models.dart`)
  - **Fields**: id, title, industry, materials, city, state, qty, turnoverCr, needBy, status, about
  - **Usage**: Leads pages, admin management

- **AdCampaign** (`lib/features/sell/models.dart`)
  - **Fields**: id, type, term, slot, productId, productTitle, productThumbnail
  - **Usage**: Ads creation and management

#### 4. Review Models
- **Review** (`lib/features/reviews/models.dart`)
  - **Fields**: id, productId, userId, authorDisplay, rating, title, body, images, createdAt, updatedAt, helpfulVotesByUser, reported, attributes
  - **Usage**: Reviews pages, product reviews
  - **Relationships**: Uses `ReviewImage`, `HelpfulVote`

- **ReviewImage** (`lib/features/reviews/models.dart`)
  - **Fields**: url, width, height
  - **Usage**: Review attachments

- **ReviewSummary** (`lib/features/reviews/models.dart`)
  - **Fields**: productId, average, totalCount, countsByStar
  - **Usage**: Product review statistics

#### 5. Messaging Models
- **Message** (`lib/features/messaging/models.dart`)
  - **Fields**: id, conversationId, senderType, senderName, text, sentAt, attachments, replyToMessageId, isSending
  - **Usage**: Messaging system
  - **Relationships**: Uses `Attachment`

- **Conversation** (`lib/features/messaging/models.dart`)
  - **Fields**: id, title, subtitle, isPinned, isSupport, messages
  - **Usage**: Messaging system
  - **Relationships**: Contains `List<Message>`

- **Attachment** (`lib/features/messaging/models.dart`)
  - **Fields**: id, name, type
  - **Usage**: Message attachments

#### 6. Location Models
- **ProductLocation** (`lib/features/sell/models.dart`)
  - **Fields**: latitude, longitude, city, state, area, pincode
  - **Usage**: Product location filtering, location-aware features

#### 7. State Information Models
- **PowerGenerator** (`lib/features/stateinfo/models/state_info_models.dart`)
  - **Fields**: id, name, type, capacity, location, logo, established, founder, ceo, ceoPhoto, headquarters, phone, email, website, description, totalPlants, employees, revenue, posts, productDesigns
  - **Usage**: State information system
  - **Relationships**: Contains `List<Post>`, `List<ProductDesign>`

- **Post** (`lib/features/stateinfo/models/state_info_models.dart`)
  - **Fields**: id, title, content, author, time, tags, imageUrl, imageUrls, pdfUrls
  - **Usage**: State information content

#### 8. Admin-Specific Models
- **KycDocument** (`lib/features/admin/models/kyc_models.dart`)
  - **Fields**: id, userId, type, fileName, fileUrl, thumbnailUrl, status, rejectionReason, reviewerId, reviewedAt, uploadedAt, expiresAt, extractedData, tags, fileSize, mimeType
  - **Usage**: KYC management

- **Category** (`lib/features/admin/models/product_models.dart`)
  - **Fields**: id, name, description, parentId, sortOrder, isActive, createdAt
  - **Usage**: Category management

## Model Relationships

### Well-Linked Models
✅ **AdminUser → SellerProfile**: Proper import and reference
✅ **PowerGenerator → Post**: Direct list relationship
✅ **PowerGenerator → ProductDesign**: Direct list relationship
✅ **Conversation → Message**: Direct list relationship
✅ **Message → Attachment**: Direct list relationship
✅ **Review → ReviewImage**: Direct list relationship
✅ **Product → ProductLocation**: Optional reference

### Shared Enums
✅ **ProductStatus**: Centralized in `lib/models/product_status.dart`
- Used by: sell models, admin models, product management service
- Values: draft, pending, active, inactive, archived

## Issues Found & Resolved

### 1. Duplicate ProductStatus Enums ✅ FIXED
**Problem**: Three different `ProductStatus` enums defined in:
- `lib/features/sell/models.dart`
- `lib/features/admin/models/product_models.dart`
- `lib/services/product_management_service.dart`

**Solution**: 
- Created shared enum in `lib/models/product_status.dart`
- Updated all references to use shared enum
- Added re-export in sell models for backward compatibility

### 2. Import Collision Risk ✅ ADDRESSED
**Problem**: Potential name collisions between admin and sell Product models
**Solution**: 
- Added import re-exports where needed
- Documented usage patterns to avoid conflicts
- Recommended import prefixes for files using both models

### 3. Missing Serialization Tests ✅ ADDED
**Problem**: No tests for model serialization/deserialization
**Solution**: 
- Created `test/models_serialization_test.dart`
- Added tests for ProductStatus, Product, UserProfile, Review
- Verified roundtrip serialization works correctly

## Usage Patterns

### High-Usage Models
1. **Product** (sell): 15+ files
2. **ProductStatus**: 13+ files
3. **Lead**: 10+ files
4. **SellerProfile**: 8+ files
5. **UserProfile**: 6+ files

### Model Distribution by Domain
- **Sell Domain**: 6 models (Product, SellerProfile, Lead, AdCampaign, ProductLocation, CustomFieldDef)
- **Admin Domain**: 15+ models (Product, AdminUser, KycDocument, Category, etc.)
- **Profile Domain**: 4 models (UserProfile, UserPreferences, PasswordChangeRequest, NotificationSettings)
- **Review Domain**: 5 models (Review, ReviewImage, ReviewSummary, HelpfulVote, ReviewListQuery)
- **Messaging Domain**: 4 models (Message, Conversation, Attachment, ReplyDraft)
- **State Info Domain**: 10+ models (PowerGenerator, Post, TransmissionLine, etc.)

## Recommendations

### 1. Model Organization
- ✅ **Completed**: Centralized shared enums
- **Consider**: Moving shared models to `lib/models/` directory
- **Consider**: Creating domain-specific model directories

### 2. Serialization
- ✅ **Completed**: Added basic serialization tests
- **Consider**: Adding more comprehensive serialization tests
- **Consider**: Adding validation for required fields

### 3. Documentation
- **Consider**: Adding model documentation comments
- **Consider**: Creating model relationship diagrams
- **Consider**: Adding field validation rules

### 4. Type Safety
- **Consider**: Adding more specific types (e.g., Email, PhoneNumber)
- **Consider**: Using sealed classes for status enums
- **Consider**: Adding model validation mixins

## Test Results

✅ **All serialization tests pass**:
- ProductStatus enum parsing
- Product model roundtrip serialization
- UserProfile model roundtrip serialization
- Review model roundtrip serialization

## Conclusion

The Vidyut app has a well-structured model architecture with clear domain separation. The main issues (duplicate enums, missing tests) have been resolved. The models are properly linked and follow good practices for serialization and relationships.

**Key Achievements**:
- ✅ Centralized ProductStatus enum
- ✅ Added comprehensive model usage mapping
- ✅ Created serialization tests
- ✅ Identified and documented model relationships
- ✅ Resolved import collision risks

The codebase is now more maintainable with clear model boundaries and proper shared dependencies.
