import 'package:flutter/material.dart';
import '../../app/layout/adaptive.dart';
import '../../app/tokens.dart';

class StateInfoPage extends StatelessWidget {
  const StateInfoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State Info')),
      body: SafeArea(
        child: ContentClamp(
          child: GridView.count(
            crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _NavCard(
                title: 'Power Generation',
                subtitle: 'Transmission Lines • Discoms',
                icon: Icons.bolt_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const _PowerGenerationPage()),
                ),
              ),
              _NavCard(
                title: 'State Info',
                subtitle: 'States • Cities • Discoms',
                icon: Icons.map_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _StatesListPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _NavCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ])),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}

// Power Generation → Transmission Lines → Discoms
class _PowerGenerationPage extends StatelessWidget {
  const _PowerGenerationPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Power Generation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProgressChips(total: 3, active: 1),
          const SizedBox(height: 12),
          _NavCard(
            title: 'Transmission Lines',
            subtitle: 'EHV • HV • MV',
            icon: Icons.cable_outlined,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const _TransmissionLinesPage())),
          ),
        ],
      ),
    );
  }
}

class _TransmissionLinesPage extends StatelessWidget {
  const _TransmissionLinesPage();
  @override
  Widget build(BuildContext context) {
    final items = List.generate(10, (i) => 'Discom ${i + 1}');
    return Scaffold(
      appBar: AppBar(title: const Text('Transmission Lines')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProgressChips(total: 3, active: 2),
          const SizedBox(height: 12),
          Text('Discoms', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...items.map((d) => _NavCard(
                title: d,
                subtitle: 'Click to view details, posts, designs, products',
                icon: Icons.apartment_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _DiscomProfilePage(name: d))),
              )),
        ],
      ),
    );
  }
}

class _DiscomProfilePage extends StatefulWidget {
  final String name;
  const _DiscomProfilePage({required this.name});
  @override
  State<_DiscomProfilePage> createState() => _DiscomProfilePageState();
}

class _DiscomProfilePageState extends State<_DiscomProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        bottom: TabBar(controller: _tabs, isScrollable: true, tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Designs'),
          Tab(text: 'Product Images'),
          Tab(text: 'Profiles'),
        ]),
      ),
      body: Column(children: [
        const SizedBox(height: 8),
        const _ProgressChips(total: 3, active: 3),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(controller: _tabs, children: const [
            _PostsList(kind: 'all'),
            _PostsList(kind: 'design'),
            _PostsList(kind: 'images'),
            _PostsList(kind: 'profiles'),
          ]),
        ),
      ]),
    );
  }
}

class _PostsList extends StatelessWidget {
  final String kind;
  const _PostsList({required this.kind});
  @override
  Widget build(BuildContext context) {
    if (kind == 'images') {
      final images = List.generate(
          12, (i) => 'https://picsum.photos/seed/state$i/800/600');
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.sizeOf(context).width >= AppBreaks.desktop
              ? 4
              : (MediaQuery.sizeOf(context).width >= AppBreaks.tablet ? 3 : 2),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: images.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(images[i], fit: BoxFit.cover),
        ),
      );
    }

    final demo = List.generate(
        12,
        (i) => {
              'title':
                  '${kind[0].toUpperCase()}${kind.substring(1)} Post ${i + 1}',
              'by': 'Admin',
              'time': '2d ago',
              'content': 'Demo content for $kind post ${i + 1}.',
            });
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        if (kind == 'design' && i == 0) {
          return Column(children: [
            TextField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search designs, specs, PDFs...')),
            const SizedBox(height: 12),
            _PostCard(data: demo[i]),
          ]);
        }
        return _PostCard(data: demo[i]);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: demo.length,
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, String> data;
  const _PostCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(data['title']!,
                    style: Theme.of(context).textTheme.titleMedium)),
            Text(data['time']!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),
          Text(data['content']!),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: const [
            Chip(label: Text('Design')),
            Chip(label: Text('PDF'))
          ]),
        ]),
      ),
    );
  }
}

// States → State profile → tabs (All, Design, Product Images, City/Towns)
class _StatesListPage extends StatelessWidget {
  const _StatesListPage();
  @override
  Widget build(BuildContext context) {
    final states = const [
      'Andhra Pradesh',
      'Telangana',
      'Tamil Nadu',
      'Karnataka',
      'Maharashtra',
      'Gujarat',
      'Rajasthan',
      'Kerala',
      'Madhya Pradesh',
      'Uttar Pradesh',
      'Bihar',
      'Punjab'
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('States')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProgressChips(total: 3, active: 1),
          const SizedBox(height: 12),
          ...states.map((s) => _NavCard(
                title: s,
                subtitle: 'View profile, posts, cities & towns',
                icon: Icons.flag_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _StateProfilePage(state: s))),
              )),
        ],
      ),
    );
  }
}

class _StateProfilePage extends StatefulWidget {
  final String state;
  const _StateProfilePage({required this.state});
  @override
  State<_StateProfilePage> createState() => _StateProfilePageState();
}

class _StateProfilePageState extends State<_StateProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.state),
        bottom: TabBar(controller: _tabs, isScrollable: true, tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Designs'),
          Tab(text: 'Product Images'),
          Tab(text: 'Cities/Towns'),
        ]),
      ),
      body: Column(children: [
        const SizedBox(height: 8),
        const _ProgressChips(total: 3, active: 2),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(controller: _tabs, children: [
            const _PostsList(kind: 'all'),
            const _PostsList(kind: 'design'),
            const _PostsList(kind: 'images'),
            _CitiesList(state: widget.state),
          ]),
        ),
      ]),
    );
  }
}

class _CitiesList extends StatelessWidget {
  final String state;
  const _CitiesList({required this.state});
  @override
  Widget build(BuildContext context) {
    final cities = List.generate(12, (i) => 'City ${i + 1}');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _ProgressChips(total: 3, active: 3),
        const SizedBox(height: 12),
        ...cities.map((c) => _NavCard(
              title: c,
              subtitle: 'View Discoms in $c',
              icon: Icons.location_city_outlined,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const _TransmissionLinesPage())),
            )),
      ],
    );
  }
}

class _ProgressChips extends StatelessWidget {
  final int total;
  final int active; // 1-based
  const _ProgressChips({required this.total, required this.active});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final on = (i + 1) == active;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: on ? AppColors.primary : AppColors.outlineSoft,
            child: Text('${i + 1}',
                style: TextStyle(
                    color: on ? Colors.white : AppColors.textSecondary,
                    fontSize: 12)),
          ),
        );
      }),
    );
  }
}
