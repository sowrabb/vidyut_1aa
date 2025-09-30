import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/layout/adaptive.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../models/state_info_models.dart';
import '../pages/comprehensive_state_info_page.dart';
import 'profile_widgets.dart';
import 'product_design_widgets.dart';
import 'shared_media_components.dart';

// States Selection Screen
class StatesSelectionScreen extends ConsumerWidget {
  const StatesSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(localStateInfoStoreProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: StateProgressIndicator(
            total: 3,
            current: store.stateFlowProgress,
          ),
        ),
        Expanded(
          child: store.indianStates.isEmpty
              ? _buildEmptyState(context, 'No states available')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: store.indianStates.length,
                  itemBuilder: (context, index) {
                    final state = store.indianStates[index];
                    return _StateCard(
                      state: state,
                      onTap: () => store.selectState(state.id),
                    );
                  },
                ),
        ),
        NavigationButtons(
          onBack: () => store.backToStateFlow(),
          onStartOver: () => store.resetToSelection(),
        ),
      ],
    );
  }
}

// State Detail Screen
class StateDetailScreen extends ConsumerStatefulWidget {
  const StateDetailScreen({super.key});

  @override
  ConsumerState<StateDetailScreen> createState() => _StateDetailScreenState();
}

class _StateDetailScreenState extends ConsumerState<StateDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(stateInfoStoreProvider);
    final state = store.selectedStateData;

    if (state == null) {
      return const Center(child: Text('State not found'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: StateProgressIndicator(
            total: 3,
            current: store.stateFlowProgress,
          ),
        ),
        // State Header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: _StateHeader(state: state),
        ),
        const SizedBox(height: 16),
        // Tab Bar
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Administration'),
            Tab(text: 'Energy Mix'),
            Tab(text: 'Districts/Mandals'),
            Tab(text: 'Updates'),
            Tab(text: 'Product Design'),
          ],
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _StateOverviewTab(state: state),
              _StateAdministrationTab(state: state),
              _StateEnergyMixTab(state: state),
              _StateDistrictsTab(state: state),
              _StateUpdatesTab(
                posts: state.posts,
                sectorType: 'state',
                sectorId: state.id,
              ),
              ProductDesignTab(
                productDesigns: state.productDesigns,
                sectorType: 'state',
                sectorId: state.id,
                isEditMode: false, // TODO: Pass from parent
              ),
            ],
          ),
        ),
        NavigationButtons(
          onBack: () => store.backToStateFlow(),
          onStartOver: () => store.resetToSelection(),
        ),
      ],
    );
  }
}

// Mandal Detail Screen
class MandalDetailScreen extends ConsumerStatefulWidget {
  const MandalDetailScreen({super.key});

  @override
  ConsumerState<MandalDetailScreen> createState() => _MandalDetailScreenState();
}

class _MandalDetailScreenState extends ConsumerState<MandalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(stateInfoStoreProvider);
    final mandal = store.selectedMandalData;
    final state = store.selectedStateData;

    if (mandal == null || state == null) {
      return const Center(child: Text('Mandal or State not found'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: StateProgressIndicator(
            total: 3,
            current: store.stateFlowProgress,
          ),
        ),
        // Mandal Header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: _MandalHeader(mandal: mandal, stateName: state.name),
        ),
        const SizedBox(height: 16),
        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Administration'),
            Tab(text: 'Local DISCOMs'),
          ],
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MandalOverviewTab(mandal: mandal),
              _MandalAdministrationTab(mandal: mandal),
              _MandalDiscomsTab(mandal: mandal),
            ],
          ),
        ),
        NavigationButtons(
          onBack: () => store.backToStateFlow(),
          onStartOver: () => store.resetToSelection(),
        ),
      ],
    );
  }
}

// State Card Widget
class _StateCard extends StatelessWidget {
  final IndianState state;
  final VoidCallback onTap;

  const _StateCard({
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Capital: ${state.capital}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  state.powerCapacity,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${state.discoms} DISCOMs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${state.mandals.length} Districts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// State Header Widget
class _StateHeader extends StatelessWidget {
  final IndianState state;

  const _StateHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(state.logo),
              backgroundColor: AppColors.surface,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Capital: ${state.capital}',
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
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.powerCapacity,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.discoms} DISCOMs',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Mandal Header Widget
class _MandalHeader extends StatelessWidget {
  final Mandal mandal;
  final String stateName;

  const _MandalHeader({required this.mandal, required this.stateName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_city,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mandal.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    stateName,
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
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mandal.population,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mandal.powerDemand,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Tab Content Widgets
class _StateOverviewTab extends StatelessWidget {
  final IndianState state;

  const _StateOverviewTab({required this.state});

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
                  'Quick Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _InfoRow('Capital', state.capital),
                _InfoRow('Power Capacity', state.powerCapacity),
                _InfoRow('Number of DISCOMs', state.discoms.toString()),
                _InfoRow('Website', state.website),
                _InfoRow('Helpline', state.helpline),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PostsList(posts: state.posts),
      ],
    );
  }
}

class _StateAdministrationTab extends StatelessWidget {
  final IndianState state;

  const _StateAdministrationTab({required this.state});

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
                  'Chief Minister',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(state.chiefMinisterPhoto),
                      backgroundColor: AppColors.surface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.chiefMinister,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Chief Minister',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
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
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Energy Minister',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(state.energyMinisterPhoto),
                      backgroundColor: AppColors.surface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.energyMinister,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Energy Minister',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
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
                _InfoRow('Address', state.address),
                _InfoRow('Email', state.email),
                _InfoRow('Website', state.website),
                _InfoRow('Helpline', state.helpline),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StateEnergyMixTab extends StatelessWidget {
  final IndianState state;

  const _StateEnergyMixTab({required this.state});

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
                  'Energy Mix Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _EnergyMixBar(
                    'Thermal', state.energyMix.thermal, Colors.orange),
                _EnergyMixBar('Hydro', state.energyMix.hydro, Colors.blue),
                _EnergyMixBar(
                    'Nuclear', state.energyMix.nuclear, Colors.purple),
                _EnergyMixBar(
                    'Renewable', state.energyMix.renewable, Colors.green),
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
                  'DISCOMs in ${state.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...state.discomsList.map((discom) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.business, size: 20),
                          const SizedBox(width: 8),
                          Text(discom),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StateDistrictsTab extends ConsumerWidget {
  final IndianState state;

  const _StateDistrictsTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(localStateInfoStoreProvider);

    return state.mandals.isEmpty
        ? _buildEmptyState(context, 'No districts/mandals available')
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: state.mandals.length,
            itemBuilder: (context, index) {
              final mandal = state.mandals[index];
              return _MandalCard(
                mandal: mandal,
                onTap: () => store.selectMandal(mandal.id),
              );
            },
          );
  }
}

class _MandalOverviewTab extends StatelessWidget {
  final Mandal mandal;

  const _MandalOverviewTab({required this.mandal});

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
                  'Demographics & Power',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _InfoRow('Population', mandal.population),
                _InfoRow('Power Demand', mandal.powerDemand),
                if (mandal.website != null)
                  _InfoRow('Website', mandal.website!),
                if (mandal.helpline != null)
                  _InfoRow('Helpline', mandal.helpline!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (mandal.posts != null) PostsList(posts: mandal.posts!),
      ],
    );
  }
}

class _StateUpdatesTab extends StatefulWidget {
  final List<Post> posts;
  final String sectorType;
  final String sectorId;

  const _StateUpdatesTab({
    required this.posts,
    required this.sectorType,
    required this.sectorId,
  });

  @override
  State<_StateUpdatesTab> createState() => _StateUpdatesTabState();
}

class _StateUpdatesTabState extends State<_StateUpdatesTab> {
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
          post.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesAuthor =
          _selectedAuthor == 'All' || post.author == _selectedAuthor;
      return matchesSearch && matchesAuthor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search and filter section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedAuthor,
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
              ],
            ),
            const SizedBox(height: 16),
            // Posts list
            if (_filteredPosts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No posts found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first post to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._filteredPosts.map((post) => _SimplePostCard(post: post)),
          ],
        ),
        // Floating action button for creating new post
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              StateInfoPostEditor.show(
                context: context,
                entityId: widget.sectorId,
                entityType: widget.sectorType,
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
}

class _SimplePostCard extends StatelessWidget {
  final Post post;

  const _SimplePostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    post.author.isNotEmpty ? post.author[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        post.time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags
                    .map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide(color: AppColors.border),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MandalAdministrationTab extends StatelessWidget {
  final Mandal mandal;

  const _MandalAdministrationTab({required this.mandal});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (mandal.divisionController != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Division Controller',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: mandal.controllerPhoto != null
                            ? AssetImage(mandal.controllerPhoto!)
                            : null,
                        backgroundColor: AppColors.surface,
                        child: mandal.controllerPhoto == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mandal.divisionController!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Division Controller',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
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
          ),
          const SizedBox(height: 16),
        ],
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
                if (mandal.administrator != null)
                  _InfoRow('Administrator', mandal.administrator!),
                if (mandal.officeAddress != null)
                  _InfoRow('Office Address', mandal.officeAddress!),
                if (mandal.phone != null) _InfoRow('Phone', mandal.phone!),
                if (mandal.email != null) _InfoRow('Email', mandal.email!),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MandalDiscomsTab extends StatelessWidget {
  final Mandal mandal;

  const _MandalDiscomsTab({required this.mandal});

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
                  'Local Distribution Companies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (mandal.discoms != null && mandal.discoms!.isNotEmpty) ...[
                  ...mandal.discoms!.map((discom) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.business, size: 20),
                            const SizedBox(width: 8),
                            Text(discom),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      )),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No DISCOMs information available'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper Widgets
class _MandalCard extends StatelessWidget {
  final Mandal mandal;
  final VoidCallback onTap;

  const _MandalCard({
    required this.mandal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mandal.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  mandal.population,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.flash_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      mandal.powerDemand,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (mandal.discoms != null)
                    Expanded(
                      child: Text(
                        '${mandal.discoms!.length} DISCOMs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            width: 100,
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

class _EnergyMixBar extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const _EnergyMixBar(this.label, this.percentage, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.outlineSoft,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper method for empty states
Widget _buildEmptyState(BuildContext context, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check back later or contact support',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
