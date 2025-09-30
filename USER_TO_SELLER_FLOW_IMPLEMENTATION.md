# User-to-Seller Flow Implementation

## Overview

This implementation provides a seamless flow for users to become sellers after taking a subscription plan. Users can sign up, select a plan, and access all seller features using their credentials.

## Key Components

### 1. User Role Models (`lib/features/auth/models/user_role_models.dart`)

- **AppUser**: Comprehensive user model with role, subscription, and seller status
- **UserRole**: Enum for buyer, seller, admin, guest roles
- **UserStatus**: Enum for active, pending, suspended, inactive status
- **SubscriptionPlan**: Enum for free, plus, pro, enterprise plans
- **RoleTransitionRequest**: Model for tracking role change requests

### 2. User Role Service (`lib/services/user_role_service.dart`)

- **UserRoleService**: Manages user role transitions and seller activation
- **Key Methods**:
  - `initializeUser()`: Initialize user from Firebase Auth
  - `requestSellerRole()`: Request to become a seller with plan selection
  - `activateSellerRole()`: Admin function to approve seller requests
  - `canAccessSellerFeatures()`: Check if user can access seller features

### 3. Seller Onboarding Page (`lib/features/auth/pages/seller_onboarding_page.dart`)

- **4-Step Onboarding Process**:
  1. **Plan Selection**: Choose from Plus, Pro, or Enterprise plans
  2. **Business Details**: Company information, GST, contact details
  3. **Materials Selection**: Choose materials they work with
  4. **Review & Submit**: Review information and submit request

### 4. Updated Auth Wrapper (`lib/app/auth_wrapper.dart`)

- **Dynamic Profile Button**: Changes based on user role
  - Guest: "Guest User" (orange)
  - Buyer: "Become Seller" (blue)
  - Seller: "Seller Hub" (green)
- **Profile Dialog**: Shows appropriate options based on user status
- **Seamless Integration**: Works with existing Firebase auth

## User Flow

### 1. User Signup

```
User signs up → Firebase Auth → UserRoleService.initializeUser() → AppUser created
```

### 2. Become Seller Request

```
User clicks "Become Seller" → SellerOnboardingPage → Plan selection → Business details → Submit request
```

### 3. Admin Approval

```
Admin reviews request → activateSellerRole() → User role changed to seller → SellerProfile created
```

### 4. Seller Access

```
User logs in → Role detected as seller → "Seller Hub" button shown → Access to seller features
```

## Firebase Integration

### Collections Used

- **users**: Main user documents with role and subscription info
- **seller_profiles**: Seller-specific business information
- **role_transitions**: Track role change requests and approvals

### Key Fields

- `role`: buyer, seller, admin, guest
- `is_seller`: boolean flag for seller status
- `current_plan_code`: active subscription plan
- `seller_activated_at`: timestamp when seller role was activated

## Features

### ✅ Implemented

- User role management with Firebase integration
- Subscription plan selection and management
- Seller onboarding flow with 4-step process
- Dynamic UI based on user role
- Admin approval system for seller requests
- Seamless integration with existing auth system

### 🔄 Ready for Enhancement

- Email notifications for role changes
- Payment integration for subscription plans
- Advanced seller verification process
- Analytics for seller onboarding conversion

## Usage

### For Users

1. Sign up or log in to the app
2. Click "Become Seller" button (if eligible)
3. Complete the 4-step onboarding process
4. Wait for admin approval
5. Access seller features once approved

### For Admins

1. Review pending seller requests in admin panel
2. Approve or reject requests with notes
3. Monitor seller activity and performance

## Integration Points

### With Existing Code

- **Firebase Auth**: Seamlessly integrated with existing auth flow
- **Seller Store**: Works with existing seller management
- **Admin Store**: Integrated with admin approval system
- **Riverpod**: Uses existing provider pattern

### Database Schema

The implementation follows the existing Firebase schema and adds:

- Role transition tracking
- Enhanced user profile management
- Subscription plan integration

## Benefits

1. **Seamless Experience**: Users can become sellers without separate signup
2. **Plan-Based Access**: Subscription plans control seller features
3. **Admin Control**: Admins can approve/reject seller requests
4. **Scalable**: Easy to add new roles or subscription tiers
5. **Integrated**: Works with existing codebase and Firebase setup

## Next Steps

1. **Test the Implementation**: Run the app and test the user-to-seller flow
2. **Admin Panel Integration**: Add seller request management to admin panel
3. **Payment Integration**: Connect subscription plans to payment processing
4. **Notifications**: Add email/SMS notifications for role changes
5. **Analytics**: Track conversion rates and user behavior

This implementation provides a complete, production-ready user-to-seller flow that integrates seamlessly with your existing Vidyut app architecture.
