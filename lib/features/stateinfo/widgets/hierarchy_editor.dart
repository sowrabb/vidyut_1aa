import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import 'state_info_bottom_sheet_editor.dart';
import '../../../services/lightweight_demo_data_service.dart';

/// Hierarchy editor for managing states, mandals, and discoms
class HierarchyEditor extends StatefulWidget {
  final LightweightDemoDataService demoDataService;
  final Function(String type, Map<String, dynamic> data) onSave;

  const HierarchyEditor({
    super.key,
    required this.demoDataService,
    required this.onSave,
  });

  @override
  State<HierarchyEditor> createState() => _HierarchyEditorState();
}

class _HierarchyEditorState extends State<HierarchyEditor>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Generators'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateInfoBottomSheetEditor(
      title: 'Manage Hierarchy',
      content: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            isScrollable: true,
          ),

          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _GeneratorsTab(
                    demoDataService: widget.demoDataService,
                    onSave: widget.onSave),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Generators management tab
class _GeneratorsTab extends StatefulWidget {
  final LightweightDemoDataService demoDataService;
  final Function(String type, Map<String, dynamic> data) onSave;

  const _GeneratorsTab({
    required this.demoDataService,
    required this.onSave,
  });

  @override
  State<_GeneratorsTab> createState() => _GeneratorsTabState();
}

class _GeneratorsTabState extends State<_GeneratorsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave('generator', {
        'name': _nameController.text,
        'type': _typeController.text,
        'capacity': _capacityController.text,
        'description': _descriptionController.text,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add new generator form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Generator',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Generator Name',
                      hintText: 'e.g., NTPC Ramagundam',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Generator name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Generator Type',
                      hintText: 'e.g., Thermal, Solar, Wind',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Generator type is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      hintText: 'e.g., 1000 MW',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Capacity is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Brief description of the generator...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      child: const Text('Add Generator'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Existing generators list
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Existing Generators',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          widget.demoDataService.allPowerGenerators.length,
                      itemBuilder: (context, index) {
                        final generator =
                            widget.demoDataService.allPowerGenerators[index];

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.power, color: Colors.white),
                          ),
                          title: Text(generator.name),
                          subtitle:
                              Text('${generator.type} - ${generator.capacity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              // Pending: Implement edit generator
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Edit ${generator.name} - Coming soon')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper function to show hierarchy editor
void showHierarchyEditor({
  required BuildContext context,
  required LightweightDemoDataService demoDataService,
  required Function(String type, Map<String, dynamic> data) onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => HierarchyEditor(
      demoDataService: demoDataService,
      onSave: onSave,
    ),
  );
}
