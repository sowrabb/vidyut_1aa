import 'package:flutter/material.dart';
import '../../../app/tokens.dart';

/// Comprehensive bottom sheet editor for State Info sections
class StateInfoBottomSheetEditor extends StatefulWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const StateInfoBottomSheetEditor({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.onSave,
    this.onCancel,
  });

  @override
  State<StateInfoBottomSheetEditor> createState() =>
      _StateInfoBottomSheetEditorState();
}

class _StateInfoBottomSheetEditorState
    extends State<StateInfoBottomSheetEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.outlineSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    widget.onCancel?.call();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: widget.content,
            ),
          ),

          // Actions
          if (widget.actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.outlineSoft),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: widget.onSave,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper function to show the bottom sheet editor
void showStateInfoEditor({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const [],
  VoidCallback? onSave,
  VoidCallback? onCancel,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StateInfoBottomSheetEditor(
      title: title,
      content: content,
      actions: actions,
      onSave: onSave,
      onCancel: onCancel,
    ),
  );
}
