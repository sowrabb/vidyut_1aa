/// Integration test to verify admin category creation syncs to app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/app/unified_providers.dart';
import 'package:vidyut/app/unified_providers_extended.dart';
import 'package:vidyut/features/admin/store/admin_store.dart';
import 'package:vidyut/features/categories/categories_page.dart';

void main() {
  group('Category Sync: Admin → App', () {
    testWidgets('Admin creates category, appears in app immediately', (tester) async {
      // Create a ProviderContainer for the test
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Get the admin store and demo data service
      final adminStore = container.read(adminStoreProvider);
      final demoService = container.read(lightweightDemoDataServiceProvider);

      // Record initial category count
      final initialCount = demoService.allCategories.length;
      print('Initial categories: $initialCount');

      // Create a new category via admin
      final newCategory = AdminCategoryData(
        id: 'test_cat_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Category ${DateTime.now().second}',
        description: 'This is a test category created by integration test',
        imageUrl: 'https://picsum.photos/seed/test/400/300',
        productCount: 0,
        industries: ['Testing'],
        materials: ['Test Material'],
        isActive: true,
        priority: 999,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Creating category: ${newCategory.name}');
      await adminStore.addCategory(newCategory);

      // Verify it was added to demo service
      final newCount = demoService.allCategories.length;
      expect(newCount, equals(initialCount + 1), 
        reason: 'Category should be added to demo service');

      // Verify category is in the list
      final addedCategory = demoService.allCategories
          .firstWhere((c) => c.name == newCategory.name);
      expect(addedCategory.name, equals(newCategory.name));
      print('✅ Category added to demo service');

      // Now test that the categoriesProvider picks it up
      final categoriesAsync = container.read(categoriesProvider);
      
      await categoriesAsync.when(
        data: (categoryTree) {
          final categories = categoryTree.categories;
          print('Categories in provider: ${categories.length}');
          
          // Check if our new category is in the provider
          final foundInProvider = categories.any((c) => c.name == newCategory.name);
          expect(foundInProvider, isTrue, 
            reason: 'New category should be in categoriesProvider');
          print('✅ Category found in categoriesProvider');
        },
        loading: () {
          fail('Provider should not be loading');
        },
        error: (error, stack) {
          fail('Provider should not have error: $error');
        },
      );

      print('✅ TEST PASSED: Category sync works!');
    });

    testWidgets('Admin updates category, changes appear immediately', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final adminStore = container.read(adminStoreProvider);
      final demoService = container.read(lightweightDemoDataServiceProvider);

      // Create a category
      final category = AdminCategoryData(
        id: 'test_cat_update_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Original Name',
        description: 'Original description',
        imageUrl: 'https://picsum.photos/seed/orig/400/300',
        productCount: 0,
        industries: ['Testing'],
        materials: ['Test Material'],
        isActive: true,
        priority: 999,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await adminStore.addCategory(category);
      print('Created category: ${category.name}');

      // Update the category
      final updatedCategory = category.copyWith(
        name: 'Updated Name',
        description: 'Updated description',
      );

      await adminStore.updateCategory(updatedCategory);
      print('Updated category name to: ${updatedCategory.name}');

      // Verify update in demo service
      final found = demoService.allCategories
          .firstWhere((c) => c.name == updatedCategory.name);
      expect(found.name, equals('Updated Name'));
      print('✅ Update reflected in demo service');

      // Verify provider gets the update
      final categoriesAsync = container.read(categoriesProvider);
      await categoriesAsync.when(
        data: (categoryTree) {
          final foundInProvider = categoryTree.categories
              .any((c) => c.name == 'Updated Name');
          expect(foundInProvider, isTrue);
          print('✅ Update reflected in categoriesProvider');
        },
        loading: () => fail('Should not be loading'),
        error: (e, s) => fail('Should not error: $e'),
      );

      print('✅ TEST PASSED: Category update sync works!');
    });

    testWidgets('Admin deletes category, removed from app immediately', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final adminStore = container.read(adminStoreProvider);
      final demoService = container.read(lightweightDemoDataServiceProvider);

      // Create a category
      final category = AdminCategoryData(
        id: 'test_cat_delete_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Category To Delete',
        description: 'This will be deleted',
        imageUrl: 'https://picsum.photos/seed/delete/400/300',
        productCount: 0,
        industries: ['Testing'],
        materials: ['Test Material'],
        isActive: true,
        priority: 999,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await adminStore.addCategory(category);
      print('Created category: ${category.name}');

      final countBeforeDelete = demoService.allCategories.length;

      // Delete the category
      await adminStore.deleteCategory(category.id);
      print('Deleted category: ${category.name}');

      // Verify deletion in demo service
      final countAfterDelete = demoService.allCategories.length;
      expect(countAfterDelete, equals(countBeforeDelete - 1));
      print('✅ Deletion reflected in demo service');

      // Verify provider reflects deletion
      final categoriesAsync = container.read(categoriesProvider);
      await categoriesAsync.when(
        data: (categoryTree) {
          final stillExists = categoryTree.categories
              .any((c) => c.name == category.name);
          expect(stillExists, isFalse);
          print('✅ Deletion reflected in categoriesProvider');
        },
        loading: () => fail('Should not be loading'),
        error: (e, s) => fail('Should not error: $e'),
      );

      print('✅ TEST PASSED: Category deletion sync works!');
    });

    testWidgets('Multiple rapid changes sync correctly', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final adminStore = container.read(adminStoreProvider);
      final demoService = container.read(lightweightDemoDataServiceProvider);

      print('Testing rapid changes...');

      // Create 3 categories rapidly
      for (int i = 0; i < 3; i++) {
        final category = AdminCategoryData(
          id: 'rapid_$i',
          name: 'Rapid Category $i',
          description: 'Rapid test',
          imageUrl: 'https://picsum.photos/seed/rapid$i/400/300',
          productCount: 0,
          industries: ['Testing'],
          materials: ['Test'],
          isActive: true,
          priority: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await adminStore.addCategory(category);
      }

      print('Created 3 categories rapidly');

      // Verify all 3 are in demo service
      final rapidCategories = demoService.allCategories
          .where((c) => c.name.startsWith('Rapid Category'))
          .toList();
      expect(rapidCategories.length, equals(3));
      print('✅ All 3 categories in demo service');

      // Verify provider has all 3
      final categoriesAsync = container.read(categoriesProvider);
      await categoriesAsync.when(
        data: (categoryTree) {
          final rapidInProvider = categoryTree.categories
              .where((c) => c.name.startsWith('Rapid Category'))
              .toList();
          expect(rapidInProvider.length, equals(3));
          print('✅ All 3 categories in categoriesProvider');
        },
        loading: () => fail('Should not be loading'),
        error: (e, s) => fail('Should not error: $e'),
      );

      print('✅ TEST PASSED: Rapid changes sync correctly!');
    });
  });
}

