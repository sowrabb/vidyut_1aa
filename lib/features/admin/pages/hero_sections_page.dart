import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/admin_store.dart';
import '../models/hero_section.dart';
import 'hero_section_editor.dart';

class HeroSectionsPage extends StatefulWidget {
  const HeroSectionsPage({super.key});

  @override
  State<HeroSectionsPage> createState() => _HeroSectionsPageState();
}

class _HeroSectionsPageState extends State<HeroSectionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Sections Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          FilledButton.icon(
            onPressed: () => _showHeroSectionEditor(),
            icon: const Icon(Icons.add),
            label: const Text('Add Hero Section'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<AdminStore>(
        builder: (context, adminStore, child) {
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
        },
      ),
    );
  }

  void _showHeroSectionEditor({HeroSection? hero}) {
    showDialog(
      context: context,
      builder: (context) => HeroSectionEditor(
        hero: hero,
        onSave: (heroSection) {
          final adminStore = Provider.of<AdminStore>(context, listen: false);
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
              Provider.of<AdminStore>(context, listen: false).deleteHeroSection(hero.id);
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
                        Icon(Icons.touch_app, size: 16, color: Colors.blue),
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
