import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import '../models/hero_section.dart';
import 'hero_section_editor.dart';
import '../../../app/provider_registry.dart';

class HeroSectionsPage extends ConsumerStatefulWidget {
  const HeroSectionsPage({super.key});

  @override
  ConsumerState<HeroSectionsPage> createState() => _HeroSectionsPageState();
}

class _HeroSectionsPageState extends ConsumerState<HeroSectionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Sections Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          OutlinedButton.icon(
            onPressed: _openRotationPreview,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Preview Rotation'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showHeroSectionEditor(),
            icon: const Icon(Icons.add),
            label: const Text('Add Hero Section'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer(builder: (context, ref, child) {
        final adminStore = ref.watch(adminStoreProvider);
        if (!adminStore.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final heroSections = adminStore.heroSections;

        if (heroSections.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.slideshow, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hero sections yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first hero section to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: heroSections.length,
          onReorder: (oldIndex, newIndex) {
            final List<HeroSection> reordered = List.from(heroSections);
            if (newIndex > oldIndex) newIndex--;
            final HeroSection item = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, item);

            final List<String> orderedIds = reordered.map((h) => h.id).toList();
            adminStore.reorderHeroSections(orderedIds);
          },
          itemBuilder: (context, index) {
            final hero = heroSections[index];
            return _HeroSectionCard(
              key: ValueKey(hero.id),
              hero: hero,
              onEdit: () => _showHeroSectionEditor(hero: hero),
              onToggle: () => adminStore.toggleHeroSectionActive(hero.id),
              onDelete: () => _confirmDelete(hero),
            );
          },
        );
      }),
    );
  }

  void _openRotationPreview() {
    showDialog(
      context: context,
      builder: (_) => const _HeroRotationPreview(),
    );
  }

  void _showHeroSectionEditor({HeroSection? hero}) {
    showDialog(
      context: context,
      builder: (context) => HeroSectionEditor(
        hero: hero,
        onSave: (heroSection) {
          final adminStore = ref.read(adminStoreProvider);
          if (hero != null) {
            adminStore.updateHeroSection(heroSection);
          } else {
            adminStore.addHeroSection(heroSection);
          }
        },
      ),
    );
  }

  void _confirmDelete(HeroSection hero) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hero Section'),
        content: Text('Are you sure you want to delete "${hero.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(adminStoreProvider).deleteHeroSection(hero.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _HeroSectionCard extends StatelessWidget {
  final HeroSection hero;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _HeroSectionCard({
    super.key,
    required this.hero,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Drag handle
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 12),

            // Priority indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: hero.isActive ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  hero.priority.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hero.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!hero.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero.subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (hero.ctaText != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.touch_app,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'CTA: ${hero.ctaText}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    hero.isActive ? Icons.visibility : Icons.visibility_off,
                    color: hero.isActive ? Colors.green : Colors.grey,
                  ),
                  tooltip: hero.isActive ? 'Hide' : 'Show',
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroRotationPreview extends StatefulWidget {
  const _HeroRotationPreview();
  @override
  State<_HeroRotationPreview> createState() => _HeroRotationPreviewState();
}

class _HeroRotationPreviewState extends State<_HeroRotationPreview> {
  late final PageController _controller;
  int _index = 0;
  late final List<HeroSection> _active;
  late final Ticker _ticker;
  Duration _acc = Duration.zero;

  @override
  void initState() {
    super.initState();
    final store = ProviderScope.containerOf(context, listen: false)
        .read(adminStoreProvider);
    _active = store.heroSections.where((h) => h.isActive).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    _controller = PageController();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration d) {
    setState(() {
      _acc += d;
      // First slide 5s, others 3s
      final dur =
          _index == 0 ? const Duration(seconds: 5) : const Duration(seconds: 3);
      if (_acc >= dur) {
        _acc = Duration.zero;
        _index = (_index + 1) % (_active.isEmpty ? 1 : _active.length);
        if (_active.isNotEmpty) {
          _controller.animateToPage(
            _index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 800,
        height: 450,
        child: _active.isEmpty
            ? const Center(child: Text('No active hero sections'))
            : Stack(children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _active.length,
                  itemBuilder: (context, i) {
                    final h = _active[i];
                    return Stack(fit: StackFit.expand, children: [
                      if ((h.imagePath ?? '').isNotEmpty)
                        Image.asset(h.imagePath!, fit: BoxFit.cover)
                      else if ((h.imageUrl ?? '').isNotEmpty)
                        Image.network(h.imageUrl!, fit: BoxFit.cover)
                      else
                        Container(color: Colors.black12),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(h.subtitle,
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ]);
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ]),
      ),
    );
  }
}
