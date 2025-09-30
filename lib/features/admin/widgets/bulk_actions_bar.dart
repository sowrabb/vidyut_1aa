import 'package:flutter/material.dart';

/// Bulk actions bar for selected users
class BulkActionsBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final Function(String) onBulkAction;

  const BulkActionsBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onBulkAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 640;
          final actionButtons = [
            FilledButton.icon(
              onPressed: () => onBulkAction('activate'),
              icon: const Icon(Icons.check_circle),
              label: const Text('Activate'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => onBulkAction('suspend'),
              icon: const Icon(Icons.pause_circle),
              label: const Text('Suspend'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
              ),
              onPressed: () => onBulkAction('delete'),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ];

          final selectionInfo = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selectedCount of $totalCount selected',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed:
                    selectedCount == totalCount ? onDeselectAll : onSelectAll,
                child: Text(
                  selectedCount == totalCount ? 'Deselect All' : 'Select All',
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selectionInfo,
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: actionButtons,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: selectionInfo),
              Wrap(
                spacing: 12,
                children: actionButtons,
              ),
            ],
          );
        },
      ),
    );
  }
}
