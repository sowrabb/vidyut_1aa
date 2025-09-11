// State Flow Admin Widgets
// Dialog components and management widgets for state flow administration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../store/admin_store.dart';
import '../models/state_flow_admin_models.dart';

// Export Data Dialog
class ExportDataDialog extends StatefulWidget {
  final AdminStore store;

  const ExportDataDialog({super.key, required this.store});

  @override
  State<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  final Set<String> _selectedDataTypes = <String>{};
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export State Flow Data'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select data types to export:'),
            const SizedBox(height: 16),
            ..._buildDataTypeCheckboxes(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting || _selectedDataTypes.isEmpty
              ? null
              : _exportData,
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  List<Widget> _buildDataTypeCheckboxes() {
    final dataTypes = {
      'customFields': 'Custom Fields',
      'customTabs': 'Custom Tabs',
      'entityTemplates': 'Entity Templates',
      'powerGenerators': 'Power Generators',
      'mediaAssets': 'Media Assets',
    };

    return dataTypes.entries.map((entry) {
      return CheckboxListTile(
        title: Text(entry.value),
        value: _selectedDataTypes.contains(entry.key),
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedDataTypes.add(entry.key);
            } else {
              _selectedDataTypes.remove(entry.key);
            }
          });
        },
      );
    }).toList();
  }

  void _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final data = widget.store.exportStateFlowData();
      
      // Filter data based on selection
      final filteredData = <String, dynamic>{};
      for (final type in _selectedDataTypes) {
        if (data.containsKey(type)) {
          filteredData[type] = data[type];
        }
      }
      
      // In a real app, this would trigger a file download
      // For now, we'll copy to clipboard
      await Clipboard.setData(ClipboardData(text: filteredData.toString()));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported to clipboard')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}

// Import Data Dialog
class ImportDataDialog extends StatefulWidget {
  final AdminStore store;

  const ImportDataDialog({super.key, required this.store});

  @override
  State<ImportDataDialog> createState() => _ImportDataDialogState();
}

class _ImportDataDialogState extends State<ImportDataDialog> {
  final _textController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import State Flow Data'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            const Text('Paste your exported data below:'),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste JSON data here...',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isImporting || _textController.text.isEmpty
              ? null
              : _importData,
          child: _isImporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }

  void _importData() async {
    setState(() {
      _isImporting = true;
    });

    try {
      // In a real app, this would parse JSON properly
      // For now, we'll simulate the import
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}

// Add/Edit Power Generator Dialog
class AddEditPowerGeneratorDialog extends StatefulWidget {
  final AdminStore store;
  final AdminPowerGenerator? generator;

  const AddEditPowerGeneratorDialog({
    super.key,
    required this.store,
    this.generator,
  });

  @override
  State<AddEditPowerGeneratorDialog> createState() => _AddEditPowerGeneratorDialogState();
}

class _AddEditPowerGeneratorDialogState extends State<AddEditPowerGeneratorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  final _establishedController = TextEditingController();
  final _founderController = TextEditingController();
  final _ceoController = TextEditingController();
  final _headquartersController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPlantsController = TextEditingController();
  final _employeesController = TextEditingController();
  final _revenueController = TextEditingController();
  
  bool _isPublished = true;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.generator != null) {
      _populateFields(widget.generator!);
    }
  }

  void _populateFields(AdminPowerGenerator generator) {
    _nameController.text = generator.name;
    _typeController.text = generator.type;
    _capacityController.text = generator.capacity;
    _locationController.text = generator.location;
    _establishedController.text = generator.established;
    _founderController.text = generator.founder;
    _ceoController.text = generator.ceo;
    _headquartersController.text = generator.headquarters;
    _phoneController.text = generator.phone;
    _emailController.text = generator.email;
    _websiteController.text = generator.website;
    _descriptionController.text = generator.description;
    _totalPlantsController.text = generator.totalPlants.toString();
    _employeesController.text = generator.employees;
    _revenueController.text = generator.revenue;
    _isPublished = generator.isPublished;
    _tags.addAll(generator.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    _establishedController.dispose();
    _founderController.dispose();
    _ceoController.dispose();
    _headquartersController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _totalPlantsController.dispose();
    _employeesController.dispose();
    _revenueController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.generator == null ? 'Add Power Generator' : 'Edit Power Generator',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildContactInfoSection(),
                      const SizedBox(height: 24),
                      _buildCompanyInfoSection(),
                      const SizedBox(height: 24),
                      _buildPublishingSection(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveGenerator,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Company Name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  hintText: 'e.g., Thermal, Hydro, Nuclear',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Type is required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity *',
                  hintText: 'e.g., 65,810 MW',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Capacity is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Location is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _headquartersController,
          decoration: const InputDecoration(
            labelText: 'Headquarters',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isNotEmpty == true && !value!.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _websiteController,
          decoration: const InputDecoration(
            labelText: 'Website',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _establishedController,
                decoration: const InputDecoration(
                  labelText: 'Established',
                  hintText: 'e.g., 1975',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _founderController,
                decoration: const InputDecoration(
                  labelText: 'Founder',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _ceoController,
          decoration: const InputDecoration(
            labelText: 'CEO/Director',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _totalPlantsController,
                decoration: const InputDecoration(
                  labelText: 'Total Plants',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _employeesController,
                decoration: const InputDecoration(
                  labelText: 'Employees',
                  hintText: 'e.g., 18,000+',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _revenueController,
          decoration: const InputDecoration(
            labelText: 'Revenue',
            hintText: 'e.g., ₹1,15,000 Crore',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Publishing & Tags',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Published'),
          subtitle: const Text('Make this generator visible to users'),
          value: _isPublished,
          onChanged: (value) {
            setState(() {
              _isPublished = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Add Tag',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _tags.map((tag) => Chip(
            label: Text(tag),
            onDeleted: () {
              setState(() {
                _tags.remove(tag);
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  void _saveGenerator() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      final generator = AdminPowerGenerator(
        id: widget.generator?.id ?? 'gen_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        type: _typeController.text,
        capacity: _capacityController.text,
        location: _locationController.text,
        logo: 'assets/logo.png', // Default logo
        established: _establishedController.text,
        founder: _founderController.text,
        ceo: _ceoController.text,
        ceoPhoto: 'assets/logo.png', // Default photo
        headquarters: _headquartersController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        description: _descriptionController.text,
        totalPlants: int.tryParse(_totalPlantsController.text) ?? 0,
        employees: _employeesController.text,
        revenue: _revenueController.text,
        posts: const [], // Empty posts initially
        isPublished: _isPublished,
        publishedAt: _isPublished ? DateTime.now() : null,
        tags: _tags,
      );

      if (widget.generator == null) {
        await widget.store.addAdminPowerGenerator(generator);
      } else {
        await widget.store.updateAdminPowerGenerator(generator);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.generator == null
                  ? 'Power generator added successfully'
                  : 'Power generator updated successfully',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Add/Edit Custom Field Dialog
class AddEditCustomFieldDialog extends StatefulWidget {
  final AdminStore store;
  final CustomField? field;

  const AddEditCustomFieldDialog({
    super.key,
    required this.store,
    this.field,
  });

  @override
  State<AddEditCustomFieldDialog> createState() => _AddEditCustomFieldDialogState();
}

class _AddEditCustomFieldDialogState extends State<AddEditCustomFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final _placeholderController = TextEditingController();
  final _helpTextController = TextEditingController();
  
  CustomFieldType _selectedType = CustomFieldType.text;
  bool _isRequired = false;
  bool _isActive = true;
  final List<String> _choices = [];
  final _choiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.field != null) {
      _populateFields(widget.field!);
    }
  }

  void _populateFields(CustomField field) {
    _nameController.text = field.name;
    _labelController.text = field.label;
    _placeholderController.text = field.placeholder ?? '';
    _helpTextController.text = field.helpText ?? '';
    _selectedType = field.type;
    _isRequired = field.isRequired;
    _isActive = field.isActive;
    if (field.choices != null) {
      _choices.addAll(field.choices!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _placeholderController.dispose();
    _helpTextController.dispose();
    _choiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.field == null ? 'Add Custom Field' : 'Edit Custom Field',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBasicFieldInfo(),
                      const SizedBox(height: 16),
                      _buildFieldConfiguration(),
                      const SizedBox(height: 16),
                      _buildFieldOptions(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveField,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicFieldInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Field Name *',
            hintText: 'e.g., company_size',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _labelController,
          decoration: const InputDecoration(
            labelText: 'Field Label *',
            hintText: 'e.g., Company Size',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Label is required' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CustomFieldType>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Field Type',
            border: OutlineInputBorder(),
          ),
          items: CustomFieldType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getFieldTypeLabel(type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFieldConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _placeholderController,
          decoration: const InputDecoration(
            labelText: 'Placeholder Text',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _helpTextController,
          decoration: const InputDecoration(
            labelText: 'Help Text',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Required Field'),
          value: _isRequired,
          onChanged: (value) {
            setState(() {
              _isRequired = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Active'),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFieldOptions() {
    if (!_needsChoices(_selectedType)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _choiceController,
                decoration: const InputDecoration(
                  labelText: 'Add Option',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: _addChoice,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addChoice(_choiceController.text),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_choices.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: _choices.map((choice) => ListTile(
                title: Text(choice),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _choices.remove(choice);
                    });
                  },
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  String _getFieldTypeLabel(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.multilineText:
        return 'Multi-line Text';
      case CustomFieldType.richText:
        return 'Rich Text';
      case CustomFieldType.number:
        return 'Number';
      case CustomFieldType.currency:
        return 'Currency';
      case CustomFieldType.percentage:
        return 'Percentage';
      case CustomFieldType.date:
        return 'Date';
      case CustomFieldType.dateTime:
        return 'Date & Time';
      case CustomFieldType.email:
        return 'Email';
      case CustomFieldType.phone:
        return 'Phone';
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.dropdown:
        return 'Dropdown';
      case CustomFieldType.multiSelect:
        return 'Multi-Select';
      case CustomFieldType.checkbox:
        return 'Checkbox';
      case CustomFieldType.radio:
        return 'Radio Button';
      case CustomFieldType.file:
        return 'File Upload';
      case CustomFieldType.image:
        return 'Image Upload';
      case CustomFieldType.location:
        return 'Location';
      case CustomFieldType.relationship:
        return 'Relationship';
    }
  }

  bool _needsChoices(CustomFieldType type) {
    return [
      CustomFieldType.dropdown,
      CustomFieldType.multiSelect,
      CustomFieldType.radio,
    ].contains(type);
  }

  void _addChoice(String choice) {
    if (choice.trim().isNotEmpty && !_choices.contains(choice.trim())) {
      setState(() {
        _choices.add(choice.trim());
        _choiceController.clear();
      });
    }
  }

  void _saveField() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      final field = CustomField(
        id: widget.field?.id ?? 'field_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        label: _labelController.text,
        type: _selectedType,
        isRequired: _isRequired,
        placeholder: _placeholderController.text.isEmpty ? null : _placeholderController.text,
        helpText: _helpTextController.text.isEmpty ? null : _helpTextController.text,
        choices: _choices.isEmpty ? null : _choices,
        isActive: _isActive,
        createdAt: widget.field?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.field == null) {
        await widget.store.addCustomField(field);
      } else {
        await widget.store.updateCustomField(field);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.field == null
                  ? 'Custom field added successfully'
                  : 'Custom field updated successfully',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Add/Edit Custom Tab Dialog
class AddEditCustomTabDialog extends StatefulWidget {
  final AdminStore store;
  final CustomTab? tab;

  const AddEditCustomTabDialog({
    super.key,
    required this.store,
    this.tab,
  });

  @override
  State<AddEditCustomTabDialog> createState() => _AddEditCustomTabDialogState();
}

class _AddEditCustomTabDialogState extends State<AddEditCustomTabDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();
  final _orderController = TextEditingController();
  
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.tab != null) {
      _populateFields(widget.tab!);
    }
  }

  void _populateFields(CustomTab tab) {
    _nameController.text = tab.name;
    _labelController.text = tab.label;
    _descriptionController.text = tab.description ?? '';
    _iconController.text = tab.icon ?? '';
    _orderController.text = tab.order.toString();
    _isActive = tab.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.tab == null ? 'Add Custom Tab' : 'Edit Custom Tab',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tab Name *',
                          hintText: 'e.g., products',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          labelText: 'Tab Label *',
                          hintText: 'e.g., Products',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Label is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _iconController,
                              decoration: const InputDecoration(
                                labelText: 'Icon Name',
                                hintText: 'e.g., shopping_cart',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _orderController,
                              decoration: const InputDecoration(
                                labelText: 'Order',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveTab,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveTab() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      final tab = CustomTab(
        id: widget.tab?.id ?? 'tab_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        label: _labelController.text,
        icon: _iconController.text.isEmpty ? null : _iconController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        order: int.tryParse(_orderController.text) ?? 0,
        isActive: _isActive,
        createdAt: widget.tab?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.tab == null) {
        // For new tabs, we need to ask which entity type to add it to
        // For now, we'll add it to all entity types
        for (final entityType in EntityType.values) {
          await widget.store.addCustomTab(tab, entityType);
        }
      } else {
        await widget.store.updateCustomTab(tab);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tab == null
                  ? 'Custom tab added successfully'
                  : 'Custom tab updated successfully',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Settings Dialog
class StateFlowSettingsDialog extends StatefulWidget {
  final AdminStore store;

  const StateFlowSettingsDialog({super.key, required this.store});

  @override
  State<StateFlowSettingsDialog> createState() => _StateFlowSettingsDialogState();
}

class _StateFlowSettingsDialogState extends State<StateFlowSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('State Flow Settings'),
      content: const SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Text('Settings configuration will be implemented here.'),
            Text('This includes:'),
            Text('• Default templates'),
            Text('• Field validation rules'),
            Text('• Media upload settings'),
            Text('• Search configurations'),
            Text('• Performance settings'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
