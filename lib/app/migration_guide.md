# Migration Guide: Unified State Management

This guide helps you migrate from the existing state management to the new unified Riverpod providers.

## Overview

The new unified state management system provides:
- Consistent state management across all features
- Role-based access control (RBAC)
- Centralized data providers
- Modern Riverpod patterns (v2)

## Key Changes

### 1. Provider Structure

**Before:**
```dart
// Mixed ChangeNotifierProvider and direct service calls
final adminStoreProvider = ChangeNotifierProvider<AdminStore>((ref) => AdminStore());
final sellerStoreProvider = ChangeNotifierProvider<SellerStore>((ref) => SellerStore());
```

**After:**
```dart
// Unified modern Riverpod providers
final sessionProvider = NotifierProvider<SessionStore, SessionState>(SessionStore.new);
final rbacProvider = NotifierProvider<RbacStore, RbacState>(RbacStore.new);
final categoriesProvider = AsyncNotifierProvider<CategoriesStore, CategoryTree>(CategoriesStore.new);
```

### 2. State Access Patterns

**Before:**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminStore = ref.watch(adminStoreProvider);
    final sellerStore = ref.watch(sellerStoreProvider);
    
    return Container();
  }
}
```

**After:**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final rbac = ref.watch(rbacProvider);
    final categories = ref.watch(categoriesProvider);
    
    // Check permissions
    final canEditProducts = rbac.can('products.write');
    
    return Container();
  }
}
```

### 3. Permission Checking

**Before:**
```dart
// Direct service calls or manual permission checks
final adminAuth = ref.read(adminAuthServiceProvider);
if (adminAuth.hasPermission('products.write')) {
  // Do something
}
```

**After:**
```dart
// Centralized RBAC
final rbac = ref.watch(rbacProvider);
if (rbac.can('products.write')) {
  // Do something
}
```

## Migration Steps

### Step 1: Update Imports

Replace existing provider imports with:
```dart
import '../app/provider_registry.dart';
```

### Step 2: Update Widget State Access

Replace direct store access with provider access:

```dart
// Before
final adminStore = ref.watch(adminStoreProvider);
final products = adminStore.products;

// After
final products = ref.watch(productsProvider({'category': 'electrical'}));
```

### Step 3: Update Permission Checks

Replace manual permission checks with RBAC provider:

```dart
// Before
final auth = ref.read(adminAuthServiceProvider);
if (auth.hasPermission('users.read')) {
  // Show admin features
}

// After
final rbac = ref.watch(rbacProvider);
if (rbac.can('users.read')) {
  // Show admin features
}
```

### Step 4: Update Data Mutations

Replace direct store method calls with provider actions:

```dart
// Before
final store = ref.read(adminStoreProvider);
await store.updateProduct(productId, updates);

// After
final store = ref.read(productDetailProvider(productId).notifier);
// Use provider methods for mutations
```

## Provider Mapping

### Auth & Session
- `firebaseAuthServiceProvider` → `sessionProvider`
- `adminAuthServiceProvider` → `rbacProvider`

### Data Access
- `demoDataServiceProvider` → `lightweightDemoDataServiceProvider`
- `categoriesStoreProvider` → `categoriesProvider`
- `messagingStoreProvider` → `threadsProvider`, `threadMessagesProvider`

### Admin Features
- `adminStoreProvider` → Various admin providers (KYC, notifications, etc.)
- `enhancedAdminStoreProvider` → Admin-specific providers

## Common Patterns

### Loading States
```dart
final categories = ref.watch(categoriesProvider);
categories.when(
  data: (data) => CategoriesList(categories: data.categories),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

### Permission-Based UI
```dart
final rbac = ref.watch(rbacProvider);
if (rbac.can('products.write')) {
  return EditProductButton();
}
```

### Data Invalidation
```dart
// After updating data, invalidate related providers
ref.invalidate(productsProvider);
ref.invalidate(categoriesProvider);
```

## Testing

### Provider Overrides
```dart
testWidgets('should show admin features for admin user', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith((ref) => SessionState(
          isLoggedIn: true,
          role: 'admin',
          // ... other properties
        )),
      ],
      child: MyApp(),
    ),
  );
});
```

### Mock Providers
```dart
final mockCategoriesProvider = Provider<List<CategoryData>>((ref) => [
  CategoryData(name: 'Test Category', ...),
]);
```

## Troubleshooting

### Common Issues

1. **Provider not found**: Make sure to import `provider_registry.dart`
2. **Permission denied**: Check RBAC provider setup and user role
3. **State not updating**: Ensure you're using `ref.watch()` for reactive updates
4. **Async state errors**: Use `AsyncValue.when()` to handle loading/error states

### Debug Tips

```dart
// Debug provider state
final rbac = ref.watch(rbacProvider);
print('Current role: ${rbac.role}');
print('Can edit products: ${rbac.can('products.write')}');
```

## Migration Checklist

- [ ] Update imports to use `provider_registry.dart`
- [ ] Replace direct store access with provider access
- [ ] Update permission checks to use `rbacProvider`
- [ ] Handle loading/error states with `AsyncValue.when()`
- [ ] Update tests to use provider overrides
- [ ] Remove old provider dependencies
- [ ] Test all user flows (buyer, seller, admin)

## Support

For questions or issues during migration, refer to:
- The wiring plan documentation
- Existing provider implementations
- Riverpod documentation
- Team code review process

