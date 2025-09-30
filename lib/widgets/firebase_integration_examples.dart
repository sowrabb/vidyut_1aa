// Example widgets showing Firebase integration with Riverpod
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/provider_registry.dart';
import 'error_handler_widget.dart';

/// Example: Products List with real-time updates
class ProductsListExample extends ConsumerWidget {
  const ProductsListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch products with filters
    final productsAsync = ref.watch(productsProvider({
      'category': 'electrical',
      'status': ProductStatus.active,
      'limit': 20,
    }));

    return AsyncErrorHandler(
      asyncValue: productsAsync,
      builder: (products) {
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.title),
              subtitle: Text(product.description),
              trailing: Text('\$${product.price}'),
              onTap: () {
                // Navigate to product detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailExample(productId: product.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Example: Product Detail with real-time updates
class ProductDetailExample extends ConsumerWidget {
  final String productId;

  const ProductDetailExample({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch single product
    final productAsync = ref.watch(productProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final reviewsSummaryAsync = ref.watch(reviewsSummaryProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: AsyncErrorHandler(
        asyncValue: productAsync,
        builder: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product info
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${product.price}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Reviews section
                Text(
                  'Reviews',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Reviews summary
                AsyncErrorHandler(
                  asyncValue: reviewsSummaryAsync,
                  builder: (summary) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${summary['averageRating']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                Text('${summary['totalReviews']} reviews'),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  for (int i = 5; i >= 1; i--)
                                    Row(
                                      children: [
                                        Text('$i'),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value:
                                                (summary['ratingDistribution']
                                                            [i] ??
                                                        0) /
                                                    (summary['totalReviews']
                                                        as int),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            '${summary['ratingDistribution'][i] ?? 0}'),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Reviews list
                AsyncErrorHandler(
                  asyncValue: reviewsAsync,
                  builder: (reviews) {
                    return Column(
                      children: reviews.map((review) {
                        return Card(
                          child: ListTile(
                            title: Text(review.authorDisplay),
                            subtitle: Text(review.body),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Example: User Profile with real-time updates
class UserProfileExample extends ConsumerWidget {
  const UserProfileExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current user profile
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final notificationsAsync = ref.watch(notificationServiceProvider);

    return AsyncErrorHandler(
      asyncValue: userProfileAsync,
      builder: (userProfile) {
        if (userProfile == null) {
          return const Center(child: Text('Please log in'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              // Notification badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Show notifications
                    },
                  ),
                  if (notificationsAsync.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationsAsync.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(userProfile.email),
                        if (userProfile.phone != null) Text(userProfile.phone!),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // User's products
                Text(
                  'My Products',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: UserProductsExample(userId: userProfile.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example: User's Products List
class UserProductsExample extends ConsumerWidget {
  final String userId;

  const UserProductsExample({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user's products
    final productsAsync = ref.watch(userProductsProvider(userId));

    return AsyncErrorHandler(
      asyncValue: productsAsync,
      builder: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text('No products found. Create your first product!'),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text('\$${product.price}'),
                onTap: () {
                  // Navigate to product detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailExample(productId: product.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Example: Search with Cloud Functions
class SearchExample extends ConsumerStatefulWidget {
  const SearchExample({super.key});

  @override
  ConsumerState<SearchExample> createState() => _SearchExampleState();
}

class _SearchExampleState extends ConsumerState<SearchExample> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch search results
    final searchResultsAsync = ref.watch(searchResultsProvider({
      'query': _searchQuery,
      'limit': 20,
    }));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
            },
          ),
        ],
      ),
      body: AsyncErrorHandler(
        asyncValue: searchResultsAsync,
        builder: (results) {
          final products = results['products'] as List<dynamic>? ?? [];

          if (products.isEmpty && _searchQuery.isNotEmpty) {
            return const Center(
              child: Text('No products found for your search'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product['title'] ?? ''),
                  subtitle: Text(product['description'] ?? ''),
                  trailing: Text('\$${product['price'] ?? 0}'),
                  onTap: () {
                    // Navigate to product detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailExample(
                          productId: product['id'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Example: Admin Dashboard with Analytics
class AdminDashboardExample extends ConsumerWidget {
  const AdminDashboardExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch analytics data
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics cards
            AsyncErrorHandler(
              asyncValue: analyticsAsync,
              builder: (analytics) {
                return Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.people, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                '${analytics['totalUsers'] ?? 0}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const Text('Total Users'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.inventory, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                '${analytics['totalProducts'] ?? 0}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const Text('Total Products'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Users list
            Text(
              'Users',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AsyncErrorHandler(
                asyncValue: allUsersAsync,
                builder: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: Chip(
                            label: Text(user.role),
                            backgroundColor: _getRoleColor(user.role),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
