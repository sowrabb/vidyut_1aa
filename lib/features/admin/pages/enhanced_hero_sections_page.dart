import 'package:flutter/material.dart';
import '../store/enhanced_admin_store.dart';
import '../models/hero_section.dart';
import '../../../services/enhanced_admin_api_service.dart';
import '../widgets/hero_section_card.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_banner.dart';

/// Enhanced hero sections management page with full CRUD and media management
class EnhancedHeroSectionsPage extends StatefulWidget {
  final EnhancedAdminStore adminStore;

  const EnhancedHeroSectionsPage({
    super.key,
    required this.adminStore,
  });

  @override
  State<EnhancedHeroSectionsPage> createState() =>
      _EnhancedHeroSectionsPageState();
}

class _EnhancedHeroSectionsPageState extends State<EnhancedHeroSectionsPage> {
  @override
  void initState() {
    super.initState();
    widget.adminStore.addListener(_onStoreChange);
  }

  @override
  void dispose() {
    widget.adminStore.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Sections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.adminStore.loadHeroSections(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reorder',
                child: ListTile(
                  leading: Icon(Icons.sort),
                  title: Text('Reorder Sections'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Slide Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Error Banner
          if (widget.adminStore.error != null)
            ErrorBanner(
              message: widget.adminStore.error!,
              onDismiss: () => widget.adminStore.clearError(),
            ),

          // Hero sections list
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => widget.adminStore.loadHeroSections(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.adminStore.heroSections.length,
                    itemBuilder: (context, index) {
                      final heroSection = widget.adminStore.heroSections[index];
                      return HeroSectionCard(
                        heroSection: heroSection,
                        onTap: () => _showHeroSectionDetails(heroSection),
                        onEdit: () => _showEditHeroSectionDialog(heroSection),
                        onDelete: () =>
                            _showDeleteHeroSectionDialog(heroSection),
                        onToggleActive: () =>
                            _toggleHeroSectionActive(heroSection),
                        onMoveUp: index > 0
                            ? () => _moveHeroSection(heroSection, -1)
                            : null,
                        onMoveDown:
                            index < widget.adminStore.heroSections.length - 1
                                ? () => _moveHeroSection(heroSection, 1)
                                : null,
                      );
                    },
                  ),
                ),

                // Loading Overlay
                if (widget.adminStore.isLoading) const LoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateHeroSectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'reorder':
        _showReorderDialog();
        break;
      case 'settings':
        _showSlideSettingsDialog();
        break;
    }
  }

  void _showCreateHeroSectionDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateHeroSectionDialog(
        adminStore: widget.adminStore,
        onHeroSectionCreated: () => setState(() {}),
      ),
    );
  }

  void _showEditHeroSectionDialog(HeroSection heroSection) {
    showDialog(
      context: context,
      builder: (context) => EditHeroSectionDialog(
        adminStore: widget.adminStore,
        heroSection: heroSection,
        onHeroSectionUpdated: () => setState(() {}),
      ),
    );
  }

  void _showDeleteHeroSectionDialog(HeroSection heroSection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hero Section'),
        content: Text(
            'Are you sure you want to delete "${heroSection.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await widget.adminStore.deleteHeroSection(heroSection.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Hero section deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to delete hero section: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHeroSectionDetails(HeroSection heroSection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(heroSection.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (heroSection.imageUrl != null &&
                  heroSection.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    heroSection.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('Subtitle', heroSection.subtitle),
              _buildDetailRow('CTA Text', heroSection.ctaText ?? 'None'),
              _buildDetailRow('CTA URL', heroSection.ctaUrl ?? 'None'),
              _buildDetailRow('Priority', heroSection.priority.toString()),
              _buildDetailRow(
                  'Status', heroSection.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Created', heroSection.createdAt.toString()),
              _buildDetailRow('Updated', heroSection.updatedAt.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditHeroSectionDialog(heroSection);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _toggleHeroSectionActive(HeroSection heroSection) async {
    try {
      await widget.adminStore.updateHeroSection(
        heroSection.id,
        UpdateHeroSectionRequest(isActive: !heroSection.isActive),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Hero section ${heroSection.isActive ? 'deactivated' : 'activated'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update hero section: $e')),
        );
      }
    }
  }

  Future<void> _moveHeroSection(HeroSection heroSection, int direction) async {
    try {
      final currentIndex = widget.adminStore.heroSections
          .indexWhere((h) => h.id == heroSection.id);
      final newIndex = currentIndex + direction;

      if (newIndex >= 0 && newIndex < widget.adminStore.heroSections.length) {
        final orderedIds =
            widget.adminStore.heroSections.map((h) => h.id).toList();
        final temp = orderedIds[currentIndex];
        orderedIds[currentIndex] = orderedIds[newIndex];
        orderedIds[newIndex] = temp;

        await widget.adminStore.reorderHeroSections(orderedIds);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hero section reordered')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reorder hero section: $e')),
        );
      }
    }
  }

  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (context) => ReorderHeroSectionsDialog(
        adminStore: widget.adminStore,
        onReordered: () => setState(() {}),
      ),
    );
  }

  void _showSlideSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SlideSettingsDialog(
        adminStore: widget.adminStore,
        onSettingsUpdated: () => setState(() {}),
      ),
    );
  }
}

// ================= Dialog Widgets =================

class CreateHeroSectionDialog extends StatefulWidget {
  final EnhancedAdminStore adminStore;
  final VoidCallback onHeroSectionCreated;

  const CreateHeroSectionDialog({
    super.key,
    required this.adminStore,
    required this.onHeroSectionCreated,
  });

  @override
  State<CreateHeroSectionDialog> createState() =>
      _CreateHeroSectionDialogState();
}

class _CreateHeroSectionDialogState extends State<CreateHeroSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _ctaTextController = TextEditingController();
  final _ctaUrlController = TextEditingController();
  final _priorityController = TextEditingController(text: '1');

  String _imageUrl = '';
  bool _isActive = true;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _ctaUrlController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Hero Section'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Subtitle is required' : null,
                ),
                const SizedBox(height: 16),
                ImageUploadWidget(
                  initialImageUrl: _imageUrl,
                  onImageChanged: (url) => _handleImageSelected(url ?? ''),
                  onImageUploaded: (url) => setState(() => _imageUrl = url),
                  isUploading: _isUploading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ctaTextController,
                  decoration: const InputDecoration(
                    labelText: 'CTA Text (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ctaUrlController,
                  decoration: const InputDecoration(
                    labelText: 'CTA URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Priority is required';
                    if (int.tryParse(value!) == null)
                      return 'Priority must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _createHeroSection,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _handleImageSelected(String imagePath) async {
    setState(() => _isUploading = true);
    try {
      final url = await widget.adminStore.uploadImage(imagePath);
      setState(() => _imageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _createHeroSection() {
    if (_formKey.currentState!.validate() && _imageUrl.isNotEmpty) {
      final request = CreateHeroSectionRequest(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        imageUrl: _imageUrl,
        ctaText:
            _ctaTextController.text.isEmpty ? null : _ctaTextController.text,
        ctaUrl: _ctaUrlController.text.isEmpty ? null : _ctaUrlController.text,
        priority: int.parse(_priorityController.text),
        isActive: _isActive,
      );

      widget.adminStore.createHeroSection(request);
      widget.onHeroSectionCreated();
      Navigator.of(context).pop();
    } else if (_imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
    }
  }
}

class EditHeroSectionDialog extends StatefulWidget {
  final EnhancedAdminStore adminStore;
  final HeroSection heroSection;
  final VoidCallback onHeroSectionUpdated;

  const EditHeroSectionDialog({
    super.key,
    required this.adminStore,
    required this.heroSection,
    required this.onHeroSectionUpdated,
  });

  @override
  State<EditHeroSectionDialog> createState() => _EditHeroSectionDialogState();
}

class _EditHeroSectionDialogState extends State<EditHeroSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaUrlController;
  late TextEditingController _priorityController;

  late String _imageUrl;
  late bool _isActive;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.heroSection.title);
    _subtitleController =
        TextEditingController(text: widget.heroSection.subtitle);
    _ctaTextController =
        TextEditingController(text: widget.heroSection.ctaText ?? '');
    _ctaUrlController =
        TextEditingController(text: widget.heroSection.ctaUrl ?? '');
    _priorityController =
        TextEditingController(text: widget.heroSection.priority.toString());
    _imageUrl = widget.heroSection.imageUrl ?? '';
    _isActive = widget.heroSection.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _ctaUrlController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.heroSection.title}'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Subtitle is required' : null,
                ),
                const SizedBox(height: 16),
                ImageUploadWidget(
                  initialImageUrl: _imageUrl,
                  onImageChanged: (url) => _handleImageSelected(url ?? ''),
                  onImageUploaded: (url) => setState(() => _imageUrl = url),
                  isUploading: _isUploading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ctaTextController,
                  decoration: const InputDecoration(
                    labelText: 'CTA Text (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ctaUrlController,
                  decoration: const InputDecoration(
                    labelText: 'CTA URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Priority is required';
                    if (int.tryParse(value!) == null)
                      return 'Priority must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _updateHeroSection,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _handleImageSelected(String imagePath) async {
    setState(() => _isUploading = true);
    try {
      final url = await widget.adminStore.uploadImage(imagePath);
      setState(() => _imageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _updateHeroSection() {
    if (_formKey.currentState!.validate()) {
      final request = UpdateHeroSectionRequest(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        imageUrl: _imageUrl,
        ctaText:
            _ctaTextController.text.isEmpty ? null : _ctaTextController.text,
        ctaUrl: _ctaUrlController.text.isEmpty ? null : _ctaUrlController.text,
        priority: int.parse(_priorityController.text),
        isActive: _isActive,
      );

      widget.adminStore.updateHeroSection(widget.heroSection.id, request);
      widget.onHeroSectionUpdated();
      Navigator.of(context).pop();
    }
  }
}

class ReorderHeroSectionsDialog extends StatelessWidget {
  final EnhancedAdminStore adminStore;
  final VoidCallback onReordered;

  const ReorderHeroSectionsDialog({
    super.key,
    required this.adminStore,
    required this.onReordered,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reorder Hero Sections'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: ReorderableListView.builder(
          itemCount: adminStore.heroSections.length,
          itemBuilder: (context, index) {
            final heroSection = adminStore.heroSections[index];
            return ListTile(
              key: ValueKey(heroSection.id),
              leading: const Icon(Icons.drag_handle),
              title: Text(heroSection.title),
              subtitle: Text('Priority: ${heroSection.priority}'),
              trailing: Icon(
                heroSection.isActive ? Icons.visibility : Icons.visibility_off,
                color: heroSection.isActive ? Colors.green : Colors.grey,
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            // Handle reordering logic
            onReordered();
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Apply reordering
            onReordered();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class SlideSettingsDialog extends StatefulWidget {
  final EnhancedAdminStore adminStore;
  final VoidCallback onSettingsUpdated;

  const SlideSettingsDialog({
    super.key,
    required this.adminStore,
    required this.onSettingsUpdated,
  });

  @override
  State<SlideSettingsDialog> createState() => _SlideSettingsDialogState();
}

class _SlideSettingsDialogState extends State<SlideSettingsDialog> {
  late int _firstSlideDuration;
  late int _otherSlidesDuration;

  @override
  void initState() {
    super.initState();
    _firstSlideDuration = widget.adminStore.firstSlideDurationSeconds;
    _otherSlidesDuration = widget.adminStore.otherSlidesDurationSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Slide Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('First slide duration: ${_firstSlideDuration}s'),
          Slider(
            value: _firstSlideDuration.toDouble(),
            min: 5,
            max: 30,
            divisions: 25,
            onChanged: (value) =>
                setState(() => _firstSlideDuration = value.round()),
          ),
          const SizedBox(height: 16),
          Text('Other slides duration: ${_otherSlidesDuration}s'),
          Slider(
            value: _otherSlidesDuration.toDouble(),
            min: 2,
            max: 15,
            divisions: 13,
            onChanged: (value) =>
                setState(() => _otherSlidesDuration = value.round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.adminStore.updateSlideDurations(
              firstSlideDuration: _firstSlideDuration,
              otherSlidesDuration: _otherSlidesDuration,
            );
            widget.onSettingsUpdated();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
