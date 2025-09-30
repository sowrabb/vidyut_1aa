import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../../services/search_service.dart';
import '../../widgets/responsive_product_grid.dart';
import '../sell/product_detail_page.dart';
import '../sell/models.dart';
import 'search_history_page.dart';
import 'search_analytics_page.dart';

class ComprehensiveSearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const ComprehensiveSearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<ComprehensiveSearchPage> createState() =>
      _ComprehensiveSearchPageState();
}

class _ComprehensiveSearchPageState
    extends ConsumerState<ComprehensiveSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _showSuggestions = false;
  bool _showFilters = false;
  bool _showHistory = false;

  // Filter states
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedMaterials = {};
  final Set<String> _selectedBrands = {};
  double _minPrice = 0;
  double _maxPrice = 100000;
  String _sortBy = 'relevance';

  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _focusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });

    // Initialize search service with products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sellerStore = ref.read(sellerStoreProvider);
      final searchServiceAsync = ref.read(searchServiceProvider);
      searchServiceAsync.whenData((searchService) {
        searchService.initializeWithProducts(sellerStore.products);
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
    final searchServiceAsync = ref.watch(searchServiceProvider);

    return searchServiceAsync.when(
      data: (searchService) => _buildSearchPage(searchService),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text('Failed to load search service: ${error.toString()}'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(searchServiceProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPage(SearchService searchService) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSearchHistory(),
            icon: const Icon(Icons.history),
            tooltip: 'Search History',
          ),
          IconButton(
            onPressed: () => _showSearchAnalytics(),
            icon: const Icon(Icons.analytics),
            tooltip: 'Search Analytics',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: const Icon(Icons.tune),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Enhanced Features
          _buildEnhancedSearchBar(searchService),

          // Search Suggestions
          if (_showSuggestions && searchService.suggestions.isNotEmpty)
            _buildSuggestionsList(searchService),

          // Filters Panel
          if (_showFilters) _buildAdvancedFiltersPanel(),

          // Search History (when not searching)
          if (_showHistory && _searchController.text.isEmpty)
            _buildSearchHistory(searchService),

          // Search Results or Empty State
          Expanded(
            child: _buildSearchResults(searchService),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchBar(SearchService searchService) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Search Input
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search products, brands, categories...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                    ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () => _performSearch(_searchController.text),
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _showSuggestions = value.isNotEmpty;
                _showHistory = value.isEmpty;
              });
              if (value.isNotEmpty) {
                searchService.searchWithSuggestions(value);
              }
            },
            onSubmitted: (value) {
              _performSearch(value);
            },
          ),

          // Quick Filter Chips
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildQuickFilterChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Popular', _selectedCategories.contains('Popular')),
          _buildFilterChip('Recent', _selectedCategories.contains('Recent')),
          _buildFilterChip(
              'High Rated', _selectedCategories.contains('High Rated')),
          _buildFilterChip(
              'Best Price', _selectedCategories.contains('Best Price')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (value) {
          setState(() {
            if (selected) {
              _selectedCategories.remove(label);
            } else {
              _selectedCategories.add(label);
            }
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildSuggestionsList(SearchService searchService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Suggestions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchService.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = searchService.suggestions[index];
              return ListTile(
                leading: Icon(
                  _getSuggestionIcon(suggestion.type),
                  size: 20,
                ),
                title: Text(suggestion.text),
                subtitle: suggestion.category != null
                    ? Text(suggestion.category!,
                        style: Theme.of(context).textTheme.bodySmall)
                    : null,
                trailing: Text(
                  '${suggestion.popularity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                onTap: () {
                  _searchController.text = suggestion.text;
                  _performSearch(suggestion.text);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getSuggestionIcon(String type) {
    switch (type) {
      case 'history':
        return Icons.history;
      case 'query':
        return Icons.trending_up;
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

  Widget _buildAdvancedFiltersPanel() {
    final searchServiceAsync = ref.watch(searchServiceProvider);

    return searchServiceAsync.when(
      data: (searchService) => _buildFiltersPanel(searchService),
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        child: const Text('Error loading filters'),
      ),
    );
  }

  Widget _buildFiltersPanel(SearchService searchService) {
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
          Row(
            children: [
              Text(
                'Advanced Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories
          _buildFilterSection(
            'Categories',
            searchService.categories,
            _selectedCategories,
            (category) {
              setState(() {
                if (_selectedCategories.contains(category)) {
                  _selectedCategories.remove(category);
                } else {
                  _selectedCategories.add(category);
                }
              });
              _applyFilters();
            },
          ),

          // Materials
          _buildFilterSection(
            'Materials',
            searchService.allProducts
                .expand((p) => p.materials)
                .toSet()
                .toList(),
            _selectedMaterials,
            (material) {
              setState(() {
                if (_selectedMaterials.contains(material)) {
                  _selectedMaterials.remove(material);
                } else {
                  _selectedMaterials.add(material);
                }
              });
              _applyFilters();
            },
          ),

          // Brands
          _buildFilterSection(
            'Brands',
            searchService.brands,
            _selectedBrands,
            (brand) {
              setState(() {
                if (_selectedBrands.contains(brand)) {
                  _selectedBrands.remove(brand);
                } else {
                  _selectedBrands.add(brand);
                }
              });
              _applyFilters();
            },
          ),

          // Price Range
          _buildPriceRangeFilter(),

          // Sort Options
          _buildSortOptions(),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                    _applyFilters();
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

  Widget _buildFilterSection(
    String title,
    List<String> options,
    Set<String> selected,
    Function(String) onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.take(10).map((option) {
            return FilterChip(
              label: Text(option),
              selected: selected.contains(option),
              onSelected: (_) => onToggle(option),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
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
          onChangeEnd: (_) => _applyFilters(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSortOptions() {
    final sortOptions = {
      'relevance': 'Relevance',
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'name_asc': 'Name: A to Z',
      'name_desc': 'Name: Z to A',
      'rating': 'Rating: High to Low',
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
            _applyFilters();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchHistory(SearchService searchService) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => searchService.clearHistory(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchService.searchHistory.length,
              itemBuilder: (context, index) {
                final item = searchService.searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(item.query),
                  subtitle: Text(
                    '${item.resultCount} results • ${_formatDate(item.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    onPressed: () => searchService.removeHistoryItem(index),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                  onTap: () {
                    _searchController.text = item.query;
                    _performSearch(item.query);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchService searchService) {
    if (_searchController.text.isEmpty && !_showHistory) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoResultsState();
    }

    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_searchResults.length} results found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (_searchController.text.isNotEmpty)
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
          child: ResponsiveProductGrid(
            products: _searchResults.map((product) {
              return ProductCardData(
                productId: product.id,
                title: product.title,
                brand: product.brand,
                price: '₹${product.price.toStringAsFixed(0)}',
                subtitle: product.subtitle,
                imageUrl: 'https://picsum.photos/seed/${product.id}/800/600',
                phone: '9000000000',
                whatsappNumber: '9000000000',
                rating: product.rating,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                onCallPressed: () {
                  // Handle call action
                },
                onWhatsAppPressed: () {
                  // Handle WhatsApp action
                },
              );
            }).toList(),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _showHistory = true;
                _showSuggestions = false;
              });
            },
            icon: const Icon(Icons.history),
            label: const Text('View Search History'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _clearSearch,
                child: const Text('Clear Search'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _showFilters = true;
                  });
                },
                child: const Text('Adjust Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSuggestions = false;
      _showHistory = false;
    });

    final searchServiceAsync = ref.read(searchServiceProvider);

    searchServiceAsync.whenData((searchService) {
      // Apply filters and get results
      final results = searchService.filterProducts(
        query: query,
        categories: _selectedCategories.isNotEmpty
            ? _selectedCategories.toList()
            : null,
        materials:
            _selectedMaterials.isNotEmpty ? _selectedMaterials.toList() : null,
        brands: _selectedBrands.isNotEmpty ? _selectedBrands.toList() : null,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
      );

      // Add to search history
      searchService.addToHistory(query, results.length);

      // Track analytics
      searchService.trackSearch(query, results.length);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _applyFilters() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _showSuggestions = false;
      _showHistory = true;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedMaterials.clear();
      _selectedBrands.clear();
      _minPrice = 0;
      _maxPrice = 100000;
      _sortBy = 'relevance';
    });
    _applyFilters();
  }

  void _showSearchHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchHistoryPage(),
      ),
    );
  }

  void _showSearchAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchAnalyticsPage(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
