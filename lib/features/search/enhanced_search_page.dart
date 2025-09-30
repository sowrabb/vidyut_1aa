import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../../services/search_service.dart';
import '../../services/location_service.dart';
import '../sell/product_detail_page.dart';
import '../sell/models.dart';

class EnhancedSearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const EnhancedSearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<EnhancedSearchPage> createState() => _EnhancedSearchPageState();
}

class _EnhancedSearchPageState extends ConsumerState<EnhancedSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _showSuggestions = false;
  bool _showFilters = false;
  String _selectedCategory = 'All';
  double _minPrice = 0;
  double _maxPrice = 50000;
  double _radius = 25;
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchService = ref.watch(searchServiceProvider);
    final locationService = ref.watch(locationServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(searchService),

          // Filters Panel
          if (_showFilters) _buildFiltersPanel(),

          // Search Results
          Expanded(
            child: _buildSearchResults(searchService, locationService),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AsyncValue<SearchService> searchService) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search products, brands, categories...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        searchService.whenData(
                            (service) => service.searchWithSuggestions(''));
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (value) {
              searchService
                  .whenData((service) => service.searchWithSuggestions(value));
              setState(() {});
            },
            onSubmitted: (value) {
              _performSearch(value);
            },
          ),

          // Search Suggestions
          searchService.when(
            data: (service) {
              if (_showSuggestions && service.suggestions.isNotEmpty) {
                return _buildSuggestions(service);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(SearchService searchService) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: searchService.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = searchService.suggestions[index];
          return ListTile(
            leading: Icon(_getSuggestionIcon(suggestion.type)),
            title: Text(suggestion.text),
            subtitle:
                suggestion.category != null ? Text(suggestion.category!) : null,
            onTap: () {
              _searchController.text = suggestion.text;
              _performSearch(suggestion.text);
            },
          );
        },
      ),
    );
  }

  IconData _getSuggestionIcon(String type) {
    switch (type) {
      case 'query':
        return Icons.history;
      case 'product':
        return Icons.inventory;
      case 'category':
        return Icons.category;
      case 'brand':
        return Icons.business;
      default:
        return Icons.search;
    }
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Category Filter
          _buildCategoryFilter(),
          const SizedBox(height: 16),

          // Price Range Filter
          _buildPriceRangeFilter(),
          const SizedBox(height: 16),

          // Radius Filter
          _buildRadiusFilter(),
          const SizedBox(height: 16),

          // Sort Filter
          _buildSortFilter(),
          const SizedBox(height: 16),

          // Apply Filters Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                    _performSearch(_searchController.text);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Wires & Cables',
      'Circuit Breakers',
      'Lights',
      'Motors',
      'Tools'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range: ₹${_minPrice.toInt()} - ₹${_maxPrice.toInt()}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 100000,
          divisions: 100,
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRadiusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Radius: ${_radius.toInt()} km',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _radius,
          min: 5,
          max: 100,
          divisions: 19,
          onChanged: (value) {
            setState(() {
              _radius = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    final sortOptions = {
      'relevance': 'Relevance',
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'distance': 'Distance',
      'newest': 'Newest First',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sortBy,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: sortOptions.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _sortBy = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(AsyncValue<SearchService> searchService,
      AsyncValue<LocationService> locationService) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    // In a real implementation, you would get actual search results
    // For now, we'll show a placeholder
    return _buildSearchResultsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for products',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a product name, brand, or category to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    // Mock search results - in real implementation, this would come from a service
    final mockProducts = [
      Product(
        id: '1',
        title: 'Copper Wire 2.5mm',
        brand: 'Finolex',
        price: 150.0,
        images: ['https://example.com/wire1.jpg'],
        materials: ['Copper'],
        subtitle: 'Electrical Wire',
        category: 'Wires & Cables',
      ),
      Product(
        id: '2',
        title: 'MCB 32A',
        brand: 'Schneider',
        price: 850.0,
        images: ['https://example.com/mcb1.jpg'],
        materials: ['Plastic', 'Metal'],
        subtitle: 'Circuit Breaker',
        category: 'Circuit Breakers',
      ),
    ];

    return Column(
      children: [
        // Search Results Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mockProducts.length} results found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: const Icon(Icons.tune),
                label: const Text('Filters'),
              ),
            ],
          ),
        ),

        // Results Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: mockProducts.length,
            itemBuilder: (context, index) {
              final product = mockProducts[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            image: product.images.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(product.images.first),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: product.images.isEmpty
                              ? const Icon(Icons.image, size: 50)
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.brand,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
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
        ),
      ],
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    // Mock search service - in real implementation, this would call the actual service
    // final searchService = ref.read(searchServiceProvider);
    // searchService.addToHistory(query, 0); // Mock result count

    setState(() {
      _showSuggestions = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _minPrice = 0;
      _maxPrice = 50000;
      _radius = 25;
      _sortBy = 'relevance';
    });
  }
}
