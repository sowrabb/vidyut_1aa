// Enhanced Product Design Editor with unified media upload system
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app/tokens.dart';
import '../models/state_info_models.dart';
import '../models/media_models.dart';
import 'media_uploader_widget.dart';
import 'state_info_bottom_sheet_editor.dart';

/// Enhanced Product Design Editor with unified media upload system
class EnhancedProductDesignEditor extends StatefulWidget {
  final ProductDesign? initialDesign;
  final String designId;
  final String author;
  final String sectorType;
  final String sectorId;
  final String stateId;
  final Function(ProductDesign) onSave;
  final String? title;

  const EnhancedProductDesignEditor({
    super.key,
    this.initialDesign,
    required this.designId,
    required this.author,
    required this.sectorType,
    required this.sectorId,
    required this.stateId,
    required this.onSave,
    this.title,
  });

  @override
  State<EnhancedProductDesignEditor> createState() => _EnhancedProductDesignEditorState();
}

class _EnhancedProductDesignEditorState extends State<EnhancedProductDesignEditor> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  late TextEditingController _guidelinesController;
  late TextEditingController _specificationsController;
  late List<String> _tags;
  late List<MediaItem> _mediaItems;
  bool _isActive = true;
  bool _isSaving = false;

  // Predefined categories for product designs
  static const List<String> _categories = [
    'Conductor',
    'Transmission Line',
    'Distribution Equipment',
    'Power Generation Equipment',
    'Control Systems',
    'Safety Equipment',
    'Measurement Devices',
    'Protection Equipment',
    'Switchgear',
    'Transformers',
    'Cables',
    'Insulators',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialDesign?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialDesign?.description ?? '');
    _categoryController = TextEditingController(text: widget.initialDesign?.category ?? '');
    _tagsController = TextEditingController();
    _guidelinesController = TextEditingController(text: widget.initialDesign?.guidelines ?? '');
    _specificationsController = TextEditingController(text: widget.initialDesign?.specifications ?? '');
    _tags = List.from(widget.initialDesign?.tags ?? []);
    _isActive = widget.initialDesign?.isActive ?? true;
    
    // Initialize media items from existing design or empty list
    if (widget.initialDesign != null) {
      _mediaItems = List.from(widget.initialDesign!.getAllMedia());
    } else {
      _mediaItems = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _guidelinesController.dispose();
    _specificationsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a description');
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a category');
      return;
    }

    // Validate media items
    final validationError = MediaConstraints.validateMediaList(_mediaItems);
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final design = ProductDesign(
        id: widget.initialDesign?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        stateId: widget.stateId,
        sectorId: widget.sectorId,
        sectorType: widget.sectorType,
        author: widget.author,
        uploadDate: widget.initialDesign?.uploadDate ?? DateTime.now().toIso8601String(),
        tags: _tags,
        // Keep legacy fields for backward compatibility
        files: MediaAdapter.toLegacyProductDesign(_mediaItems),
        thumbnailUrl: _mediaItems.where((m) => m.type == MediaType.image && m.isCover).firstOrNull?.downloadUrl,
        // New media system
        media: _mediaItems,
        isActive: _isActive,
        guidelines: _guidelinesController.text.trim().isEmpty ? null : _guidelinesController.text.trim(),
        specifications: _specificationsController.text.trim().isEmpty ? null : _specificationsController.text.trim(),
      );

      await widget.onSave(design);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save product design: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _onMediaChanged(List<MediaItem> mediaItems) {
    setState(() {
      _mediaItems = mediaItems;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StateInfoBottomSheetEditor(
      title: widget.title ?? (widget.initialDesign == null ? 'Create New Product Design' : 'Edit Product Design'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            Text(
              'Design Title *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter product design title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Category field
            Text(
              'Category *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categories.contains(_categoryController.text) ? _categoryController.text : null,
              decoration: const InputDecoration(
                hintText: 'Select or enter category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _categoryController.text = value;
                }
              },
              onTap: () {
                // Allow manual input
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                hintText: 'Or enter custom category',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 16),

            // Description field
            Text(
              'Description *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the product design...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Media uploader
            MediaUploaderWidget(
              initialMedia: _mediaItems,
              onMediaChanged: _onMediaChanged,
              postId: widget.designId,
              isEditMode: widget.initialDesign != null,
              maxImages: 15,
              maxPdfs: 10,
              maxTotalFiles: 20,
            ),

            const SizedBox(height: 16),

            // Guidelines field
            Text(
              'State-Specific Guidelines (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _guidelinesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter any state-specific guidelines...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Specifications field
            Text(
              'Technical Specifications (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _specificationsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter technical specifications...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Tags section
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Tags display
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                        ))
                    .toList(),
              ),

            const SizedBox(height: 16),

            // Active status
            Row(
              children: [
                Checkbox(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                ),
                const Text('Active (visible to users)'),
              ],
            ),

            const SizedBox(height: 16),

            // Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (_titleController.text.isNotEmpty)
                      Text(
                        _titleController.text,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    if (_categoryController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _categoryController.text,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                    if (_descriptionController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _descriptionController.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    
                    // Media preview
                    if (_mediaItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildMediaPreview(),
                    ],
                    
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 4,
                        children: _tags
                            .map((tag) => Chip(
                                  label: Text(tag,
                                      style: const TextStyle(fontSize: 12)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onSave: _handleSave,
    );
  }

  Widget _buildMediaPreview() {
    final images = _mediaItems.where((m) => m.type == MediaType.image).toList();
    final pdfs = _mediaItems.where((m) => m.type == MediaType.pdf).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) ...[
          Text(
            'Images (${images.length})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: image.isCover 
                        ? Border.all(color: Colors.green, width: 2)
                        : Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image.thumbnailUrl ?? image.downloadUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.border,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (pdfs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'PDFs (${pdfs.length})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: pdfs.map((pdf) => Chip(
              avatar: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
              label: Text(pdf.name, style: const TextStyle(fontSize: 12)),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

/// Helper function to show enhanced product design editor
void showEnhancedProductDesignEditor({
  required BuildContext context,
  ProductDesign? initialDesign,
  required String designId,
  required String author,
  required String sectorType,
  required String sectorId,
  required String stateId,
  required Function(ProductDesign) onSave,
  String? title,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EnhancedProductDesignEditor(
      initialDesign: initialDesign,
      designId: designId,
      author: author,
      sectorType: sectorType,
      sectorId: sectorId,
      stateId: stateId,
      onSave: onSave,
      title: title,
    ),
  );
}

