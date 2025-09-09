import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../../app/tokens.dart';
import '../models.dart';

class CustomFieldEditor extends StatefulWidget {
  final List<CustomFieldDef> fields;
  final ValueChanged<List<CustomFieldDef>> onFieldsChanged;

  const CustomFieldEditor({
    super.key,
    required this.fields,
    required this.onFieldsChanged,
  });

  @override
  State<CustomFieldEditor> createState() => _CustomFieldEditorState();
}

class _CustomFieldEditorState extends State<CustomFieldEditor> {
  late List<CustomFieldDef> _fields;

  @override
  void initState() {
    super.initState();
    _fields = List.from(widget.fields);
  }

  void _addField() {
    final newField = CustomFieldDef(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'New Field',
      type: FieldType.text,
    );
    setState(() {
      _fields.add(newField);
    });
    widget.onFieldsChanged(_fields);
  }

  void _updateField(int index, CustomFieldDef field) {
    setState(() {
      _fields[index] = field;
    });
    widget.onFieldsChanged(_fields);
  }

  void _deleteField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
    widget.onFieldsChanged(_fields);
  }

  void _showDropdownOptionsDialog(CustomFieldDef field, int index) {
    final optionsController = TextEditingController(
      text: field.options.join(', '),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dropdown Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter options separated by commas:'),
            const SizedBox(height: 16),
            TextField(
              controller: optionsController,
              decoration: const InputDecoration(
                hintText: 'Option 1, Option 2, Option 3',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final options = optionsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              _updateField(index, field.copyWith(options: options));
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Custom Fields',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _addField,
              icon: const Icon(Ionicons.add_outline, size: 18),
              label: const Text('Add Field'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_fields.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineSoft),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Ionicons.add_circle_outline,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No custom fields yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add custom fields to collect specific information',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fields.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final field = _fields[index];
              return _FieldCard(
                field: field,
                onUpdate: (updatedField) => _updateField(index, updatedField),
                onDelete: () => _deleteField(index),
                onShowOptions: field.type == FieldType.dropdown
                    ? () => _showDropdownOptionsDialog(field, index)
                    : null,
              );
            },
          ),
      ],
    );
  }
}

class _FieldCard extends StatefulWidget {
  final CustomFieldDef field;
  final ValueChanged<CustomFieldDef> onUpdate;
  final VoidCallback onDelete;
  final VoidCallback? onShowOptions;

  const _FieldCard({
    required this.field,
    required this.onUpdate,
    required this.onDelete,
    this.onShowOptions,
  });

  @override
  State<_FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<_FieldCard> {
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadowSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Field Label',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      widget.onUpdate(widget.field.copyWith(label: value));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<FieldType>(
                    value: widget.field.type,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: FieldType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeLabel(type)),
                      );
                    }).toList(),
                    onChanged: (type) {
                      if (type != null) {
                        widget.onUpdate(widget.field.copyWith(type: type));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Ionicons.trash_outline, size: 20),
                  color: AppColors.error,
                  tooltip: 'Delete Field',
                ),
              ],
            ),
            if (widget.field.type == FieldType.dropdown) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Options: ${widget.field.options.isEmpty ? "None" : widget.field.options.join(", ")}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onShowOptions,
                    icon: const Icon(Ionicons.settings_outline, size: 16),
                    label: const Text('Edit Options'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Text';
      case FieldType.number:
        return 'Number';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.boolean:
        return 'Yes/No';
      case FieldType.date:
        return 'Date';
    }
  }
}
