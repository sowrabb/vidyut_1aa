import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import 'advanced_search_filter.dart';

/// Bulk Operations System for StateInfo editing
class BulkOperations extends StatefulWidget {
  final List<String> selectedItems;
  final String entityType;
  final Function(List<String>, BulkOperation)? onBulkOperation;
  final Function(List<String>)? onSelectionChanged;
  final List<BulkOperationOption> availableOperations;

  const BulkOperations({
    super.key,
    required this.selectedItems,
    required this.entityType,
    this.onBulkOperation,
    this.onSelectionChanged,
    required this.availableOperations,
  });

  @override
  State<BulkOperations> createState() => _BulkOperationsState();
}

class _BulkOperationsState extends State<BulkOperations> {
  bool _showBulkPanel = false;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showBulkPanel ? null : 60,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.select_all, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.selectedItems.length} ${widget.entityType.toLowerCase()}${widget.selectedItems.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _showBulkPanel = !_showBulkPanel),
                    icon: Icon(
                      _showBulkPanel
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onSelectionChanged?.call([]),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Clear Selection',
                  ),
                ],
              ),
            ),

            // Bulk Operations Panel
            if (_showBulkPanel)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bulk Operations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableOperations.map((operation) {
                        return _buildOperationButton(operation);
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButton(BulkOperationOption operation) {
    return ElevatedButton.icon(
      onPressed: () => _executeBulkOperation(operation),
      icon: Icon(operation.icon, size: 16),
      label: Text(operation.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: operation.color ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _executeBulkOperation(BulkOperationOption operation) {
    widget.onBulkOperation?.call(
        widget.selectedItems,
        BulkOperation(
          type: operation.type,
          label: operation.label,
          parameters: {},
        ));
  }
}

/// Bulk operation option definition
class BulkOperationOption {
  final BulkOperationType type;
  final String label;
  final IconData icon;
  final Color? color;
  final bool requiresConfirmation;
  final String? confirmationMessage;

  const BulkOperationOption({
    required this.type,
    required this.label,
    required this.icon,
    this.color,
    this.requiresConfirmation = true,
    this.confirmationMessage,
  });
}

/// Bulk operation types
enum BulkOperationType {
  delete,
  edit,
  enable,
  disable,
  export,
  import,
  duplicate,
  move,
  assignCategory,
  assignRegion,
  setStatus,
}

/// Bulk operation model
class BulkOperation {
  final BulkOperationType type;
  final String label;
  final Map<String, dynamic> parameters;

  const BulkOperation({
    required this.type,
    required this.label,
    required this.parameters,
  });
}

/// Bulk Edit Bottom Sheet
class BulkEditBottomSheet extends StatefulWidget {
  final List<String> selectedItems;
  final String entityType;
  final List<BulkEditField> availableFields;
  final Function(List<String>, Map<String, dynamic>)? onSave;

  const BulkEditBottomSheet({
    super.key,
    required this.selectedItems,
    required this.entityType,
    required this.availableFields,
    this.onSave,
  });

  @override
  State<BulkEditBottomSheet> createState() => _BulkEditBottomSheetState();
}

class _BulkEditBottomSheetState extends State<BulkEditBottomSheet> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.availableFields) {
      _controllers[field.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.outlineSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(Icons.edit, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bulk Edit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.selectedItems.length} ${widget.entityType.toLowerCase()}${widget.selectedItems.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text(
                  'Select fields to update for all selected items:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.availableFields
                    .map((field) => _buildFieldInput(field)),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(BulkEditField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _values.containsKey(field.name) &&
                    _values[field.name] != null,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _values[field.name] = '';
                    } else {
                      _values.remove(field.name);
                      _controllers[field.name]?.clear();
                    }
                  });
                },
              ),
              Expanded(
                child: Text(
                  field.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_values.containsKey(field.name) &&
              _values[field.name] != null) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _controllers[field.name],
              decoration: InputDecoration(
                hintText: 'Enter new ${field.displayName.toLowerCase()}',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _values[field.name] = value;
              },
            ),
          ],
        ],
      ),
    );
  }

  void _saveChanges() {
    final changes = <String, dynamic>{};
    for (final entry in _values.entries) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        changes[entry.key] = entry.value;
      }
    }

    if (changes.isNotEmpty) {
      widget.onSave?.call(widget.selectedItems, changes);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one field to update'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Bulk edit field definition
class BulkEditField {
  final String name;
  final String displayName;
  final BulkEditFieldType type;
  final List<String>? options;

  const BulkEditField({
    required this.name,
    required this.displayName,
    this.type = BulkEditFieldType.text,
    this.options,
  });
}

/// Bulk edit field types
enum BulkEditFieldType {
  text,
  number,
  email,
  url,
  dropdown,
  boolean,
}

/// Bulk Operations Manager
class BulkOperationsManager {
  /// Get available operations for a specific entity type
  static List<BulkOperationOption> getAvailableOperations(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'power generator':
        return [
          const BulkOperationOption(
            type: BulkOperationType.edit,
            label: 'Bulk Edit',
            icon: Icons.edit,
          ),
          const BulkOperationOption(
            type: BulkOperationType.delete,
            label: 'Delete',
            icon: Icons.delete,
            color: Colors.red,
          ),
          const BulkOperationOption(
            type: BulkOperationType.duplicate,
            label: 'Duplicate',
            icon: Icons.copy,
          ),
          const BulkOperationOption(
            type: BulkOperationType.export,
            label: 'Export',
            icon: Icons.download,
          ),
        ];
      case 'state':
        return [
          const BulkOperationOption(
            type: BulkOperationType.edit,
            label: 'Bulk Edit',
            icon: Icons.edit,
          ),
          const BulkOperationOption(
            type: BulkOperationType.delete,
            label: 'Delete',
            icon: Icons.delete,
            color: Colors.red,
          ),
          const BulkOperationOption(
            type: BulkOperationType.duplicate,
            label: 'Duplicate',
            icon: Icons.copy,
          ),
          const BulkOperationOption(
            type: BulkOperationType.export,
            label: 'Export',
            icon: Icons.download,
          ),
        ];
      case 'distribution company':
      case 'discom':
        return [
          const BulkOperationOption(
            type: BulkOperationType.edit,
            label: 'Bulk Edit',
            icon: Icons.edit,
          ),
          const BulkOperationOption(
            type: BulkOperationType.delete,
            label: 'Delete',
            icon: Icons.delete,
            color: Colors.red,
          ),
          const BulkOperationOption(
            type: BulkOperationType.duplicate,
            label: 'Duplicate',
            icon: Icons.copy,
          ),
          const BulkOperationOption(
            type: BulkOperationType.export,
            label: 'Export',
            icon: Icons.download,
          ),
        ];
      default:
        return [
          const BulkOperationOption(
            type: BulkOperationType.edit,
            label: 'Bulk Edit',
            icon: Icons.edit,
          ),
          const BulkOperationOption(
            type: BulkOperationType.delete,
            label: 'Delete',
            icon: Icons.delete,
            color: Colors.red,
          ),
        ];
    }
  }

  /// Get available fields for bulk editing
  static List<BulkEditField> getAvailableFields(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'power generator':
        return [
          const BulkEditField(name: 'name', displayName: 'Name'),
          const BulkEditField(name: 'type', displayName: 'Type'),
          const BulkEditField(name: 'location', displayName: 'Location'),
          const BulkEditField(
              name: 'headquarters', displayName: 'Headquarters'),
          const BulkEditField(name: 'phone', displayName: 'Phone'),
          const BulkEditField(name: 'email', displayName: 'Email'),
          const BulkEditField(name: 'website', displayName: 'Website'),
        ];
      case 'state':
        return [
          const BulkEditField(name: 'name', displayName: 'Name'),
          const BulkEditField(name: 'capital', displayName: 'Capital'),
          const BulkEditField(name: 'website', displayName: 'Website'),
          const BulkEditField(name: 'email', displayName: 'Email'),
          const BulkEditField(name: 'helpline', displayName: 'Helpline'),
        ];
      case 'distribution company':
      case 'discom':
        return [
          const BulkEditField(name: 'name', displayName: 'Name'),
          const BulkEditField(name: 'coverage', displayName: 'Coverage'),
          const BulkEditField(name: 'website', displayName: 'Website'),
          const BulkEditField(name: 'phone', displayName: 'Phone'),
          const BulkEditField(name: 'email', displayName: 'Email'),
        ];
      default:
        return [
          const BulkEditField(name: 'name', displayName: 'Name'),
        ];
    }
  }

  /// Get search filter fields for an entity type
  static List<SearchFilterField> getSearchFilterFields(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'power generator':
        return [
          const SearchFilterField(name: 'name', displayName: 'Name'),
          const SearchFilterField(name: 'type', displayName: 'Type'),
          const SearchFilterField(name: 'location', displayName: 'Location'),
          const SearchFilterField(name: 'capacity', displayName: 'Capacity'),
          const SearchFilterField(
              name: 'established', displayName: 'Established'),
          const SearchFilterField(name: 'ceo', displayName: 'CEO'),
          const SearchFilterField(
              name: 'headquarters', displayName: 'Headquarters'),
          const SearchFilterField(name: 'phone', displayName: 'Phone'),
          const SearchFilterField(name: 'email', displayName: 'Email'),
          const SearchFilterField(name: 'website', displayName: 'Website'),
        ];
      case 'state':
        return [
          const SearchFilterField(name: 'name', displayName: 'Name'),
          const SearchFilterField(name: 'capital', displayName: 'Capital'),
          const SearchFilterField(
              name: 'powerCapacity', displayName: 'Power Capacity'),
          const SearchFilterField(
              name: 'chiefMinister', displayName: 'Chief Minister'),
          const SearchFilterField(
              name: 'energyMinister', displayName: 'Energy Minister'),
          const SearchFilterField(name: 'website', displayName: 'Website'),
          const SearchFilterField(name: 'email', displayName: 'Email'),
          const SearchFilterField(name: 'helpline', displayName: 'Helpline'),
        ];
      case 'distribution company':
      case 'discom':
        return [
          const SearchFilterField(name: 'name', displayName: 'Name'),
          const SearchFilterField(name: 'coverage', displayName: 'Coverage'),
          const SearchFilterField(name: 'customers', displayName: 'Customers'),
          const SearchFilterField(name: 'capacity', displayName: 'Capacity'),
          const SearchFilterField(name: 'director', displayName: 'Director'),
          const SearchFilterField(name: 'website', displayName: 'Website'),
          const SearchFilterField(name: 'phone', displayName: 'Phone'),
          const SearchFilterField(name: 'email', displayName: 'Email'),
        ];
      default:
        return [
          const SearchFilterField(name: 'name', displayName: 'Name'),
        ];
    }
  }
}
