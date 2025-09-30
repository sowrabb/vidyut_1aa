import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import 'state_info_bottom_sheet_editor.dart';

/// Leadership editor with photo upload and details
class LeadershipEditor extends StatefulWidget {
  final String leaderName;
  final String leaderTitle;
  final String leaderPhoto;
  final Function(String name, String title, String photo) onSave;

  const LeadershipEditor({
    super.key,
    required this.leaderName,
    required this.leaderTitle,
    required this.leaderPhoto,
    required this.onSave,
  });

  @override
  State<LeadershipEditor> createState() => _LeadershipEditorState();
}

class _LeadershipEditorState extends State<LeadershipEditor> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late String _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.leaderName);
    _titleController = TextEditingController(text: widget.leaderTitle);
    _photoUrl = widget.leaderPhoto;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(_nameController.text, _titleController.text, _photoUrl);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return StateInfoBottomSheetEditor(
      title: 'Edit Leadership',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selectPhoto,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.outlineSoft, width: 2),
                      image: _photoUrl.isNotEmpty
                          ? DecorationImage(
                              image: AssetImage(_photoUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _photoUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 60, color: AppColors.outlineSoft)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _selectPhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Change Photo'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Name field
          Text(
            'Leader Name',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter leader name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Title field
          Text(
            'Position/Title',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Chief Executive Officer',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        _photoUrl.isNotEmpty ? AssetImage(_photoUrl) : null,
                    backgroundColor: AppColors.surface,
                    child: _photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Leader Name'
                        : _nameController.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _titleController.text.isEmpty
                        ? 'Position'
                        : _titleController.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onSave: _handleSave,
    );
  }

  void _selectPhoto() {
    // Pending: Implement photo selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Photo'),
        content: const Text(
            'Photo selection will be implemented with image picker.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show leadership editor
void showLeadershipEditor({
  required BuildContext context,
  required String leaderName,
  required String leaderTitle,
  required String leaderPhoto,
  required Function(String name, String title, String photo) onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => LeadershipEditor(
      leaderName: leaderName,
      leaderTitle: leaderTitle,
      leaderPhoto: leaderPhoto,
      onSave: onSave,
    ),
  );
}
