import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/provider_registry.dart';

// Simple test widget to verify providers work
class ProviderTestWidget extends ConsumerWidget {
  const ProviderTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final rbac = ref.watch(rbacProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session: ${session.isLoggedIn ? "Logged In" : "Not Logged In"}'),
            Text('Role: ${rbac.role}'),
            Text('Can admin.access: ${rbac.can('admin.access')}'),
            const SizedBox(height: 16),
            
            Text('Search Query: ${searchQuery.query}'),
            const SizedBox(height: 16),
            
            Text('Categories:'),
            categoriesAsync.when(
              loading: () => const Text('Loading categories...'),
              error: (error, stack) => Text('Error: $error'),
              data: (categories) => Text('Loaded ${categories.getRootCategories().length} categories'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                ref.read(searchQueryProvider.notifier).state = SearchQuery(
                  query: 'test query',
                  categories: ['wires'],
                  filters: {'price': '100-500'},
                );
              },
              child: const Text('Test Search Query'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                ref.invalidate(categoriesProvider);
              },
              child: const Text('Refresh Categories'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: ProviderTestWidget(),
      ),
    ),
  );
}

