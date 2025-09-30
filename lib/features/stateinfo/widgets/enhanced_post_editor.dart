// Enhanced Post Editor with unified media upload system
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app/tokens.dart';
import '../models/state_info_models.dart';
import '../models/media_models.dart';
import 'media_uploader_widget.dart';
import 'state_info_bottom_sheet_editor.dart';

/// Enhanced Post Editor with unified media upload system
class EnhancedPostEditor extends StatefulWidget {
  final Post? initialPost;
  final String postId;
  final String author;
  final Function(Post) onSave;
  final String? title;

  const EnhancedPostEditor({
    super.key,
    this.initialPost,
    required this.postId,
    required this.author,
    required this.onSave,
    this.title,
  });

  @override
  State<EnhancedPostEditor> createState() => _EnhancedPostEditorState();
}

class _EnhancedPostEditorState extends State<EnhancedPostEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late List<String> _tags;
  late List<MediaItem> _mediaItems;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialPost?.title ?? '');
    _contentController = TextEditingController(text: widget.initialPost?.content ?? '');
    _tagsController = TextEditingController();
    _tags = List.from(widget.initialPost?.tags ?? []);
    
    // Initialize media items from existing post or empty list
    if (widget.initialPost != null) {
      _mediaItems = List.from(widget.initialPost!.getAllMedia());
    } else {
      _mediaItems = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
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

    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter content');
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
      final post = Post(
        id: widget.initialPost?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        author: widget.author,
        time: widget.initialPost?.time ?? DateTime.now().toString(),
        tags: _tags,
        // Keep legacy fields for backward compatibility
        imageUrl: _mediaItems.where((m) => m.type == MediaType.image && m.isCover).firstOrNull?.downloadUrl,
        imageUrls: _mediaItems.where((m) => m.type == MediaType.image).map((m) => m.downloadUrl).toList(),
        pdfUrls: _mediaItems.where((m) => m.type == MediaType.pdf).map((m) => m.downloadUrl).toList(),
        // New media system
        media: _mediaItems,
      );

      await widget.onSave(post);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save post: $e');
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
      title: widget.title ?? (widget.initialPost == null ? 'Create New Post' : 'Edit Post'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          Text(
            'Post Title *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Enter post title',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Content field
          Text(
            'Content *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write your post content here...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 16),

          // Media uploader
          MediaUploaderWidget(
            initialMedia: _mediaItems,
            onMediaChanged: _onMediaChanged,
            postId: widget.postId,
            isEditMode: widget.initialPost != null,
            maxImages: 10,
            maxPdfs: 5,
            maxTotalFiles: 15,
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
                  if (_contentController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _contentController.text,
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

/// Helper function to show enhanced post editor
void showEnhancedPostEditor({
  required BuildContext context,
  Post? initialPost,
  required String postId,
  required String author,
  required Function(Post) onSave,
  String? title,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EnhancedPostEditor(
      initialPost: initialPost,
      postId: postId,
      author: author,
      onSave: onSave,
      title: title,
    ),
  );
}

