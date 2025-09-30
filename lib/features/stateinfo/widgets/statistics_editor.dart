import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import 'state_info_bottom_sheet_editor.dart';

/// Statistics editor with dynamic key-value pairs
class StatisticsEditor extends StatefulWidget {
  final Map<String, String> statistics;
  final Function(Map<String, String>) onSave;

  const StatisticsEditor({
    super.key,
    required this.statistics,
    required this.onSave,
  });

  @override
  State<StatisticsEditor> createState() => _StatisticsEditorState();
}

class _StatisticsEditorState extends State<StatisticsEditor> {
  late List<MapEntry<String, String>> _statisticsList;

  @override
  void initState() {
    super.initState();
    _statisticsList = widget.statistics.entries.toList();
  }

  void _handleSave() {
    final Map<String, String> newStats = Map.fromEntries(_statisticsList);
    widget.onSave(newStats);
    Navigator.pop(context);
  }

  void _addStatistic() {
    setState(() {
      _statisticsList.add(const MapEntry('', ''));
    });
  }

  void _removeStatistic(int index) {
    setState(() {
      _statisticsList.removeAt(index);
    });
  }

  void _updateStatistic(int index, String key, String value) {
    setState(() {
      _statisticsList[index] = MapEntry(key, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StateInfoBottomSheetEditor(
      title: 'Edit Key Statistics',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add or edit key statistics. Each statistic will be displayed as a card.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Statistics list
          ...List.generate(_statisticsList.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Statistic Name',
                            hintText: 'e.g., Total Plants',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) => _updateStatistic(
                              index, value, _statisticsList[index].value),
                          controller: TextEditingController(
                              text: _statisticsList[index].key),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            hintText: 'e.g., 15',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) => _updateStatistic(
                              index, _statisticsList[index].key, value),
                          controller: TextEditingController(
                              text: _statisticsList[index].value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeStatistic(index),
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Remove statistic',
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Add button
          Center(
            child: OutlinedButton.icon(
              onPressed: _addStatistic,
              icon: const Icon(Icons.add),
              label: const Text('Add Statistic'),
            ),
          ),

          const SizedBox(height: 16),

          // Preview
          if (_statisticsList.isNotEmpty)
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
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: _statisticsList
                          .where((entry) =>
                              entry.key.isNotEmpty && entry.value.isNotEmpty)
                          .map((entry) => Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        entry.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                      Text(
                                        entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
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
}

/// Helper function to show statistics editor
void showStatisticsEditor({
  required BuildContext context,
  required Map<String, String> statistics,
  required Function(Map<String, String>) onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatisticsEditor(
      statistics: statistics,
      onSave: onSave,
    ),
  );
}
