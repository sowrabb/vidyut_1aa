import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import 'state_info_bottom_sheet_editor.dart';

/// Post editor for creating and editing updates
class PostEditor extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final String? initialImageUrl;
  final List<String>? initialTags;
  final Function(
      String title, String content, String? imageUrl, List<String> tags) onSave;

  const PostEditor({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.initialImageUrl,
    this.initialTags,
    required this.onSave,
  });

  @override
  State<PostEditor> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late String? _imageUrl;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController =
        TextEditingController(text: widget.initialContent ?? '');
    _tagsController = TextEditingController();
    _imageUrl = widget.initialImageUrl;
    _tags = List.from(widget.initialTags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(
      _titleController.text,
      _contentController.text,
      _imageUrl,
      _tags,
    );
    Navigator.pop(context);
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

  void _selectImage() {
    // Pending: Implement image selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: const Text(
            'Image selection will be implemented with image picker.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StateInfoBottomSheetEditor(
      title: widget.initialTitle == null ? 'Create New Post' : 'Edit Post',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          Text(
            'Post Title',
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
            'Content',
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

          // Image section
          Text(
            'Image (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectImage,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.outlineSoft, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              child: _imageUrl != null && _imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 40, color: AppColors.outlineSoft),
                        SizedBox(height: 8),
                        Text('Tap to add image',
                            style: TextStyle(color: AppColors.outlineSoft)),
                      ],
                    ),
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
                  if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
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
}

/// Helper function to show post editor
void showPostEditor({
  required BuildContext context,
  String? initialTitle,
  String? initialContent,
  String? initialImageUrl,
  List<String>? initialTags,
  required Function(
          String title, String content, String? imageUrl, List<String> tags)
      onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PostEditor(
      initialTitle: initialTitle,
      initialContent: initialContent,
      initialImageUrl: initialImageUrl,
      initialTags: initialTags,
      onSave: onSave,
    ),
  );
}
