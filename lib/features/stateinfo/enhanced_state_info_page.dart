import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/tokens.dart';
import '../../../app/breakpoints.dart';
import '../../../app/layout/adaptive.dart';
import 'store/lightweight_state_info_store.dart';
import 'models/state_info_models.dart';
import 'data/static_data.dart';
import 'widgets/responsive_layout.dart';
import '../../../app/provider_registry.dart';

/// Enhanced State Info Flow with proper routing and tab bars
class EnhancedStateInfoPage extends ConsumerWidget {
  const EnhancedStateInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the provider is initialized
    ref.watch(lightweightStateInfoStoreProvider);
    return const _StateInfoRouter();
  }
}

/// Router widget that handles navigation between different screens
class _StateInfoRouter extends ConsumerWidget {
  const _StateInfoRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(lightweightStateInfoStoreProvider);
    return Navigator(
      key: store.navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) => _generateRoute(context, store, settings),
    );
  }

  Route<dynamic> _generateRoute(BuildContext context,
      LightweightStateInfoStore store, RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const _SelectionScreen(),
          settings: settings,
        );
      case '/power-flow':
        return MaterialPageRoute(
          builder: (_) => _PowerFlowScreen(store: store),
          settings: settings,
        );
      case '/state-flow':
        return MaterialPageRoute(
          builder: (_) => _StateFlowScreen(store: store),
          settings: settings,
        );
      case '/generator-profile':
        return MaterialPageRoute(
          builder: (_) => _GeneratorProfileScreen(store: store),
          settings: settings,
        );
      case '/state-profile':
        return MaterialPageRoute(
          builder: (_) => _StateProfileScreen(store: store),
          settings: settings,
        );
      case '/mandal-profile':
        return MaterialPageRoute(
          builder: (_) => _MandalProfileScreen(store: store),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const _SelectionScreen(),
          settings: settings,
        );
    }
  }
}

/// Selection Screen with proper routing
class _SelectionScreen extends ConsumerWidget {
  const _SelectionScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(lightweightStateInfoStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Electricity Board Info'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveLayout.getContentMargin(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                _HeaderSection(),
                SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),

                // Flow Selection Cards
                _EnhancedFlowCard(
                  title: 'Power Generation Flow',
                  subtitle: 'Follow the complete electricity journey',
                  description: 'Generator → Transmission → Distribution',
                  icon: Icons.bolt,
                  color: Colors.orange,
                  features: const [
                    'Explore power generators (NTPC, NHPC, etc.)',
                    'Understand transmission infrastructure',
                    'Learn about distribution companies',
                  ],
                  onTap: () => store.selectPath(MainPath.powerFlow),
                ),
                SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.5),
                _EnhancedFlowCard(
                  title: 'State-Based Flow',
                  subtitle: 'Explore by geographic regions',
                  description: 'State → Districts → Mandals',
                  icon: Icons.map,
                  color: Colors.blue,
                  features: const [
                    'Browse states and their energy profiles',
                    'Discover district-wise information',
                    'Explore mandal-level details',
                  ],
                  onTap: () => store.selectPath(MainPath.stateFlow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Power Flow Screen with proper routing
class _PowerFlowScreen extends StatelessWidget {
  final LightweightStateInfoStore store;

  const _PowerFlowScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Generation Flow'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => store.goBack(),
        ),
      ),
      body: const _GeneratorScreen(),
    );
  }
}

/// State Flow Screen with proper routing
class _StateFlowScreen extends StatelessWidget {
  final LightweightStateInfoStore store;

  const _StateFlowScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State-Based Flow'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => store.goBack(),
        ),
      ),
      body: const _StatesScreen(),
    );
  }
}

/// Generator Profile Screen with customer-facing seller profile layout
class _GeneratorProfileScreen extends StatefulWidget {
  final LightweightStateInfoStore store;

  const _GeneratorProfileScreen({required this.store});

  @override
  State<_GeneratorProfileScreen> createState() =>
      _GeneratorProfileScreenState();
}

class _GeneratorProfileScreenState extends State<_GeneratorProfileScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generator = widget.store.selectedGeneratorData;

    if (generator == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Generator Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => widget.store.goBack(),
          ),
        ),
        body: const Center(child: Text('Generator not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.store.goBack(),
        ),
      ),
      body: SafeArea(
        child: ContentClamp(
          child: NestedScrollView(
            headerSliverBuilder: (c, inner) => [
              SliverToBoxAdapter(child: _masthead(context, generator)),
              SliverAppBar(
                pinned: true,
                toolbarHeight: 56,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                backgroundColor: AppColors.surface,
                title: _tabsOnly(context),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _overviewTab(context, generator),
                _companyTab(context, generator),
                _performanceTab(context, generator),
                _contactTab(context, generator),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _masthead(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    final isPhone = MediaQuery.of(context).size.width < AppBreakpoints.tablet;
    const double logoSize = 112;

    final contactMeta = [
      _Meta(generator.location),
      _Meta('Type: ${generator.type}'),
      if (generator.phone.isNotEmpty)
        _ClickableMetaIcon(
          Icons.call,
          generator.phone,
          onTap: () => _launchPhone(generator.phone),
        ),
      if (generator.email.isNotEmpty)
        _ClickableMetaIcon(
          Icons.email_outlined,
          generator.email,
          onTap: () => _launchEmail(generator.email),
        ),
    ];

    final statsMeta = [
      _Badge('${generator.totalPlants} Plants'),
      const _Meta('★ 4.8 (150)'),
      _Meta('${generator.employees} Employees'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: !isPhone
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.bolt,
                          color: Colors.orange, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(generator.name, style: t.headlineSmall),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: contactMeta),
                          const SizedBox(height: 6),
                          Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () => _launchPhone(generator.phone),
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Generator'),
                  ),
                  if (generator.website.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => _launchWebsite(generator.website),
                      icon: const Icon(Icons.web),
                      label: const Text('Visit Website'),
                    ),
                ]),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.bolt, color: Colors.orange, size: 36),
                ),
                const SizedBox(height: 12),
                Text(generator.name, style: t.headlineSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 12, runSpacing: 6, children: contactMeta),
                const SizedBox(height: 6),
                Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () => _launchPhone(generator.phone),
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Generator'),
                  ),
                  if (generator.website.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => _launchWebsite(generator.website),
                      icon: const Icon(Icons.web),
                      label: const Text('Visit Website'),
                    ),
                ]),
              ],
            ),
    );
  }

  Widget _tabsOnly(BuildContext context) {
    return TabBar(
      controller: _tabs,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Company'),
        Tab(text: 'Performance'),
        Tab(text: 'Contact'),
      ],
    );
  }

  Widget _overviewTab(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Overview', style: t.titleLarge),
        const SizedBox(height: 16),
        _statsGrid(context, generator),
      ],
    );
  }

  Widget _companyTab(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Company Information', style: t.titleLarge),
        const SizedBox(height: 16),
        _companyInfo(context, generator),
      ],
    );
  }

  Widget _performanceTab(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Performance Metrics', style: t.titleLarge),
        const SizedBox(height: 16),
        _performanceMetrics(context, generator),
      ],
    );
  }

  Widget _contactTab(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Contact Information', style: t.titleLarge),
        const SizedBox(height: 16),
        _contactInfo(context, generator),
      ],
    );
  }

  Widget _statsGrid(BuildContext context, PowerGenerator generator) {
    final items = [
      _Stat('Type', generator.type, Icons.bolt),
      _Stat('Capacity', generator.capacity, Icons.power),
      _Stat('Location', generator.location, Icons.location_on),
      _Stat('Total Plants', '${generator.totalPlants}', Icons.business),
      _Stat('Employees', generator.employees, Icons.people),
      _Stat('Established', generator.established, Icons.calendar_today),
      _Stat('CEO', generator.ceo, Icons.person),
      _Stat('Headquarters', generator.headquarters, Icons.location_city),
    ];
    final cross = MediaQuery.of(context).size.width >= AppBreakpoints.desktop
        ? 3
        : (MediaQuery.of(context).size.width >= AppBreakpoints.tablet ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.6,
      ),
      itemBuilder: (_, i) => items[i],
    );
  }

  Widget _companyInfo(BuildContext context, PowerGenerator generator) {
    return Column(
      children: [
        _InfoCard('Company Name', generator.name),
        _InfoCard('CEO', generator.ceo),
        _InfoCard('Headquarters', generator.headquarters),
        _InfoCard('Established', generator.established),
        _InfoCard('Founder', generator.founder),
        _InfoCard('Total Plants', '${generator.totalPlants}'),
        _InfoCard('Employees', generator.employees),
      ],
    );
  }

  Widget _performanceMetrics(BuildContext context, PowerGenerator generator) {
    return Column(
      children: [
        _InfoCard('Power Capacity', generator.capacity),
        _InfoCard('Generation Type', generator.type),
        _InfoCard('Location', generator.location),
        _InfoCard('Operational Plants', '${generator.totalPlants}'),
      ],
    );
  }

  Widget _contactInfo(BuildContext context, PowerGenerator generator) {
    return Column(
      children: [
        if (generator.website.isNotEmpty)
          _ContactItem(
            icon: Icons.web,
            label: 'Website',
            value: generator.website,
            onTap: () => _launchWebsite(generator.website),
          ),
        if (generator.phone.isNotEmpty)
          _ContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: generator.phone,
            onTap: () => _launchPhone(generator.phone),
          ),
        if (generator.email.isNotEmpty)
          _ContactItem(
            icon: Icons.email,
            label: 'Email',
            value: generator.email,
            onTap: () => _launchEmail(generator.email),
          ),
        _ContactItem(
          icon: Icons.location_city,
          label: 'Headquarters',
          value: generator.headquarters,
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }
}

/// State Profile Screen with seller-style layout
class _StateProfileScreen extends StatelessWidget {
  final LightweightStateInfoStore store;

  const _StateProfileScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    final state = store.selectedStateData;

    if (state == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('State Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => store.goBack(),
          ),
        ),
        body: const Center(child: Text('State not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => store.goBack(),
        ),
      ),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section - exactly like seller profile
                Text(
                  state.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Indian State - ${state.capital}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Basic Information Section
                const _SectionHeader(
                  title: 'Basic Information',
                  icon: Ionicons.information_circle_outline,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.capital,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Capital',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.powerCapacity,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Power Capacity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.discoms.toString(),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Number of DISCOMs',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Contact Information Section
                const _SectionHeader(
                  title: 'Contact Information',
                  icon: Ionicons.call_outline,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.website,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.helpline,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Helpline',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // Administration Section
                const _SectionHeader(
                  title: 'Administration',
                  icon: Ionicons.business_outline,
                ),
                const SizedBox(height: 16),
                ResponsiveRow(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: state.chiefMinister,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Chief Minister',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: state.energyMinister,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Energy Minister',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.address,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // Energy Mix Section
                const _SectionHeader(
                  title: 'Energy Mix',
                  icon: Ionicons.flash_outline,
                ),
                const SizedBox(height: 16),
                ResponsiveRow(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '${state.energyMix.thermal}%',
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Thermal',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${state.energyMix.hydro}%',
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Hydro',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ResponsiveRow(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '${state.energyMix.nuclear}%',
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Nuclear',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${state.energyMix.renewable}%',
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Renewable',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // DISCOMs Section
                const _SectionHeader(
                  title: 'Distribution Companies',
                  icon: Ionicons.business_outline,
                ),
                const SizedBox(height: 16),
                ...state.discomsList.map((discom) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        initialValue: discom,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'DISCOM',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business, size: 16),
                        ),
                      ),
                    )),
                const SizedBox(height: 32),

                // Districts Section
                const _SectionHeader(
                  title: 'Districts/Mandals',
                  icon: Ionicons.location_outline,
                ),
                const SizedBox(height: 16),
                ...state.mandals.map((mandal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        initialValue:
                            '${mandal.name} - ${mandal.population} • ${mandal.powerDemand}',
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'District/Mandal',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city, size: 16),
                          suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                        onTap: () => store.navigateToMandalProfile(mandal.id),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mandal Profile Screen with seller-style layout
class _MandalProfileScreen extends StatelessWidget {
  final LightweightStateInfoStore store;

  const _MandalProfileScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    final mandal = store.selectedMandalData;

    if (mandal == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mandal Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => store.goBack(),
          ),
        ),
        body: const Center(child: Text('Mandal not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandal Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => store.goBack(),
        ),
      ),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section - exactly like seller profile
                Text(
                  mandal.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'District/Mandal Information',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Basic Information Section
                const _SectionHeader(
                  title: 'Basic Information',
                  icon: Ionicons.information_circle_outline,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mandal.population,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Population',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mandal.powerDemand,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Power Demand',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Demographics Section
                const _SectionHeader(
                  title: 'Demographics',
                  icon: Ionicons.people_outline,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mandal.population,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Total Population',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mandal.powerDemand,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Power Demand',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Power Information Section
                const _SectionHeader(
                  title: 'Power Information',
                  icon: Ionicons.flash_outline,
                ),
                const SizedBox(height: 16),
                ResponsiveRow(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: mandal.powerDemand,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Power Demand',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: mandal.population,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Population',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced Generator Screen with proper navigation
class _GeneratorScreen extends ConsumerWidget {
  const _GeneratorScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(lightweightStateInfoStoreProvider);

    return Column(
      children: [
        // Header Section
        const _ScreenHeader(
          title: 'Power Generators',
          subtitle: 'Explore India\'s major power generation companies',
          icon: Icons.bolt,
          color: Colors.orange,
        ),

        // Generators Grid
        Expanded(
          child: ResponsiveContainer(
            child: GridView.builder(
              padding: ResponsiveLayout.getScreenPadding(context),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getGridColumns(context),
                crossAxisSpacing: ResponsiveLayout.getSpacing(context),
                mainAxisSpacing: ResponsiveLayout.getSpacing(context),
                childAspectRatio: _getCardAspectRatio(context),
              ),
              itemCount: StateInfoStaticData.powerGenerators.length,
              itemBuilder: (context, index) {
                final generator = StateInfoStaticData.powerGenerators[index];
                return _GeneratorCard(
                  generator: generator,
                  onTap: () => store.navigateToGeneratorProfile(generator.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Enhanced States Screen with proper navigation
class _StatesScreen extends ConsumerWidget {
  const _StatesScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(lightweightStateInfoStoreProvider);

    return Column(
      children: [
        // Header Section
        const _ScreenHeader(
          title: 'Select a State',
          subtitle: 'Choose a state to explore its electricity infrastructure',
          icon: Icons.flag,
          color: Colors.blue,
        ),

        // States Grid
        Expanded(
          child: ResponsiveContainer(
            child: GridView.builder(
              padding: ResponsiveLayout.getScreenPadding(context),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getGridColumns(context),
                crossAxisSpacing: ResponsiveLayout.getSpacing(context),
                mainAxisSpacing: ResponsiveLayout.getSpacing(context),
                childAspectRatio: _getCardAspectRatio(context),
              ),
              itemCount: StateInfoStaticData.indianStates.length,
              itemBuilder: (context, index) {
                final state = StateInfoStaticData.indianStates[index];
                return _StateCard(
                  state: state,
                  onTap: () => store.navigateToStateProfile(state.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// UI Components
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.tablet;
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          ),
          child: Icon(
            Icons.electrical_services,
            size: isMobile ? 36 : (isDesktop ? 56 : 48),
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          'Choose Information Flow',
          style: TextStyle(
            fontSize: isMobile ? 22 : (isDesktop ? 32 : 28),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          'Select how you want to explore India\'s electricity infrastructure',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EnhancedFlowCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final VoidCallback onTap;

  const _EnhancedFlowCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.tablet;
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

    return Card(
      elevation: isMobile ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isMobile ? 24 : 32,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : (isDesktop ? 22 : 20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: isMobile ? 12 : 16,
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Flow Description
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: color,
                      size: isMobile ? 16 : 20,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Features List
              Text(
                'What you\'ll explore:',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: isMobile ? 6 : 8),
                          width: isMobile ? 4 : 6,
                          height: isMobile ? 4 : 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.tablet;
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Icon(
              icon,
              size: isMobile ? 24 : (isDesktop ? 40 : 32),
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : (isDesktop ? 28 : 24),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  final PowerGenerator generator;
  final VoidCallback onTap;

  const _GeneratorCard({
    required this.generator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.tablet;

    return Card(
      elevation: isMobile ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Generator Icon and Name
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                    ),
                    child: Icon(
                      Icons.bolt,
                      color: Colors.orange,
                      size: isMobile ? 16 : 20,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      generator.name,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: isMobile ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 8 : 12),

              // Type Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: _getTypeColor(generator.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  generator.type,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: _getTypeColor(generator.type),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 6 : 8),

              // Capacity Info
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  generator.capacity,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),

              const Spacer(),

              // Location Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      generator.location,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isMobile ? 10 : 12,
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'thermal':
        return Colors.orange;
      case 'hydro':
        return Colors.blue;
      case 'nuclear':
        return Colors.purple;
      case 'renewable':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _StateCard extends StatelessWidget {
  final IndianState state;
  final VoidCallback onTap;

  const _StateCard({
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.tablet;

    return Card(
      elevation: isMobile ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // State Icon and Name
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: Colors.blue,
                      size: isMobile ? 16 : 20,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      state.name,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: isMobile ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 8 : 12),

              // Capital Info
              Text(
                'Capital: ${state.capital}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: isMobile ? 6 : 8),

              // Power Capacity Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  state.powerCapacity,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),

              const Spacer(),

              // DISCOMs Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.discoms} DISCOMs',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isMobile ? 10 : 12,
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

// Helper methods for responsive grid configuration
int _getGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < AppBreakpoints.tablet) {
    return 1; // Mobile: single column
  } else if (width < AppBreakpoints.desktop) {
    return 2; // Tablet: 2 columns
  } else if (width < AppBreakpoints.wide) {
    return 3; // Desktop: 3 columns
  } else {
    return 4; // Wide desktop: 4 columns
  }
}

double _getCardAspectRatio(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < AppBreakpoints.tablet) {
    return 1.4; // Mobile: taller cards
  } else if (width < AppBreakpoints.desktop) {
    return 1.2; // Tablet: medium aspect ratio
  } else if (width < AppBreakpoints.wide) {
    return 1.1; // Desktop: slightly wider cards
  } else {
    return 1.0; // Wide desktop: square cards
  }
}

/// Section header component (exact copy from seller profile)
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Responsive row component (exact copy from seller profile)
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.tablet;

    if (isMobile) {
      return Column(
        children: children
            .expand((child) => [child, SizedBox(height: spacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    } else {
      return Row(
        children: children
            .expand((child) => [child, SizedBox(width: spacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }
  }
}

// Helper components for customer-facing profile layout
class _Meta extends StatelessWidget {
  final String text;
  const _Meta(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodySmall);
}

class _ClickableMetaIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _ClickableMetaIcon(this.icon, this.text, {required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Chip(label: Text(text));
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value)
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        subtitle: Text(value),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }
}
