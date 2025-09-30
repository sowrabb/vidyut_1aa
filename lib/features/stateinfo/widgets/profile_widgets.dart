import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app/layout/adaptive.dart';
import '../../../app/tokens.dart';
import '../../../widgets/lightweight_image_widget.dart';
import '../models/state_info_models.dart';
import 'product_design_widgets.dart';
import 'leadership_editor.dart';
import 'statistics_editor.dart';
import 'enhanced_post_editor.dart';
import 'shared_media_components.dart';

// Company Profile View Widget
class CompanyProfileView extends StatefulWidget {
  final String companyName;
  final String companyType;
  final String capacity;
  final String location;
  final String logo;
  final String established;
  final String founder;
  final String leaderName;
  final String leaderTitle;
  final String leaderPhoto;
  final String headquarters;
  final String phone;
  final String email;
  final String website;
  final String description;
  final Map<String, String> statistics;
  final List<Post> posts;
  final List<ProductDesign> productDesigns;
  final String sectorType;
  final String sectorId;
  final bool isEditMode;

  const CompanyProfileView({
    super.key,
    required this.companyName,
    required this.companyType,
    required this.capacity,
    required this.location,
    required this.logo,
    required this.established,
    required this.founder,
    required this.leaderName,
    required this.leaderTitle,
    required this.leaderPhoto,
    required this.headquarters,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.statistics,
    required this.posts,
    this.productDesigns = const [],
    required this.sectorType,
    required this.sectorId,
    this.isEditMode = false,
  });

  @override
  State<CompanyProfileView> createState() => _CompanyProfileViewState();
}

class _CompanyProfileViewState extends State<CompanyProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Company Header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: _CompanyHeader(
            companyName: widget.companyName,
            companyType: widget.companyType,
            capacity: widget.capacity,
            location: widget.location,
            logo: widget.logo,
            established: widget.established,
          ),
        ),
        const SizedBox(height: 16),
        // Tab Bar
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Leadership'),
            Tab(text: 'Statistics'),
            Tab(text: 'Updates'),
            Tab(text: 'Product Design'),
          ],
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _CompanyOverviewTab(
                description: widget.description,
                founder: widget.founder,
                headquarters: widget.headquarters,
                phone: widget.phone,
                email: widget.email,
                website: widget.website,
              ),
              _CompanyLeadershipTab(
                leaderName: widget.leaderName,
                leaderTitle: widget.leaderTitle,
                leaderPhoto: widget.leaderPhoto,
                isEditMode: widget.isEditMode,
              ),
              _CompanyStatisticsTab(
                  statistics: widget.statistics, isEditMode: widget.isEditMode),
              _CompanyUpdatesTab(
                posts: widget.posts, 
                isEditMode: widget.isEditMode,
                sectorType: widget.sectorType,
                sectorId: widget.sectorId,
              ),
              ProductDesignTab(
                productDesigns: widget.productDesigns,
                sectorType: widget.sectorType,
                sectorId: widget.sectorId,
                isEditMode: widget.isEditMode,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Company Header Widget
class _CompanyHeader extends StatelessWidget {
  final String companyName;
  final String companyType;
  final String capacity;
  final String location;
  final String logo;
  final String established;

  const _CompanyHeader({
    required this.companyName,
    required this.companyType,
    required this.capacity,
    required this.location,
    required this.logo,
    required this.established,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(logo),
              backgroundColor: AppColors.surface,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    companyType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          capacity,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Established: $established',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Tab Content Widgets
class _CompanyOverviewTab extends StatelessWidget {
  final String description;
  final String founder;
  final String headquarters;
  final String phone;
  final String email;
  final String website;

  const _CompanyOverviewTab({
    required this.description,
    required this.founder,
    required this.headquarters,
    required this.phone,
    required this.email,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (founder.isNotEmpty) _InfoRow('Founder', founder),
                _InfoRow('Headquarters', headquarters),
                _InfoRow('Phone', phone),
                _InfoRow('Email', email),
                _InfoRow('Website', website),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyLeadershipTab extends StatelessWidget {
  final String leaderName;
  final String leaderTitle;
  final String leaderPhoto;
  final bool isEditMode;

  const _CompanyLeadershipTab({
    required this.leaderName,
    required this.leaderTitle,
    required this.leaderPhoto,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Leadership',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (isEditMode)
                      IconButton(
                        tooltip: 'Edit leadership',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showLeadershipEditor(
                            context: context,
                            leaderName: leaderName,
                            leaderTitle: leaderTitle,
                            leaderPhoto: leaderPhoto,
                            onSave: (name, title, photo) {
                              // Update the edit store
                              // Persist leadership changes via parent/store as needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Leadership updated: $name')),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(leaderPhoto),
                        backgroundColor: AppColors.surface,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        leaderName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leaderTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyStatisticsTab extends StatelessWidget {
  final Map<String, String> statistics;
  final bool isEditMode;

  const _CompanyStatisticsTab(
      {required this.statistics, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Key Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (isEditMode)
                      IconButton(
                        tooltip: 'Edit statistics',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showStatisticsEditor(
                            context: context,
                            statistics: statistics,
                            onSave: (newStats) {
                              // Update the edit store
                              // Persist statistics via parent/store as needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Statistics updated: ${newStats.length} items')),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: context.isDesktop ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: statistics.entries
                      .map(
                        (entry) => _StatisticCard(
                          label: entry.key,
                          value: entry.value,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyUpdatesTab extends StatefulWidget {
  final List<Post> posts;
  final bool isEditMode;
  final String sectorType;
  final String sectorId;

  const _CompanyUpdatesTab({
    required this.posts, 
    required this.isEditMode,
    required this.sectorType,
    required this.sectorId,
  });

  @override
  State<_CompanyUpdatesTab> createState() => _CompanyUpdatesTabState();
}

class _CompanyUpdatesTabState extends State<_CompanyUpdatesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedAuthor = 'All';
  List<String> _availableAuthors = ['All'];

  @override
  void initState() {
    super.initState();
    _updateAuthors();
  }

  void _updateAuthors() {
    final authors = widget.posts.map((post) => post.author).toSet().toList();
    authors.sort();
    _availableAuthors = ['All', ...authors];
  }

  List<Post> get _filteredPosts {
    return widget.posts.where((post) {
      final matchesSearch = _searchQuery.isEmpty ||
          post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesAuthor =
          _selectedAuthor == 'All' || post.author == _selectedAuthor;

      return matchesSearch && matchesAuthor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditMode) {
      return Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search updates...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAuthor,
                        decoration: InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: _availableAuthors.map((author) {
                          return DropdownMenuItem(
                            value: author,
                            child: Text(author),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAuthor = value ?? 'All';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Posts List
          Expanded(
            child: _filteredPosts.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final cross = width >= 1200 ? 1 : (width >= 768 ? 2 : 1);
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cross,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            return _FacebookPostCard(post: post);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search updates...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedAuthor,
                          decoration: InputDecoration(
                            labelText: 'Author',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: _availableAuthors.map((author) {
                            return DropdownMenuItem(
                              value: author,
                              child: Text(author),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAuthor = value ?? 'All';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Posts List
            Expanded(
              child: _filteredPosts.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final cross =
                            width >= 1200 ? 1 : (width >= 768 ? 2 : 1);
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cross,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = _filteredPosts[index];
                              return _FacebookPostCard(
                                post: post,
                                isEditMode: widget.isEditMode,
                                onEdit: widget.isEditMode ? () => _editPost(post) : null,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
            child: FloatingActionButton(
            onPressed: () {
              StateInfoPostEditor.show(
                context: context,
                entityId: widget.sectorId, // Use sectorId as entityId
                entityType: widget.sectorType, // Use sectorType as entityType
                author: 'Current User', // TODO: Get from auth context
                onSave: (post) {
                  // Persist new post via parent/store as needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New post created: ${post.title}')),
                  );
                },
              );
            },
            tooltip: 'Create new post',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No updates found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editPost(Post post) {
    showEnhancedPostEditor(
      context: context,
      initialPost: post,
      postId: post.id,
      author: post.author,
      onSave: (updatedPost) {
        // Persist updated post via parent/store as needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated: ${updatedPost.title}')),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Statistic Card Widget
class _StatisticCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatisticCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Posts List Widget
class PostsList extends StatelessWidget {
  final List<Post> posts;

  const PostsList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No updates available',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for company updates',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final cross = width >= 1200 ? 3 : (width >= 768 ? 2 : 1);
      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _FacebookPostCard(post: post);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      );
    });
  }
}

// Post Card Widget
// Removed legacy PostCard. Updates now uses _FacebookPostCard exclusively.

// _ActionButton no longer used in the simplified Updates card.

// Explicit FB-style card used in Updates
class _FacebookPostCard extends StatelessWidget {
  final Post post;
  final bool isEditMode;
  final VoidCallback? onEdit;
  
  const _FacebookPostCard({
    required this.post,
    this.isEditMode = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    void openBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child:
                            const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.author,
                                style: textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(post.time,
                                style: textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Display cover image from new media system
                  Builder(
                    builder: (context) {
                      final coverImage = post.getCoverImage();
                      if (coverImage != null) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    _PostImageZoomPage(imageUrl: coverImage.downloadUrl),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: LightweightImageWidget(
                                imagePath: coverImage.downloadUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 400,
                                cacheHeight: 300,
                                errorWidget: Container(
                                  color: AppColors.surface,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 48, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  if (post.title.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(post.title,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(post.content,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: openBottomSheet,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.author,
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(post.time,
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16)),
                    child: Text('Updates',
                        style: textTheme.bodySmall?.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w600)),
                  ),
                  if (isEditMode && onEdit != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                      tooltip: 'Edit Post',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
            Builder(
              builder: (context) {
                final coverImage = post.getCoverImage();
                if (coverImage != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  _PostImageZoomPage(imageUrl: coverImage.downloadUrl),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: LightweightImageWidget(
                            imagePath: coverImage.downloadUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                            cacheHeight: 300,
                            errorWidget: Container(
                              color: AppColors.surface,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported,
                                  size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (post.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Text(post.title,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(post.content,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              ),
            if (post.tags.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Text(
                  'Tags',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('#$tag',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostImageZoomPage extends StatelessWidget {
  final String imageUrl;

  const _PostImageZoomPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper Info Row Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
