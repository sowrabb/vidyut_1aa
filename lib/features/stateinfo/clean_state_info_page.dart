import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/tokens.dart';
import '../../../app/layout/adaptive.dart';
import 'store/state_info_edit_store.dart';
import 'models/state_info_models.dart';
import 'data/static_data.dart';
import 'data/profile_posts_data.dart';
import 'widgets/profile_post_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'widgets/profile_search_filter.dart';
import 'widgets/professional_bottom_sheet.dart';
import 'widgets/advanced_search_filter.dart';
import 'widgets/bulk_operations.dart';
import 'widgets/enhanced_post_editor.dart';
import '../../../app/provider_registry.dart';

/// Clean, scalable state info page with dropdown-based selection
class CleanStateInfoPage extends StatelessWidget {
  final bool isEditMode;
  final bool showAdminControls;

  const CleanStateInfoPage({super.key, this.isEditMode = false, this.showAdminControls = false});

  @override
  Widget build(BuildContext context) {
    return _CleanStateInfoContent(isEditMode: isEditMode, showAdminControls: showAdminControls);
  }
}

class _EditStateInfoButton extends StatelessWidget {
  const _EditStateInfoButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Main Edit Button
          ElevatedButton(
            onPressed: () => _navigateToEditMode(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 24),
                SizedBox(width: 12),
                Text(
                  'Edit StateInfo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Data Management Button
          OutlinedButton.icon(
            onPressed: () => _showDataManagementBottomSheet(context),
            icon: const Icon(Icons.data_object, size: 20),
            label: const Text(
              'Data Management',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataManagementBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DataManagementBottomSheet(),
    );
  }

  void _navigateToEditMode(BuildContext context) {
    // Use replace instead of push to prevent deep stacks
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CleanStateInfoPage(isEditMode: true),
      ),
    );
  }
}

class _CleanStateInfoContent extends StatelessWidget {
  final bool isEditMode;
  final bool showAdminControls;

  const _CleanStateInfoContent({required this.isEditMode, required this.showAdminControls});

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      appBar: AppBar(
        title: const Text('State Electricity Board Info'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(),
                const SizedBox(height: 32),
                if (showAdminControls) const _EditStateInfoButton(),
                if (showAdminControls) const SizedBox(height: 32),
                _FlowSelectionCard(
                  title: 'Power Generation Flow',
                  subtitle: 'Explore power generation infrastructure',
                  icon: Icons.bolt,
                  color: Colors.orange,
                  onTap: () => _showPowerFlowSelection(context, isEditMode),
                  isEditMode: isEditMode,
                ),
                const SizedBox(height: 24),
                _FlowSelectionCard(
                  title: 'State-Based Flow',
                  subtitle: 'Explore by geographic regions',
                  icon: Icons.map,
                  color: Colors.blue,
                  onTap: () => _showStateFlowSelection(context, isEditMode),
                  isEditMode: isEditMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return page;
  }

  Widget _HeaderSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.electrical_services,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Choose Information Flow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Select how you want to explore India\'s electricity infrastructure',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showPowerFlowSelection(BuildContext context, bool isEditMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PowerFlowSelectionPage(isEditMode: isEditMode),
      ),
    );
  }

  void _showStateFlowSelection(BuildContext context, bool isEditMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _StateFlowSelectionPage(isEditMode: isEditMode),
      ),
    );
  }
}

class _FlowSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isEditMode;

  const _FlowSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditMode) ...[
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _showEditFlowBottomSheet(context),
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Edit Flow',
                ),
              ],
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditFlowBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FlowEditBottomSheet(
        title: title,
        subtitle: subtitle,
        icon: icon,
        color: color,
      ),
    );
  }
}

/// Power Generation Flow Selection Page
class _PowerFlowSelectionPage extends StatefulWidget {
  final bool isEditMode;

  const _PowerFlowSelectionPage({this.isEditMode = false});

  @override
  State<_PowerFlowSelectionPage> createState() =>
      _PowerFlowSelectionPageState();
}

class _PowerFlowSelectionPageState extends State<_PowerFlowSelectionPage> {
  String? selectedGenerator;
  String? selectedTransmission;
  String? selectedDistribution;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Generation Flow'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.orange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Power Generation Flow',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Explore power generation infrastructure',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Step 1: Generator Selection
                _SelectionStep(
                  title: 'Step 1: Select Power Generator',
                  subtitle: 'Choose a power generation company',
                  isEditMode: widget.isEditMode,
                  onEdit: () => _showEditGeneratorsBottomSheet(context),
                  actionButton: selectedGenerator != null
                      ? _ActionButton(
                          label: 'Show Profile',
                          onPressed: () => _showGeneratorProfile(
                              context, selectedGenerator!),
                        )
                      : null,
                  child: DropdownButtonFormField<String>(
                    value: selectedGenerator,
                    decoration: const InputDecoration(
                      labelText: 'Power Generator',
                      border: OutlineInputBorder(),
                    ),
                    items: ProviderScope.containerOf(context)
                        .read(stateInfoEditStoreProvider)
                        .powerGenerators
                        .map((generator) {
                      return DropdownMenuItem(
                        value: generator.id,
                        child: Text(generator.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGenerator = value;
                        selectedTransmission = null;
                        selectedDistribution = null;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Step 2: Transmission Selection
                _SelectionStep(
                  title: 'Step 2: Select Transmission Line',
                  subtitle: 'Choose a transmission infrastructure',
                  isEditMode: widget.isEditMode,
                  onEdit: () => _showEditTransmissionBottomSheet(context),
                  actionButton: selectedTransmission != null
                      ? _ActionButton(
                          label: 'Show Profile',
                          onPressed: () => _showTransmissionProfile(
                              context, selectedTransmission!),
                        )
                      : null,
                  enabled: selectedGenerator != null,
                  child: DropdownButtonFormField<String>(
                    value: selectedTransmission,
                    decoration: const InputDecoration(
                      labelText: 'Transmission Line',
                      border: OutlineInputBorder(),
                    ),
                    items: ProviderScope.containerOf(context)
                        .read(stateInfoEditStoreProvider)
                        .transmissionLines
                        .map((transmission) {
                      return DropdownMenuItem(
                        value: transmission.id,
                        child: Text(transmission.name),
                      );
                    }).toList(),
                    onChanged: selectedGenerator != null
                        ? (value) {
                            setState(() {
                              selectedTransmission = value;
                              selectedDistribution = null;
                            });
                          }
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                // Step 3: Distribution Selection
                _SelectionStep(
                  title: 'Step 3: Select Distribution Company',
                  subtitle: 'Choose a distribution company',
                  isEditMode: widget.isEditMode,
                  onEdit: () => _showEditDistributionBottomSheet(context),
                  actionButton: selectedDistribution != null
                      ? _ActionButton(
                          label: 'Show Profile',
                          onPressed: () => _showDistributionProfile(
                              context, selectedDistribution!),
                        )
                      : null,
                  enabled: selectedTransmission != null,
                  child: DropdownButtonFormField<String>(
                    value: selectedDistribution,
                    decoration: const InputDecoration(
                      labelText: 'Distribution Company',
                      border: OutlineInputBorder(),
                    ),
                    items: ProviderScope.containerOf(context)
                        .read(stateInfoEditStoreProvider)
                        .distributionCompanies
                        .map((distribution) {
                      return DropdownMenuItem(
                        value: distribution.id,
                        child: Text(distribution.name),
                      );
                    }).toList(),
                    onChanged: selectedTransmission != null
                        ? (value) {
                            setState(() {
                              selectedDistribution = value;
                            });
                          }
                        : null,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGeneratorProfile(BuildContext context, String generatorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GeneratorProfilePage(
          generatorId: generatorId,
          isEditMode: widget.isEditMode,
        ),
      ),
    );
  }

  void _showTransmissionProfile(BuildContext context, String transmissionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _TransmissionProfilePage(transmissionId: transmissionId),
      ),
    );
  }

  void _showDistributionProfile(BuildContext context, String distributionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DistributionProfilePage(
          distributionId: distributionId,
          isEditMode: widget.isEditMode,
        ),
      ),
    );
  }

  void _showEditGeneratorsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GeneratorsEditBottomSheet(),
    );
  }

  void _showEditTransmissionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TransmissionEditBottomSheet(),
    );
  }

  void _showEditDistributionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DistributionEditBottomSheet(),
    );
  }
}

/// State-Based Flow Selection Page
class _StateFlowSelectionPage extends StatefulWidget {
  final bool isEditMode;

  const _StateFlowSelectionPage({this.isEditMode = false});

  @override
  State<_StateFlowSelectionPage> createState() =>
      _StateFlowSelectionPageState();
}

class _StateFlowSelectionPageState extends State<_StateFlowSelectionPage> {
  String? selectedState;
  String? selectedMandal;
  String? selectedDiscom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State-Based Flow'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'State-Based Flow',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Explore by geographic regions',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Step 1: State Selection
                _SelectionStep(
                  title: 'Step 1: Select State',
                  subtitle: 'Choose an Indian state',
                  isEditMode: widget.isEditMode,
                  onEdit: () => _showEditStatesBottomSheet(context),
                  actionButton: selectedState != null
                      ? _ActionButton(
                          label: 'Show Profile',
                          onPressed: () =>
                              _showStateProfile(context, selectedState!),
                        )
                      : null,
                  child: DropdownButtonFormField<String>(
                    value: selectedState,
                    decoration: const InputDecoration(
                      labelText: 'Indian State',
                      border: OutlineInputBorder(),
                    ),
                    items: ProviderScope.containerOf(context)
                        .read(stateInfoEditStoreProvider)
                        .indianStates
                        .map((state) {
                      return DropdownMenuItem(
                        value: state.id,
                        child: Text(state.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedState = value;
                        selectedMandal = null;
                        selectedDiscom = null;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Step 2: Mandal/District Selection
                _SelectionStep(
                  title: 'Step 2: Select District/Mandal',
                  subtitle: 'Choose a district or mandal',
                  isEditMode: widget.isEditMode,
                  onEdit: () => _showEditMandalsBottomSheet(context),
                  actionButton: selectedMandal != null
                      ? _ActionButton(
                          label: 'Show Profile',
                          onPressed: () =>
                              _showMandalProfile(context, selectedMandal!),
                        )
                      : null,
                  enabled: selectedState != null,
                  child: DropdownButtonFormField<String>(
                    value: selectedMandal,
                    decoration: const InputDecoration(
                      labelText: 'District/Mandal',
                      border: OutlineInputBorder(),
                    ),
                    items: selectedState != null
                        ? StateInfoStaticData.indianStates
                            .firstWhere((s) => s.id == selectedState)
                            .mandals
                            .map((mandal) {
                            return DropdownMenuItem(
                              value: mandal.id,
                              child: Text(mandal.name),
                            );
                          }).toList()
                        : [],
                    onChanged: selectedState != null
                        ? (value) {
                            setState(() {
                              selectedMandal = value;
                            });
                          }
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                // Step 3: DISCOM Selection within selected district/state
                _SelectionStep(
                  title: 'Step 3: Select DISCOM',
                  subtitle:
                      'Choose a distribution company for the selected region',
                  isEditMode: widget.isEditMode,
                  onEdit: () => _showEditDiscomsBottomSheet(context),
                  actionButton: (selectedDiscom != null)
                      ? _ActionButton(
                          label: 'Show DISCOM Profile',
                          onPressed: () => _showSelectedDiscomProfile(context),
                        )
                      : null,
                  enabled: selectedState != null,
                  child: DropdownButtonFormField<String>(
                    value: selectedDiscom,
                    decoration: const InputDecoration(
                      labelText: 'DISCOM',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableDiscoms()
                        .map((name) =>
                            DropdownMenuItem(value: name, child: Text(name)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDiscom = val;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStateProfile(BuildContext context, String stateId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _StateProfilePage(
          stateId: stateId,
          isEditMode: widget.isEditMode,
        ),
      ),
    );
  }

  void _showMandalProfile(BuildContext context, String mandalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MandalProfilePage(mandalId: mandalId),
      ),
    );
  }

  List<String> _availableDiscoms() {
    if (selectedState == null) return [];
    final state = StateInfoStaticData.indianStates
        .firstWhere((s) => s.id == selectedState);
    // If district selected and it has discoms, prioritize those; else show state discom list
    if (selectedMandal != null) {
      final mandal = state.mandals.firstWhere((m) => m.id == selectedMandal,
          orElse: () => state.mandals.first);
      if ((mandal.discoms ?? []).isNotEmpty) return mandal.discoms!;
    }
    return state.discomsList;
  }

  void _showSelectedDiscomProfile(BuildContext context) {
    if (selectedDiscom == null) return;
    // Try to resolve to known distribution company dataset by name id mapping
    final name = selectedDiscom!;
    final match = StateInfoStaticData.distributionCompanies.firstWhere(
      (d) =>
          d.name.toLowerCase() == name.toLowerCase() ||
          d.id.toLowerCase() == name.toLowerCase(),
      orElse: () => StateInfoStaticData.distributionCompanies.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DistributionProfilePage(
          distributionId: match.id,
          isEditMode: widget.isEditMode,
        ),
      ),
    );
  }

  void _showEditStatesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _StatesEditBottomSheet(),
    );
  }

  void _showEditMandalsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _MandalsEditBottomSheet(selectedState: selectedState),
    );
  }

  void _showEditDiscomsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DiscomsEditBottomSheet(),
    );
  }
}

/// Selection Step Widget
class _SelectionStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? actionButton;
  final bool enabled;
  final bool isEditMode;
  final VoidCallback? onEdit;

  const _SelectionStep({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionButton,
    this.enabled = true,
    this.isEditMode = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditMode && onEdit != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Edit ${title.split(': ').last}',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
          if (actionButton != null) ...[
            const SizedBox(height: 12),
            actionButton!,
          ],
        ],
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.visibility),
        label: Text(label),
      ),
    );
  }
}

// Profile pages with customer-facing seller profile layout
class _GeneratorProfilePage extends StatefulWidget {
  final String generatorId;
  final bool isEditMode;

  const _GeneratorProfilePage(
      {required this.generatorId, this.isEditMode = false});

  @override
  State<_GeneratorProfilePage> createState() => _GeneratorProfilePageState();
}

class _GeneratorProfilePageState extends State<_GeneratorProfilePage>
    with TickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _showEditGeneratorBottomSheet(
      BuildContext context, PowerGenerator generator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GeneratorEditBottomSheet(generator: generator),
    );
  }

  void _showCustomFieldsBottomSheet(
      BuildContext context, String entityId, String entityType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomFieldsEditBottomSheet(
        entityId: entityId,
        entityType: entityType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generator = StateInfoStaticData.powerGenerators.firstWhere(
      (g) => g.id == widget.generatorId,
      orElse: () => StateInfoStaticData.powerGenerators.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: widget.isEditMode
            ? [
                IconButton(
                  onPressed: () => _showCustomFieldsBottomSheet(
                      context, generator.id, 'Power Generator'),
                  icon: const Icon(Icons.edit_attributes,
                      color: AppColors.primary),
                  tooltip: 'Edit Custom Fields',
                ),
                IconButton(
                  onPressed: () =>
                      _showEditGeneratorBottomSheet(context, generator),
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Edit Generator Profile',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: ContentClamp(
          child: NestedScrollView(
            headerSliverBuilder: (c, inner) => [
              SliverToBoxAdapter(child: _masthead(context, generator)),
              SliverAppBar(
                pinned: true,
                toolbarHeight: 56,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                backgroundColor: AppColors.surface,
                title: TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Admin'),
                    Tab(text: 'Updates'),
                    Tab(text: 'Product Designs'),
                    Tab(text: 'Contact'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _overviewTab(context, generator),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Admin',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.outlineSoft)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.person,
                                  size: 42, color: AppColors.primary)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    generator.ceo.isNotEmpty
                                        ? generator.ceo
                                        : 'Authority Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('Chief Executive Officer',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppColors.textSecondary)),
                              ])),
                        ]),
                      ),
                    ),
                  ],
                ),
                _updatesTab(
                    context, generator.id, ProfilePostsData.getGeneratorPosts),
                _productDesignsTab(
                    context, generator.id, ProfilePostsData.getGeneratorPosts),
                _contactTab(context, generator),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _masthead(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    final isPhone = MediaQuery.of(context).size.width < 768;
    const double logoSize = 112;

    final contactMeta = [
      _Meta(generator.location),
      _Meta('Type: ${generator.type}'),
      if (generator.phone.isNotEmpty)
        _ClickableMetaIcon(
          Icons.call,
          generator.phone,
          onTap: () => _launchPhone(generator.phone),
        ),
      if (generator.email.isNotEmpty)
        _ClickableMetaIcon(
          Icons.email,
          generator.email,
          onTap: () => _launchEmail(generator.email),
        ),
    ];

    final statsMeta = [
      _Badge('${generator.totalPlants} Plants'),
      const _Meta('★ 4.8 (150)'),
      _Meta('${generator.employees} Employees'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: !isPhone
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.bolt,
                          color: Colors.orange, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(generator.name, style: t.headlineSmall),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: contactMeta),
                          const SizedBox(height: 6),
                          Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () => _launchPhone(generator.phone),
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Generator'),
                  ),
                  if (generator.website.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => _launchWebsite(generator.website),
                      icon: const Icon(Icons.web),
                      label: const Text('Visit Website'),
                    ),
                ]),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.bolt, color: Colors.orange, size: 36),
                ),
                const SizedBox(height: 12),
                Text(generator.name, style: t.headlineSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 12, runSpacing: 6, children: contactMeta),
                const SizedBox(height: 6),
                Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () => _launchPhone(generator.phone),
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Generator'),
                  ),
                  if (generator.website.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => _launchWebsite(generator.website),
                      icon: const Icon(Icons.web),
                      label: const Text('Visit Website'),
                    ),
                ]),
              ],
            ),
    );
  }

  // Removed legacy per-page tabs; using _StandardProfilePage for all profiles.

  Widget _overviewTab(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Overview', style: t.titleLarge),
        const SizedBox(height: 16),
        _statsGrid(context, generator),
      ],
    );
  }

  // Removed legacy generator-specific admin tab; using _StandardProfilePage

  Widget _statsGrid(BuildContext context, PowerGenerator generator) {
    final items = [
      _Stat('Type', generator.type, Icons.bolt),
      _Stat('Capacity', generator.capacity, Icons.power),
      _Stat('Location', generator.location, Icons.location_on),
      _Stat('Total Plants', '${generator.totalPlants}', Icons.business),
      _Stat('Employees', generator.employees, Icons.people),
      _Stat('Established', generator.established, Icons.calendar_today),
      _Stat('CEO', generator.ceo, Icons.person),
      _Stat('Headquarters', generator.headquarters, Icons.location_city),
    ];
    final cross = MediaQuery.of(context).size.width >= 1024
        ? 3
        : (MediaQuery.of(context).size.width >= 768 ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.6,
      ),
      itemBuilder: (_, i) => items[i],
    );
  }

  Widget _updatesTab(BuildContext context, String entityId,
      List<ProfilePost> Function(String) getPosts) {
    return _PostsTab(
      entityId: entityId,
      category: PostCategory.update,
      getPosts: getPosts,
    );
  }

  Widget _productDesignsTab(BuildContext context, String entityId,
      List<ProfilePost> Function(String) getPosts) {
    return _PostsTab(
      entityId: entityId,
      category: PostCategory.productDesign,
      getPosts: getPosts,
    );
  }

  Widget _contactTab(BuildContext context, PowerGenerator generator) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Contact Information', style: t.titleLarge),
        const SizedBox(height: 16),
        if (generator.website.isNotEmpty)
          _ContactItem(
            icon: Icons.web,
            label: 'Website',
            value: generator.website,
            onTap: () => _launchWebsite(generator.website),
          ),
        if (generator.phone.isNotEmpty)
          _ContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: generator.phone,
            onTap: () => _launchPhone(generator.phone),
          ),
        if (generator.email.isNotEmpty)
          _ContactItem(
            icon: Icons.email,
            label: 'Email',
            value: generator.email,
            onTap: () => _launchEmail(generator.email),
          ),
        _ContactItem(
          icon: Icons.location_city,
          label: 'Headquarters',
          value: generator.headquarters,
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }
}

// Placeholder profile pages for other entities
class _TransmissionProfilePage extends StatefulWidget {
  final String transmissionId;
  const _TransmissionProfilePage({required this.transmissionId});
  @override
  State<_TransmissionProfilePage> createState() =>
      _TransmissionProfilePageState();
}

class _TransmissionProfilePageState extends State<_TransmissionProfilePage>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = StateInfoStaticData.transmissionLines.firstWhere(
      (e) => e.id == widget.transmissionId,
      orElse: () => StateInfoStaticData.transmissionLines.first,
    );

    return _StandardProfilePage(
      title: 'Transmission Profile',
      masthead: _txMasthead(context, tx),
      overviewStats: [
        _Stat('Voltage', tx.voltage, Icons.bolt),
        _Stat('Coverage', tx.coverage, Icons.public),
        _Stat(
            'Substations', '${tx.totalSubstations}', Icons.electrical_services),
        _Stat('Employees', tx.employees, Icons.people),
        _Stat('Established', tx.established, Icons.calendar_today),
        _Stat('Headquarters', tx.headquarters, Icons.location_city),
      ],
      adminName: tx.ceo,
      adminRole: 'Chief Executive Officer',
      contactItems: [
        _ContactItem(
            icon: Icons.web,
            label: 'Website',
            value: tx.website,
            onTap: () => _launchWebsite(tx.website)),
        _ContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: tx.phone,
            onTap: () => _launchPhone(tx.phone)),
        _ContactItem(
            icon: Icons.email,
            label: 'Email',
            value: tx.email,
            onTap: () => _launchEmail(tx.email)),
        _ContactItem(
            icon: Icons.location_on, label: 'Address', value: tx.address),
      ],
      postsGetter: ProfilePostsData.getTransmissionPosts,
      entityId: tx.id,
      entityType: 'Transmission Line',
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  // Legacy helper removed

  // Removed legacy per-page admin helper

  Widget _txMasthead(BuildContext context, TransmissionLine tx) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineSoft)),
            alignment: Alignment.center,
            child:
                const Icon(Icons.electric_bolt, color: Colors.blue, size: 36)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.name, style: t.headlineSmall),
          const SizedBox(height: 6),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _Meta('Voltage: ${tx.voltage}'),
            _Meta('Coverage: ${tx.coverage}'),
            _Meta(tx.headquarters),
          ]),
        ])),
      ]),
    );
  }

  // Legacy helper removed
}

class _DistributionProfilePage extends StatefulWidget {
  final String distributionId;
  final bool isEditMode;

  const _DistributionProfilePage(
      {required this.distributionId, this.isEditMode = false});
  @override
  State<_DistributionProfilePage> createState() =>
      _DistributionProfilePageState();
}

class _DistributionProfilePageState extends State<_DistributionProfilePage>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discom = StateInfoStaticData.distributionCompanies.firstWhere(
      (e) => e.id == widget.distributionId,
      orElse: () => StateInfoStaticData.distributionCompanies.first,
    );

    return _StandardProfilePage(
      title: 'Distribution Company',
      masthead: _discomMasthead(context, discom),
      overviewStats: [
        _Stat('Coverage', discom.coverage, Icons.map),
        _Stat('Customers', discom.customers, Icons.people),
        _Stat('Capacity', discom.capacity, Icons.flash_on),
        _Stat('Established', discom.established, Icons.calendar_today),
        _Stat('Address', discom.address, Icons.location_city),
      ],
      adminName: discom.director,
      adminRole: 'Director',
      contactItems: [
        _ContactItem(
            icon: Icons.web,
            label: 'Website',
            value: discom.website,
            onTap: () => _launchWebsite(discom.website)),
        _ContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: discom.phone,
            onTap: () => _launchPhone(discom.phone)),
        _ContactItem(
            icon: Icons.email,
            label: 'Email',
            value: discom.email,
            onTap: () => _launchEmail(discom.email)),
      ],
      postsGetter: ProfilePostsData.getDistributionPosts,
      entityId: discom.id,
      entityType: 'Distribution Company',
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  // Legacy helper removed

  // Removed legacy per-page admin helper
  Widget _discomMasthead(BuildContext context, DistributionCompany d) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineSoft)),
            alignment: Alignment.center,
            child: const Icon(Icons.cable, color: Colors.green, size: 36)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.name, style: t.headlineSmall),
          const SizedBox(height: 6),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _Meta(d.coverage),
            _Meta('Customers: ${d.customers}'),
            _Meta('Capacity: ${d.capacity}'),
          ]),
        ])),
      ]),
    );
  }

  // Legacy helper removed
}

class _StateProfilePage extends StatelessWidget {
  final String stateId;
  final bool isEditMode;

  const _StateProfilePage({required this.stateId, this.isEditMode = false});

  @override
  Widget build(BuildContext context) {
    final state = StateInfoStaticData.indianStates.firstWhere(
      (s) => s.id == stateId,
      orElse: () => StateInfoStaticData.indianStates.first,
    );

    return _StandardProfilePage(
      title: 'State Profile',
      masthead: _stateMasthead(context, state),
      isEditMode: isEditMode,
      overviewStats: [
        _Stat('Capital', state.capital, Icons.location_city),
        _Stat('Power Capacity', state.powerCapacity, Icons.flash_on),
        _Stat('Helpline', state.helpline, Icons.support_agent),
        _Stat('Discoms', state.discoms.toString(), Icons.account_tree),
      ],
      adminName: state.energyMinister,
      adminRole: 'Energy Minister',
      contactItems: [
        _ContactItem(
            icon: Icons.web,
            label: 'Website',
            value: state.website,
            onTap: () => _openWebsite(state.website)),
        _ContactItem(
            icon: Icons.email,
            label: 'Email',
            value: state.email,
            onTap: () => _openEmail(state.email)),
        _ContactItem(
            icon: Icons.location_on, label: 'Address', value: state.address),
      ],
      postsGetter: ProfilePostsData.getStatePosts,
      entityId: state.id,
      entityType: 'State',
    );
  }

  Future<void> _openWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}

/// Standard profile layout reused across Transmission/Distribution to mirror Generator UI
class _StandardProfilePage extends StatefulWidget {
  final String title;
  final Widget masthead;
  final List<Widget> overviewStats;
  final String adminName;
  final String adminRole;
  final List<Widget> contactItems;
  final List<ProfilePost> Function(String) postsGetter;
  final String entityId;
  final String entityType;
  final bool isEditMode;

  const _StandardProfilePage({
    required this.title,
    required this.masthead,
    required this.overviewStats,
    required this.adminName,
    required this.adminRole,
    required this.contactItems,
    required this.postsGetter,
    required this.entityId,
    required this.entityType,
    this.isEditMode = false,
  });

  @override
  State<_StandardProfilePage> createState() => _StandardProfilePageState();
}

class _StandardProfilePageState extends State<_StandardProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _showEditEntityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntityEditBottomSheet(
        title: widget.title,
        entityId: widget.entityId,
      ),
    );
  }

  void _showCustomFieldsBottomSheet(
      BuildContext context, String entityId, String entityType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomFieldsEditBottomSheet(
        entityId: entityId,
        entityType: entityType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cross = MediaQuery.of(context).size.width >= 1024
        ? 3
        : (MediaQuery.of(context).size.width >= 768 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: widget.isEditMode
            ? [
                IconButton(
                  onPressed: () => _showCustomFieldsBottomSheet(
                      context, widget.entityId, widget.entityType),
                  icon: const Icon(Icons.edit_attributes,
                      color: AppColors.primary),
                  tooltip: 'Edit Custom Fields',
                ),
                IconButton(
                  onPressed: () => _showEditEntityBottomSheet(context),
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Edit Profile',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: ContentClamp(
          child: NestedScrollView(
            headerSliverBuilder: (c, inner) => [
              SliverToBoxAdapter(child: widget.masthead),
              SliverAppBar(
                  pinned: true,
                  toolbarHeight: 56,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  backgroundColor: AppColors.surface,
                  title: TabBar(
                      controller: _tabs,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Admin'),
                        Tab(text: 'Updates'),
                        Tab(text: 'Product Designs'),
                        Tab(text: 'Contact'),
                      ])),
            ],
            body: TabBarView(controller: _tabs, children: [
              // Overview
              ListView(padding: const EdgeInsets.all(16), children: [
                Text('Overview', style: t.titleLarge),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.overviewStats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.6,
                  ),
                  itemBuilder: (_, i) => widget.overviewStats[i],
                ),
              ]),

              // Admin
              ListView(padding: const EdgeInsets.all(16), children: [
                Text('Admin', style: t.titleLarge),
                const SizedBox(height: 16),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.outlineSoft)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.person,
                                  size: 42, color: AppColors.primary)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    widget.adminName.isNotEmpty
                                        ? widget.adminName
                                        : 'Authority Name',
                                    style: t.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(widget.adminRole,
                                    style: t.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary)),
                              ])),
                        ]))),
              ]),

              // Updates
              _PostsTab(
                  entityId: widget.entityId,
                  category: PostCategory.update,
                  getPosts: widget.postsGetter),

              // Product Designs
              _PostsTab(
                  entityId: widget.entityId,
                  category: PostCategory.productDesign,
                  getPosts: widget.postsGetter),

              // Contact
              ListView(padding: const EdgeInsets.all(16), children: [
                Text('Contact Information', style: t.titleLarge),
                const SizedBox(height: 12),
                ...widget.contactItems,
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _MandalProfilePage extends StatelessWidget {
  final String mandalId;
  const _MandalProfilePage({required this.mandalId});

  @override
  Widget build(BuildContext context) {
    final state = StateInfoStaticData.indianStates
        .firstWhere((s) => s.mandals.any((m) => m.id == mandalId));
    final mandal = state.mandals.firstWhere((m) => m.id == mandalId);

    return _StandardProfilePage(
      title: 'District/Mandal',
      masthead: _mandalMasthead(context, mandal),
      overviewStats: [
        _Stat('Population', mandal.population, Icons.groups),
        _Stat('Power Demand', mandal.powerDemand, Icons.flash_on),
        _Stat('Administrator', mandal.administrator ?? 'Not available',
            Icons.badge),
      ],
      adminName: mandal.divisionController ?? 'Division Controller',
      adminRole: 'Division Controller',
      contactItems: [
        if ((mandal.website ?? '').isNotEmpty)
          _ContactItem(
              icon: Icons.web,
              label: 'Website',
              value: mandal.website!,
              onTap: () => _openWebsite(mandal.website!)),
        if ((mandal.phone ?? '').isNotEmpty)
          _ContactItem(icon: Icons.phone, label: 'Phone', value: mandal.phone!),
        if ((mandal.email ?? '').isNotEmpty)
          _ContactItem(icon: Icons.email, label: 'Email', value: mandal.email!),
        if ((mandal.officeAddress ?? '').isNotEmpty)
          _ContactItem(
              icon: Icons.location_on,
              label: 'Address',
              value: mandal.officeAddress!),
      ],
      postsGetter: ProfilePostsData.getMandalPosts,
      entityId: mandal.id,
      entityType: 'Mandal',
    );
  }

  Future<void> _openWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }
}

Widget _stateMasthead(BuildContext context, IndianState state) {
  final t = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineSoft)),
          alignment: Alignment.center,
          child: const Icon(Icons.public, color: Colors.deepPurple, size: 36)),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(state.name, style: t.headlineSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _Meta('Capital: ${state.capital}'),
          _Meta('Capacity: ${state.powerCapacity}'),
        ]),
      ])),
    ]),
  );
}

Widget _mandalMasthead(BuildContext context, Mandal mandal) {
  final t = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineSoft)),
          alignment: Alignment.center,
          child: const Icon(Icons.location_city, color: Colors.teal, size: 36)),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(mandal.name, style: t.headlineSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _Meta('Population: ${mandal.population}'),
          _Meta('Demand: ${mandal.powerDemand}'),
        ]),
      ])),
    ]),
  );
}

// Helper components for customer-facing profile layout
class _Meta extends StatelessWidget {
  final String text;
  const _Meta(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodySmall);
}

class _ClickableMetaIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _ClickableMetaIcon(this.icon, this.text, {required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Chip(label: Text(text));
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value)
        ]),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        subtitle: Text(value),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }
}

/// Posts tab widget for Updates and Product Designs
class _PostsTab extends StatefulWidget {
  final String entityId;
  final PostCategory category;
  final List<ProfilePost> Function(String) getPosts;

  const _PostsTab({
    required this.entityId,
    required this.category,
    required this.getPosts,
  });

  @override
  State<_PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<_PostsTab> {
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  List<ProfilePost> _allPosts = [];
  List<ProfilePost> _filteredPosts = [];
  final Map<String, bool> _likedPosts = {}; // Track liked posts

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      // Try to get posts from the store first, fallback to static data
      try {
        final store =
            ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
        final storePosts = store.getPostsForEntity(widget.entityId);
        if (storePosts.isNotEmpty) {
          // Convert Post to ProfilePost for compatibility
          _allPosts = storePosts
              .map((post) => ProfilePost(
                    id: post.id,
                    title: post.title,
                    content: post.content,
                    imageUrl: post.imageUrl,
                    category: post.category,
                    tags: post.tags,
                    author: post.author,
                    publishDate: post.publishDate,
                    likes: post.likes,
                    comments: post.comments,
                  ))
              .toList();
        } else {
          _allPosts = widget.getPosts(widget.entityId);
        }
      } catch (e) {
        _allPosts = widget.getPosts(widget.entityId);
      }
      _filteredPosts = _allPosts;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFiltersChanged(List<String> filters) {
    setState(() {
      _selectedFilters = filters;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<ProfilePost> filtered = _allPosts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((post) {
        return post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            post.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply tag filters
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((post) {
        return _selectedFilters.any((filter) => post.tags
            .any((tag) => tag.toLowerCase().contains(filter.toLowerCase())));
      }).toList();
    }

    setState(() {
      _filteredPosts = filtered;
    });
  }

  void _toggleLike(String postId) {
    setState(() {
      _likedPosts[postId] = !(_likedPosts[postId] ?? false);
    });
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    showEnhancedPostEditor(
      context: context,
      postId: DateTime.now().millisecondsSinceEpoch.toString(),
      author: 'Current User', // TODO: Get from auth context
      onSave: (post) {
        // Convert Post to ProfilePost for compatibility
        final profilePost = ProfilePost(
          id: post.id,
          title: post.title,
          content: post.content,
          imageUrl: post.imageUrl ?? '',
          category: widget.category,
          tags: post.tags,
          author: post.author,
          publishDate: DateTime.tryParse(post.time) ?? DateTime.now(),
          likes: 0,
          comments: 0,
          imageUrls: post.imageUrls,
          pdfUrls: post.pdfUrls,
        );
        
        // Update the store
        try {
          final store = ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
          store.addPostToEntity(widget.entityId, profilePost);
        } catch (e) {
          // Fallback if store is not available
        }
        
        _loadPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New post created: ${post.title}')),
        );
      },
    );
  }

  void _editPost(ProfilePost post) {
    // Convert ProfilePost to Post for the enhanced editor
    final postForEditor = Post(
      id: post.id,
      title: post.title,
      content: post.content,
      author: post.author,
      time: post.publishDate.toIso8601String(),
      tags: post.tags,
      imageUrl: post.imageUrl,
      imageUrls: post.imageUrls,
      pdfUrls: post.pdfUrls,
    );
    
    showEnhancedPostEditor(
      context: context,
      initialPost: postForEditor,
      postId: post.id,
      author: post.author,
      onSave: (updatedPost) {
        // Convert back to ProfilePost and update
        final updatedProfilePost = ProfilePost(
          id: updatedPost.id,
          title: updatedPost.title,
          content: updatedPost.content,
          imageUrl: updatedPost.imageUrl ?? '',
          category: post.category,
          tags: updatedPost.tags,
          author: updatedPost.author,
          publishDate: DateTime.tryParse(updatedPost.time) ?? DateTime.now(),
          likes: post.likes,
          comments: post.comments,
          imageUrls: updatedPost.imageUrls,
          pdfUrls: updatedPost.pdfUrls,
        );
        
        // Update the store
        try {
          final store = ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
          store.updatePostInEntity(widget.entityId, updatedProfilePost);
        } catch (e) {
          // Fallback if store is not available
        }
        
        _loadPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated: ${updatedPost.title}')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search and Filter (NOT sticky)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ProfileSearchFilter(
                category: widget.category,
                onSearchChanged: _onSearchChanged,
                onFiltersChanged: _onFiltersChanged,
              ),
            ),

            // Posts List
            _filteredPosts.isEmpty
                ? _buildEmptyState()
                : _buildResponsivePostsGrid(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostBottomSheet(context),
        backgroundColor: AppColors.primary,
        tooltip:
            'Create New ${widget.category == PostCategory.update ? 'Update' : 'Product Design'}',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildResponsivePostsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        int crossAxisCount;
        double horizontalPadding;
        const double crossSpacing = 12;

        if (constraints.maxWidth >= 1200) {
          // Desktop - single column as requested
          crossAxisCount = 1;
          horizontalPadding = 24;
        } else if (constraints.maxWidth >= 768) {
          // Tablet - 2 columns
          crossAxisCount = 2;
          horizontalPadding = 20;
        } else {
          // Mobile - 1 column
          crossAxisCount = 1;
          horizontalPadding = 16;
        }

        // Masonry grid doesn't need childAspectRatio

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: crossSpacing,
            crossAxisSpacing: crossSpacing,
            itemCount: _filteredPosts.length,
            itemBuilder: (context, index) {
              final post = _filteredPosts[index];
              return ProfilePostCard(
                post: post,
                isLiked: _likedPosts[post.id] ?? false,
                onTap: () => _showPostDetail(post),
                onLike: () => _toggleLike(post.id),
                onEdit: () => _editPost(post),
                showEditButton: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.category == PostCategory.update
                ? Icons.update
                : Icons.design_services,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilters.isNotEmpty
                ? 'No posts found matching your criteria'
                : 'No ${widget.category.displayName.toLowerCase()} available',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty || _selectedFilters.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilters = [];
                  _filteredPosts = _allPosts;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _showPostDetail(ProfilePost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalBottomSheet(post: post),
    );
  }
}

/// Bottom Sheet for Editing Flow Properties
class _FlowEditBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _FlowEditBottomSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  State<_FlowEditBottomSheet> createState() => _FlowEditBottomSheetState();
}

class _FlowEditBottomSheetState extends State<_FlowEditBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _subtitleController = TextEditingController(text: widget.subtitle);
    _selectedColor = widget.color;
    _selectedIcon = widget.icon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
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
                const Text(
                  'Edit Flow',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  const Text(
                    'Flow Title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter flow title',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subtitle Field
                  const Text(
                    'Flow Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subtitleController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter flow description',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Color Selection
                  const Text(
                    'Flow Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      Colors.orange,
                      Colors.blue,
                      Colors.green,
                      Colors.purple,
                      Colors.red,
                      Colors.teal,
                    ]
                        .map((color) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == color
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: _selectedColor == color
                                    ? const Icon(Icons.check,
                                        color: Colors.white)
                                    : null,
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Icon Selection
                  const Text(
                    'Flow Icon',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      Icons.bolt,
                      Icons.map,
                      Icons.flash_on,
                      Icons.power,
                      Icons.electrical_services,
                      Icons.battery_charging_full,
                    ]
                        .map((icon) => GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _selectedIcon == icon
                                      ? _selectedColor.withOpacity(0.1)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedIcon == icon
                                        ? _selectedColor
                                        : AppColors.outlineSoft,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: _selectedIcon == icon
                                      ? _selectedColor
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
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
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Flow "${_titleController.text}" updated successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
  }
}

/// Bottom Sheet for Editing Generators
class _GeneratorsEditBottomSheet extends StatefulWidget {
  const _GeneratorsEditBottomSheet();

  @override
  State<_GeneratorsEditBottomSheet> createState() =>
      _GeneratorsEditBottomSheetState();
}

class _GeneratorsEditBottomSheetState
    extends State<_GeneratorsEditBottomSheet> {
  List<String> _selectedGenerators = [];
  String _searchQuery = '';
  List<SearchFilter> _filters = [];
  List<PowerGenerator> _filteredGenerators = [];

  @override
  void initState() {
    super.initState();
    _filteredGenerators = ProviderScope.containerOf(context)
        .read(stateInfoEditStoreProvider)
        .powerGenerators;
  }

  void _updateSearchAndFilters([StateInfoEditStore? store]) {
    final StateInfoEditStore storeInstance = store ??
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    setState(() {
      _filteredGenerators = storeInstance.powerGenerators;

      // Apply search
      if (_searchQuery.isNotEmpty) {
        _filteredGenerators = _filteredGenerators.where((generator) {
          return generator.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              generator.type
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              generator.location
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }).toList();
      }

      // Apply filters
      for (final filter in _filters) {
        _filteredGenerators = _filteredGenerators.where((generator) {
          dynamic fieldValue;
          switch (filter.field) {
            case 'name':
              fieldValue = generator.name;
              break;
            case 'type':
              fieldValue = generator.type;
              break;
            case 'location':
              fieldValue = generator.location;
              break;
            case 'capacity':
              fieldValue = generator.capacity;
              break;
            case 'established':
              fieldValue = generator.established;
              break;
            case 'ceo':
              fieldValue = generator.ceo;
              break;
            case 'headquarters':
              fieldValue = generator.headquarters;
              break;
            case 'phone':
              fieldValue = generator.phone;
              break;
            case 'email':
              fieldValue = generator.email;
              break;
            case 'website':
              fieldValue = generator.website;
              break;
            default:
              return true;
          }

          return _evaluateFilter(fieldValue, filter);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                const Text(
                  'Manage Power Generators',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AdvancedSearchFilter(
              entityType: 'Power Generators',
              availableFields: BulkOperationsManager.getSearchFilterFields(
                  'Power Generator'),
              initialSearchQuery: _searchQuery,
              initialFilters: _filters,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
                _updateSearchAndFilters();
              },
              onFiltersChanged: (filters) {
                setState(() => _filters = filters);
                _updateSearchAndFilters();
              },
            ),
          ),

          // Bulk Operations
          BulkOperations(
            selectedItems: _selectedGenerators,
            entityType: 'Power Generators',
            availableOperations:
                BulkOperationsManager.getAvailableOperations('Power Generator'),
            onSelectionChanged: (selected) {
              setState(() => _selectedGenerators = selected);
            },
            onBulkOperation: _handleBulkOperation,
          ),

          // Content
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final store = ref.watch(stateInfoEditStoreProvider);
                // Update filtered generators when store changes
                _updateSearchAndFilters(store);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filteredGenerators.length,
                  itemBuilder: (context, index) {
                    final generator = _filteredGenerators[index];
                    final isSelected =
                        _selectedGenerators.contains(generator.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedGenerators.add(generator.id);
                              } else {
                                _selectedGenerators.remove(generator.id);
                              }
                            });
                          },
                        ),
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.1),
                              radius: 16,
                              child: const Icon(Icons.bolt,
                                  color: Colors.orange, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(generator.name),
                                  Text(
                                      '${generator.type} • ${generator.capacity}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _editGenerator(generator),
                              icon: const Icon(Icons.edit,
                                  color: AppColors.primary),
                              tooltip: 'Edit Generator',
                            ),
                            IconButton(
                              onPressed: () => _deleteGenerator(generator),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Generator',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewGenerator,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New Generator',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editGenerator(PowerGenerator generator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GeneratorEditBottomSheet(generator: generator),
    );
  }

  void _deleteGenerator(PowerGenerator generator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Generator'),
        content: Text('Are you sure you want to delete ${generator.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              store.deletePowerGenerator(generator.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${generator.name} deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewGenerator() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    final newId = store.generateId();

    final newGenerator = PowerGenerator(
      id: newId,
      name: 'New Power Generator',
      type: 'Thermal',
      capacity: '0 MW',
      location: 'India',
      logo: 'https://via.placeholder.com/100',
      established: '2024',
      founder: 'Unknown',
      ceo: 'Unknown',
      ceoPhoto: 'https://via.placeholder.com/100',
      headquarters: 'India',
      phone: '',
      email: '',
      website: '',
      description: 'New power generator',
      totalPlants: 0,
      employees: '0',
      revenue: '₹0',
      posts: const [],
      productDesigns: const [],
    );

    store.addPowerGenerator(newGenerator);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newGenerator.name} added successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleBulkOperation(List<String> selectedIds, BulkOperation operation) {
    switch (operation.type) {
      case BulkOperationType.edit:
        _showBulkEditBottomSheet(selectedIds);
        break;
      case BulkOperationType.delete:
        _confirmBulkDelete(selectedIds);
        break;
      case BulkOperationType.duplicate:
        _bulkDuplicate(selectedIds);
        break;
      case BulkOperationType.export:
        _bulkExport(selectedIds);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${operation.label} - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  void _showBulkEditBottomSheet(List<String> selectedIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BulkEditBottomSheet(
        selectedItems: selectedIds,
        entityType: 'Power Generators',
        availableFields:
            BulkOperationsManager.getAvailableFields('Power Generator'),
        onSave: (ids, changes) {
          final store = ProviderScope.containerOf(context)
              .read(stateInfoEditStoreProvider);
          for (final id in ids) {
            final generator = store.getPowerGeneratorById(id);
            if (generator != null) {
              final updatedGenerator = PowerGenerator(
                id: generator.id,
                name: changes['name'] ?? generator.name,
                type: changes['type'] ?? generator.type,
                capacity: generator.capacity,
                location: changes['location'] ?? generator.location,
                logo: generator.logo,
                established: generator.established,
                founder: generator.founder,
                ceo: changes['ceo'] ?? generator.ceo,
                ceoPhoto: generator.ceoPhoto,
                headquarters: changes['headquarters'] ?? generator.headquarters,
                phone: changes['phone'] ?? generator.phone,
                email: changes['email'] ?? generator.email,
                website: changes['website'] ?? generator.website,
                description: generator.description,
                totalPlants: generator.totalPlants,
                employees: generator.employees,
                revenue: generator.revenue,
                posts: generator.posts,
                productDesigns: generator.productDesigns,
              );
              store.updatePowerGenerator(updatedGenerator);
            }
          }
          setState(() => _selectedGenerators.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${ids.length} generators updated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  void _confirmBulkDelete(List<String> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Generators'),
        content: Text(
            'Are you sure you want to delete ${selectedIds.length} generator${selectedIds.length == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              for (final id in selectedIds) {
                store.deletePowerGenerator(id);
              }
              setState(() => _selectedGenerators.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${selectedIds.length} generators deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _bulkDuplicate(List<String> selectedIds) {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    int duplicated = 0;

    for (final id in selectedIds) {
      final generator = store.getPowerGeneratorById(id);
      if (generator != null) {
        final newId = store.generateId();
        final duplicatedGenerator = PowerGenerator(
          id: newId,
          name: '${generator.name} (Copy)',
          type: generator.type,
          capacity: generator.capacity,
          location: generator.location,
          logo: generator.logo,
          established: generator.established,
          founder: generator.founder,
          ceo: generator.ceo,
          ceoPhoto: generator.ceoPhoto,
          headquarters: generator.headquarters,
          phone: generator.phone,
          email: generator.email,
          website: generator.website,
          description: generator.description,
          totalPlants: generator.totalPlants,
          employees: generator.employees,
          revenue: generator.revenue,
          posts: generator.posts,
          productDesigns: generator.productDesigns,
        );
        store.addPowerGenerator(duplicatedGenerator);
        duplicated++;
      }
    }

    setState(() => _selectedGenerators.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$duplicated generators duplicated successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _bulkExport(List<String> selectedIds) {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export ${selectedIds.length} generators - Coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  bool _evaluateFilter(dynamic fieldValue, SearchFilter filter) {
    final value = fieldValue?.toString() ?? '';
    final filterValue = filter.value;

    switch (filter.operator) {
      case SearchOperator.contains:
        return value.toLowerCase().contains(filterValue.toLowerCase());
      case SearchOperator.equals:
        return value.toLowerCase() == filterValue.toLowerCase();
      case SearchOperator.startsWith:
        return value.toLowerCase().startsWith(filterValue.toLowerCase());
      case SearchOperator.endsWith:
        return value.toLowerCase().endsWith(filterValue.toLowerCase());
      case SearchOperator.greaterThan:
        return _compareNumbers(value, filterValue) > 0;
      case SearchOperator.lessThan:
        return _compareNumbers(value, filterValue) < 0;
      case SearchOperator.isEmpty:
        return value.isEmpty;
      case SearchOperator.isNotEmpty:
        return value.isNotEmpty;
    }
  }

  int _compareNumbers(String a, String b) {
    final numA = double.tryParse(a.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    final numB = double.tryParse(b.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    return numA.compareTo(numB);
  }
}

/// Bottom Sheet for Editing Transmission Lines
class _TransmissionEditBottomSheet extends StatefulWidget {
  const _TransmissionEditBottomSheet();

  @override
  State<_TransmissionEditBottomSheet> createState() =>
      _TransmissionEditBottomSheetState();
}

class _TransmissionEditBottomSheetState
    extends State<_TransmissionEditBottomSheet> {
  List<String> _selectedTransmissions = [];
  String _searchQuery = '';
  List<SearchFilter> _filters = [];
  List<TransmissionLine> _filteredTransmissions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransmissions = ProviderScope.containerOf(context)
        .read(stateInfoEditStoreProvider)
        .transmissionLines;
  }

  void _updateSearchAndFilters() {
    setState(() {
      final store =
          ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
      _filteredTransmissions = store.transmissionLines;

      // Apply search
      if (_searchQuery.isNotEmpty) {
        _filteredTransmissions = _filteredTransmissions.where((transmission) {
          return transmission.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              transmission.voltage
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              transmission.coverage
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }).toList();
      }

      // Apply filters
      for (final filter in _filters) {
        _filteredTransmissions = _filteredTransmissions.where((transmission) {
          dynamic fieldValue;
          switch (filter.field) {
            case 'name':
              fieldValue = transmission.name;
              break;
            case 'voltage':
              fieldValue = transmission.voltage;
              break;
            case 'coverage':
              fieldValue = transmission.coverage;
              break;
            case 'headquarters':
              fieldValue = transmission.headquarters;
              break;
            case 'ceo':
              fieldValue = transmission.ceo;
              break;
            default:
              return true;
          }

          return _evaluateFilter(fieldValue, filter);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                const Text(
                  'Manage Transmission Lines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AdvancedSearchFilter(
              entityType: 'Transmission Lines',
              availableFields: BulkOperationsManager.getSearchFilterFields(
                  'Transmission Line'),
              initialSearchQuery: _searchQuery,
              initialFilters: _filters,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
                _updateSearchAndFilters();
              },
              onFiltersChanged: (filters) {
                setState(() => _filters = filters);
                _updateSearchAndFilters();
              },
            ),
          ),

          // Bulk Operations
          BulkOperations(
            selectedItems: _selectedTransmissions,
            entityType: 'Transmission Lines',
            availableOperations: BulkOperationsManager.getAvailableOperations(
                'Transmission Line'),
            onSelectionChanged: (selected) {
              setState(() => _selectedTransmissions = selected);
            },
            onBulkOperation: _handleBulkOperation,
          ),

          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filteredTransmissions.length,
              itemBuilder: (context, index) {
                final transmission = _filteredTransmissions[index];
                final isSelected =
                    _selectedTransmissions.contains(transmission.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedTransmissions.add(transmission.id);
                          } else {
                            _selectedTransmissions.remove(transmission.id);
                          }
                        });
                      },
                    ),
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          radius: 16,
                          child: const Icon(Icons.electrical_services,
                              color: Colors.blue, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transmission.name),
                              Text(
                                  '${transmission.voltage} • ${transmission.coverage}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editTransmission(transmission),
                          icon:
                              const Icon(Icons.edit, color: AppColors.primary),
                          tooltip: 'Edit Transmission',
                        ),
                        IconButton(
                          onPressed: () => _deleteTransmission(transmission),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Transmission',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewTransmission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add New Transmission Line'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editTransmission(TransmissionLine transmission) {
    // TODO: Implement edit transmission functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${transmission.name} - Coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteTransmission(TransmissionLine transmission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transmission Line'),
        content: Text('Are you sure you want to delete ${transmission.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              store.deleteTransmissionLine(transmission.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${transmission.name} deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewTransmission() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    final newId = store.generateId();

    final newTransmission = TransmissionLine(
      id: newId,
      name: 'New Transmission Line',
      voltage: '765 kV',
      coverage: 'National',
      headquarters: 'India',
      logo: 'https://via.placeholder.com/100',
      established: '2024',
      founder: 'Unknown',
      ceo: 'Unknown',
      ceoPhoto: 'https://via.placeholder.com/100',
      address: 'India',
      phone: '',
      email: '',
      website: '',
      description: 'New transmission line',
      totalSubstations: 0,
      employees: '0',
      revenue: '₹0',
      posts: const [],
      productDesigns: const [],
    );

    store.addTransmissionLine(newTransmission);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newTransmission.name} added successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleBulkOperation(List<String> selectedIds, BulkOperation operation) {
    switch (operation.type) {
      case BulkOperationType.edit:
        // TODO: Implement bulk edit for transmissions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bulk edit transmissions - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
        break;
      case BulkOperationType.delete:
        _confirmBulkDelete(selectedIds);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${operation.label} - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  void _confirmBulkDelete(List<String> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transmission Lines'),
        content: Text(
            'Are you sure you want to delete ${selectedIds.length} transmission line${selectedIds.length == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              for (final id in selectedIds) {
                store.deleteTransmissionLine(id);
              }
              setState(() => _selectedTransmissions.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${selectedIds.length} transmission lines deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _evaluateFilter(dynamic fieldValue, SearchFilter filter) {
    final value = fieldValue?.toString() ?? '';
    final filterValue = filter.value;

    switch (filter.operator) {
      case SearchOperator.contains:
        return value.toLowerCase().contains(filterValue.toLowerCase());
      case SearchOperator.equals:
        return value.toLowerCase() == filterValue.toLowerCase();
      case SearchOperator.startsWith:
        return value.toLowerCase().startsWith(filterValue.toLowerCase());
      case SearchOperator.endsWith:
        return value.toLowerCase().endsWith(filterValue.toLowerCase());
      case SearchOperator.greaterThan:
        return _compareNumbers(value, filterValue) > 0;
      case SearchOperator.lessThan:
        return _compareNumbers(value, filterValue) < 0;
      case SearchOperator.isEmpty:
        return value.isEmpty;
      case SearchOperator.isNotEmpty:
        return value.isNotEmpty;
    }
  }

  int _compareNumbers(String a, String b) {
    final numA = double.tryParse(a.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    final numB = double.tryParse(b.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    return numA.compareTo(numB);
  }
}

/// Bottom Sheet for Editing Distribution Companies
class _DistributionEditBottomSheet extends StatefulWidget {
  const _DistributionEditBottomSheet();

  @override
  State<_DistributionEditBottomSheet> createState() =>
      _DistributionEditBottomSheetState();
}

class _DistributionEditBottomSheetState
    extends State<_DistributionEditBottomSheet> {
  List<String> _selectedDistributions = [];
  String _searchQuery = '';
  List<SearchFilter> _filters = [];
  List<DistributionCompany> _filteredDistributions = [];

  @override
  void initState() {
    super.initState();
    _filteredDistributions = ProviderScope.containerOf(context)
        .read(stateInfoEditStoreProvider)
        .distributionCompanies;
  }

  void _updateSearchAndFilters() {
    setState(() {
      final store =
          ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
      _filteredDistributions = store.distributionCompanies;

      // Apply search
      if (_searchQuery.isNotEmpty) {
        _filteredDistributions = _filteredDistributions.where((distribution) {
          return distribution.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              distribution.coverage
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              distribution.director
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }).toList();
      }

      // Apply filters
      for (final filter in _filters) {
        _filteredDistributions = _filteredDistributions.where((distribution) {
          dynamic fieldValue;
          switch (filter.field) {
            case 'name':
              fieldValue = distribution.name;
              break;
            case 'coverage':
              fieldValue = distribution.coverage;
              break;
            case 'director':
              fieldValue = distribution.director;
              break;
            case 'customers':
              fieldValue = distribution.customers;
              break;
            case 'capacity':
              fieldValue = distribution.capacity;
              break;
            default:
              return true;
          }

          return _evaluateFilter(fieldValue, filter);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                const Text(
                  'Manage Distribution Companies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AdvancedSearchFilter(
              entityType: 'Distribution Companies',
              availableFields: BulkOperationsManager.getSearchFilterFields(
                  'Distribution Company'),
              initialSearchQuery: _searchQuery,
              initialFilters: _filters,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
                _updateSearchAndFilters();
              },
              onFiltersChanged: (filters) {
                setState(() => _filters = filters);
                _updateSearchAndFilters();
              },
            ),
          ),

          // Bulk Operations
          BulkOperations(
            selectedItems: _selectedDistributions,
            entityType: 'Distribution Companies',
            availableOperations: BulkOperationsManager.getAvailableOperations(
                'Distribution Company'),
            onSelectionChanged: (selected) {
              setState(() => _selectedDistributions = selected);
            },
            onBulkOperation: _handleBulkOperation,
          ),

          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filteredDistributions.length,
              itemBuilder: (context, index) {
                final distribution = _filteredDistributions[index];
                final isSelected =
                    _selectedDistributions.contains(distribution.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedDistributions.add(distribution.id);
                          } else {
                            _selectedDistributions.remove(distribution.id);
                          }
                        });
                      },
                    ),
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          radius: 16,
                          child: const Icon(Icons.account_tree,
                              color: Colors.purple, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(distribution.name),
                              Text(
                                  '${distribution.coverage} • ${distribution.customers} customers'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editDistribution(distribution),
                          icon:
                              const Icon(Icons.edit, color: AppColors.primary),
                          tooltip: 'Edit Distribution',
                        ),
                        IconButton(
                          onPressed: () => _deleteDistribution(distribution),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Distribution',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewDistribution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add New Distribution Company'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editDistribution(DistributionCompany distribution) {
    // TODO: Implement edit distribution functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${distribution.name} - Coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteDistribution(DistributionCompany distribution) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Distribution Company'),
        content: Text('Are you sure you want to delete ${distribution.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              store.deleteDistributionCompany(distribution.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${distribution.name} deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewDistribution() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    final newId = store.generateId();

    final newDistribution = DistributionCompany(
      id: newId,
      name: 'New Distribution Company',
      logo: 'https://via.placeholder.com/100',
      established: '2024',
      director: 'Unknown',
      directorPhoto: 'https://via.placeholder.com/100',
      address: 'India',
      phone: '',
      email: '',
      website: '',
      coverage: 'Regional',
      customers: '0',
      capacity: '0 MW',
      description: 'New distribution company',
      posts: const [],
      productDesigns: const [],
    );

    store.addDistributionCompany(newDistribution);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newDistribution.name} added successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleBulkOperation(List<String> selectedIds, BulkOperation operation) {
    switch (operation.type) {
      case BulkOperationType.edit:
        // TODO: Implement bulk edit for distributions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bulk edit distributions - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
        break;
      case BulkOperationType.delete:
        _confirmBulkDelete(selectedIds);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${operation.label} - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  void _confirmBulkDelete(List<String> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Distribution Companies'),
        content: Text(
            'Are you sure you want to delete ${selectedIds.length} distribution compan${selectedIds.length == 1 ? 'y' : 'ies'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              for (final id in selectedIds) {
                store.deleteDistributionCompany(id);
              }
              setState(() => _selectedDistributions.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${selectedIds.length} distribution companies deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _evaluateFilter(dynamic fieldValue, SearchFilter filter) {
    final value = fieldValue?.toString() ?? '';
    final filterValue = filter.value;

    switch (filter.operator) {
      case SearchOperator.contains:
        return value.toLowerCase().contains(filterValue.toLowerCase());
      case SearchOperator.equals:
        return value.toLowerCase() == filterValue.toLowerCase();
      case SearchOperator.startsWith:
        return value.toLowerCase().startsWith(filterValue.toLowerCase());
      case SearchOperator.endsWith:
        return value.toLowerCase().endsWith(filterValue.toLowerCase());
      case SearchOperator.greaterThan:
        return _compareNumbers(value, filterValue) > 0;
      case SearchOperator.lessThan:
        return _compareNumbers(value, filterValue) < 0;
      case SearchOperator.isEmpty:
        return value.isEmpty;
      case SearchOperator.isNotEmpty:
        return value.isNotEmpty;
    }
  }

  int _compareNumbers(String a, String b) {
    final numA = double.tryParse(a.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    final numB = double.tryParse(b.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
    return numA.compareTo(numB);
  }
}

/// Bottom Sheet for Editing States
class _StatesEditBottomSheet extends StatefulWidget {
  const _StatesEditBottomSheet();

  @override
  State<_StatesEditBottomSheet> createState() => _StatesEditBottomSheetState();
}

class _StatesEditBottomSheetState extends State<_StatesEditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                const Text(
                  'Manage Indian States',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider)
                  .indianStates
                  .length,
              itemBuilder: (context, index) {
                final store = ProviderScope.containerOf(context)
                    .read(stateInfoEditStoreProvider);
                final state = store.indianStates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.location_on, color: Colors.blue),
                    ),
                    title: Text(state.name),
                    subtitle: Text('${state.mandals.length} districts'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editState(state),
                          icon:
                              const Icon(Icons.edit, color: AppColors.primary),
                          tooltip: 'Edit State',
                        ),
                        IconButton(
                          onPressed: () => _deleteState(state),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete State',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewState,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New State',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editState(IndianState state) {
    // Open entity edit bottom sheet for states
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntityEditBottomSheet(
        title: 'State Profile',
        entityId: state.id,
      ),
    );
  }

  void _deleteState(IndianState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete State'),
        content: Text('Are you sure you want to delete ${state.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              store.deleteIndianState(state.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.name} deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewState() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    final newId = store.generateId();

    final newState = IndianState(
      id: newId,
      name: 'New State',
      capital: 'New Capital',
      powerCapacity: '0 MW',
      discoms: 0,
      logo: 'https://via.placeholder.com/100',
      address: 'India',
      website: '',
      email: '',
      helpline: '',
      chiefMinister: 'Unknown',
      chiefMinisterPhoto: 'https://via.placeholder.com/100',
      energyMinister: 'Unknown',
      energyMinisterPhoto: 'https://via.placeholder.com/100',
      energyMix: const EnergyMix(
        thermal: 0,
        hydro: 0,
        nuclear: 0,
        renewable: 0,
      ),
      discomsList: const [],
      posts: const [],
      mandals: const [],
      productDesigns: const [],
    );

    store.addIndianState(newState);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newState.name} added successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Bottom Sheet for Editing Mandals
class _MandalsEditBottomSheet extends StatefulWidget {
  final String? selectedState;

  const _MandalsEditBottomSheet({this.selectedState});

  @override
  State<_MandalsEditBottomSheet> createState() =>
      _MandalsEditBottomSheetState();
}

class _MandalsEditBottomSheetState extends State<_MandalsEditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final mandals = widget.selectedState != null
        ? StateInfoStaticData.indianStates
            .firstWhere((s) => s.id == widget.selectedState,
                orElse: () => StateInfoStaticData.indianStates.first)
            .mandals
        : <Mandal>[];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                Text(
                  'Manage Districts/Mandals${widget.selectedState != null ? ' in ${StateInfoStaticData.indianStates.firstWhere((s) => s.id == widget.selectedState).name}' : ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: mandals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          widget.selectedState == null
                              ? 'Please select a state first'
                              : 'No districts/mandals found',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: mandals.length,
                    itemBuilder: (context, index) {
                      final mandal = mandals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.location_city,
                                color: Colors.green),
                          ),
                          title: Text(mandal.name),
                          subtitle:
                              Text('${mandal.discoms?.length ?? 0} DISCOMs'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _editMandal(mandal),
                                icon: const Icon(Icons.edit,
                                    color: AppColors.primary),
                                tooltip: 'Edit District/Mandal',
                              ),
                              IconButton(
                                onPressed: () => _deleteMandal(mandal),
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete District/Mandal',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.selectedState != null ? _addNewMandal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New District/Mandal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editMandal(Mandal mandal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${mandal.name} - Coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteMandal(Mandal mandal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete District/Mandal'),
        content: Text('Are you sure you want to delete ${mandal.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${mandal.name} deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewMandal() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    final newId = store.generateId();

    final newMandal = Mandal(
      id: newId,
      name: 'New District/Mandal',
      population: '0',
      powerDemand: '0 MW',
      discoms: const [],
    );

    store.addMandal(newMandal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newMandal.name} added successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Bottom Sheet for Editing DISCOMs
class _DiscomsEditBottomSheet extends StatefulWidget {
  const _DiscomsEditBottomSheet();

  @override
  State<_DiscomsEditBottomSheet> createState() =>
      _DiscomsEditBottomSheetState();
}

class _DiscomsEditBottomSheetState extends State<_DiscomsEditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                const Text(
                  'Manage DISCOMs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider)
                  .distributionCompanies
                  .length,
              itemBuilder: (context, index) {
                final store = ProviderScope.containerOf(context)
                    .read(stateInfoEditStoreProvider);
                final discom = store.distributionCompanies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      child: const Icon(Icons.electrical_services,
                          color: Colors.purple),
                    ),
                    title: Text(discom.name),
                    subtitle: const Text('Distribution Company'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editDiscom(discom),
                          icon:
                              const Icon(Icons.edit, color: AppColors.primary),
                          tooltip: 'Edit DISCOM',
                        ),
                        IconButton(
                          onPressed: () => _deleteDiscom(discom),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete DISCOM',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewDiscom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New DISCOM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editDiscom(DistributionCompany discom) {
    // Open entity edit bottom sheet for DISCOMs
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntityEditBottomSheet(
        title: 'DISCOM Profile',
        entityId: discom.id,
      ),
    );
  }

  void _deleteDiscom(DistributionCompany discom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete DISCOM'),
        content: Text('Are you sure you want to delete ${discom.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final store = ProviderScope.containerOf(context)
                  .read(stateInfoEditStoreProvider);
              store.deleteDistributionCompany(discom.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${discom.name} deleted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewDiscom() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    final newId = store.generateId();

    final newDiscom = DistributionCompany(
      id: newId,
      name: 'New DISCOM',
      logo: 'https://via.placeholder.com/100',
      established: '2024',
      director: 'Unknown',
      directorPhoto: 'https://via.placeholder.com/100',
      address: 'India',
      phone: '',
      email: '',
      website: '',
      coverage: 'Regional',
      customers: '0',
      capacity: '0 MW',
      description: 'New distribution company',
      posts: const [],
      productDesigns: const [],
    );

    store.addDistributionCompany(newDiscom);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newDiscom.name} added successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Bottom Sheet for Editing Generator Profile
class _GeneratorEditBottomSheet extends StatefulWidget {
  final PowerGenerator generator;

  const _GeneratorEditBottomSheet({required this.generator});

  @override
  State<_GeneratorEditBottomSheet> createState() =>
      _GeneratorEditBottomSheetState();
}

class _GeneratorEditBottomSheetState extends State<_GeneratorEditBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _ceoController;
  late TextEditingController _headquartersController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.generator.name);
    _descriptionController =
        TextEditingController(text: widget.generator.description);
    _locationController =
        TextEditingController(text: widget.generator.location);
    _phoneController = TextEditingController(text: widget.generator.phone);
    _emailController = TextEditingController(text: widget.generator.email);
    _websiteController = TextEditingController(text: widget.generator.website);
    _ceoController = TextEditingController(text: widget.generator.ceo);
    _headquartersController =
        TextEditingController(text: widget.generator.headquarters);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _ceoController.dispose();
    _headquartersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                Text(
                  'Edit ${widget.generator.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contact Information Section
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Leadership Section
                  const Text(
                    'Leadership',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _ceoController,
                    decoration: const InputDecoration(
                      labelText: 'CEO Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _headquartersController,
                    decoration: const InputDecoration(
                      labelText: 'Headquarters',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
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
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);

    // Create updated generator with new values
    final updatedGenerator = PowerGenerator(
      id: widget.generator.id,
      name: _nameController.text,
      type: widget.generator.type,
      capacity: widget.generator.capacity,
      location: _locationController.text,
      logo: widget.generator.logo,
      established: widget.generator.established,
      founder: widget.generator.founder,
      ceo: _ceoController.text,
      ceoPhoto: widget.generator.ceoPhoto,
      headquarters: _headquartersController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      website: _websiteController.text,
      description: _descriptionController.text,
      totalPlants: widget.generator.totalPlants,
      employees: widget.generator.employees,
      revenue: widget.generator.revenue,
      posts: widget.generator.posts,
      productDesigns: widget.generator.productDesigns,
    );

    // Update in store
    store.updatePowerGenerator(updatedGenerator);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameController.text} profile updated successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
  }
}

/// Bottom Sheet for Editing Entity Profiles (States, DISCOMs, etc.)
class _EntityEditBottomSheet extends StatefulWidget {
  final String title;
  final String entityId;

  const _EntityEditBottomSheet({
    required this.title,
    required this.entityId,
  });

  @override
  State<_EntityEditBottomSheet> createState() => _EntityEditBottomSheetState();
}

class _EntityEditBottomSheetState extends State<_EntityEditBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Entity Name');
    _descriptionController = TextEditingController(text: 'Entity Description');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
                Text(
                  'Edit ${widget.title}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Additional Fields Section
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Location/Region',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Contact Information',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
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
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);

    // Determine the entity type and update accordingly
    if (widget.title.contains('State')) {
      final state = store.getIndianStateById(widget.entityId);
      if (state != null) {
        final updatedState = IndianState(
          id: state.id,
          name: _nameController.text,
          capital: state.capital,
          powerCapacity: state.powerCapacity,
          discoms: state.discoms,
          logo: state.logo,
          address: _descriptionController.text,
          website: state.website,
          email: state.email,
          helpline: state.helpline,
          chiefMinister: state.chiefMinister,
          chiefMinisterPhoto: state.chiefMinisterPhoto,
          energyMinister: state.energyMinister,
          energyMinisterPhoto: state.energyMinisterPhoto,
          energyMix: state.energyMix,
          discomsList: state.discomsList,
          posts: state.posts,
          mandals: state.mandals,
          productDesigns: state.productDesigns,
        );
        store.updateIndianState(updatedState);
      }
    } else if (widget.title.contains('DISCOM')) {
      final discom = store.getDistributionCompanyById(widget.entityId);
      if (discom != null) {
        final updatedDiscom = DistributionCompany(
          id: discom.id,
          name: _nameController.text,
          logo: discom.logo,
          established: discom.established,
          director: discom.director,
          directorPhoto: discom.directorPhoto,
          address: _descriptionController.text,
          phone: discom.phone,
          email: discom.email,
          website: discom.website,
          coverage: discom.coverage,
          customers: discom.customers,
          capacity: discom.capacity,
          description: _descriptionController.text,
          posts: discom.posts,
          productDesigns: discom.productDesigns,
        );
        store.updateDistributionCompany(updatedDiscom);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} updated successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
  }
}

/// Bottom Sheet for Editing Custom Fields
class _CustomFieldsEditBottomSheet extends StatefulWidget {
  final String entityId;
  final String entityType;

  const _CustomFieldsEditBottomSheet({
    required this.entityId,
    required this.entityType,
  });

  @override
  State<_CustomFieldsEditBottomSheet> createState() =>
      _CustomFieldsEditBottomSheetState();
}

class _CustomFieldsEditBottomSheetState
    extends State<_CustomFieldsEditBottomSheet> {
  final List<CustomField> _customFields = [];
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _fieldValueController = TextEditingController();
  final TextEditingController _fieldDescriptionController =
      TextEditingController();
  String _selectedFieldType = 'text';

  @override
  void initState() {
    super.initState();
    // Load existing custom fields from store
    try {
      final store =
          ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
      final existing = store.getCustomFieldsForEntity(widget.entityId);
      _customFields.addAll(existing.map((e) => CustomField(
            id: e.id,
            name: e.name,
            type: e.type,
            value: e.value,
            description: e.description,
          )));
    } catch (_) {
      // ignore if provider not available at init; will show empty
    }
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldValueController.dispose();
    _fieldDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                const Icon(Icons.edit_attributes, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Edit Custom Fields for ${widget.entityType}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Column(
              children: [
                // Add New Field Section
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Custom Field',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fieldNameController,
                        decoration: const InputDecoration(
                          labelText: 'Field Name',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Specialization, Region, etc.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedFieldType,
                        decoration: const InputDecoration(
                          labelText: 'Field Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'text', child: Text('Text')),
                          DropdownMenuItem(
                              value: 'number', child: Text('Number')),
                          DropdownMenuItem(value: 'date', child: Text('Date')),
                          DropdownMenuItem(
                              value: 'boolean', child: Text('Yes/No')),
                          DropdownMenuItem(
                              value: 'email', child: Text('Email')),
                          DropdownMenuItem(value: 'url', child: Text('URL')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedFieldType = value!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fieldValueController,
                        decoration: const InputDecoration(
                          labelText: 'Field Value',
                          border: OutlineInputBorder(),
                          hintText: 'Enter the value for this field',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fieldDescriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Describe what this field represents',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addCustomField,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Field'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Existing Fields List
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Existing Custom Fields',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _customFields.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit_attributes_outlined,
                                          size: 64,
                                          color: AppColors.textSecondary),
                                      SizedBox(height: 16),
                                      Text(
                                        'No custom fields added yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add custom fields to store additional information',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _customFields.length,
                                  itemBuilder: (context, index) {
                                    final field = _customFields[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: _getFieldTypeIcon(field.type),
                                        title: Text(field.name),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(field.value),
                                            if (field.description?.isNotEmpty ==
                                                true)
                                              Text(
                                                field.description!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  _editCustomField(field),
                                              icon: const Icon(Icons.edit,
                                                  size: 20),
                                              tooltip: 'Edit Field',
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _deleteCustomField(field),
                                              icon: const Icon(Icons.delete,
                                                  size: 20, color: Colors.red),
                                              tooltip: 'Delete Field',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCustomFields,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Custom Fields',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getFieldTypeIcon(String type) {
    switch (type) {
      case 'text':
        return const Icon(Icons.text_fields, color: AppColors.primary);
      case 'number':
        return const Icon(Icons.numbers, color: AppColors.primary);
      case 'date':
        return const Icon(Icons.calendar_today, color: AppColors.primary);
      case 'boolean':
        return const Icon(Icons.check_circle, color: AppColors.primary);
      case 'email':
        return const Icon(Icons.email, color: AppColors.primary);
      case 'url':
        return const Icon(Icons.link, color: AppColors.primary);
      default:
        return const Icon(Icons.text_fields, color: AppColors.primary);
    }
  }

  void _addCustomField() {
    if (_fieldNameController.text.trim().isEmpty ||
        _fieldValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in field name and value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newField = CustomField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _fieldNameController.text.trim(),
      type: _selectedFieldType,
      value: _fieldValueController.text.trim(),
      description: _fieldDescriptionController.text.trim().isEmpty
          ? null
          : _fieldDescriptionController.text.trim(),
    );

    setState(() {
      _customFields.add(newField);
      _fieldNameController.clear();
      _fieldValueController.clear();
      _fieldDescriptionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom field "${newField.name}" added'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _editCustomField(CustomField field) {
    _fieldNameController.text = field.name;
    _fieldValueController.text = field.value;
    _fieldDescriptionController.text = field.description ?? '';
    _selectedFieldType = field.type;

    // Remove the field from the list temporarily
    setState(() {
      _customFields.remove(field);
    });

    // Show a dialog to edit the field
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Custom Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fieldNameController,
              decoration: const InputDecoration(
                labelText: 'Field Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFieldType,
              decoration: const InputDecoration(
                labelText: 'Field Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'number', child: Text('Number')),
                DropdownMenuItem(value: 'date', child: Text('Date')),
                DropdownMenuItem(value: 'boolean', child: Text('Yes/No')),
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'url', child: Text('URL')),
              ],
              onChanged: (value) => setState(() => _selectedFieldType = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fieldValueController,
              decoration: const InputDecoration(
                labelText: 'Field Value',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fieldDescriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Restore the field
              setState(() {
                _customFields.add(field);
              });
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedField = CustomField(
                id: field.id,
                name: _fieldNameController.text.trim(),
                type: _selectedFieldType,
                value: _fieldValueController.text.trim(),
                description: _fieldDescriptionController.text.trim().isEmpty
                    ? null
                    : _fieldDescriptionController.text.trim(),
              );

              setState(() {
                _customFields.add(updatedField);
                _fieldNameController.clear();
                _fieldValueController.clear();
                _fieldDescriptionController.clear();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Custom field "${updatedField.name}" updated'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomField(CustomField field) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Field'),
        content: Text('Are you sure you want to delete "${field.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customFields.remove(field);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Custom field "${field.name}" deleted'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveCustomFields() {
    final store =
        ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
    store.setCustomFieldsForEntity(
      widget.entityId,
      _customFields
          .map((f) => CustomFieldData(
                id: f.id,
                name: f.name,
                type: f.type,
                value: f.value,
                description: f.description,
              ))
          .toList(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_customFields.length} custom fields saved for ${widget.entityType}'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
  }
}

/// Custom Field Model
class CustomField {
  final String id;
  final String name;
  final String type;
  final String value;
  final String? description;

  const CustomField({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.description,
  });
}

/// Bottom Sheet for Creating New Posts
class _CreatePostBottomSheet extends StatefulWidget {
  final String entityId;
  final PostCategory category;
  final VoidCallback onPostCreated;

  const _CreatePostBottomSheet({
    required this.entityId,
    required this.category,
    required this.onPostCreated,
  });

  @override
  State<_CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<_CreatePostBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _pdfUrlController = TextEditingController();
  String _selectedImageUrl = '';
  final List<String> _imageUrls = [];
  final List<String> _pdfUrls = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                const Icon(Icons.add_circle, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Create New ${widget.category == PostCategory.update ? 'Update' : 'Product Design'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      hintText: 'Enter post title',
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // Content Field
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      hintText: 'Enter post content',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 6,
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 16),

                  // Tags Field
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., technology, innovation, energy',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image URL Field
                  TextField(
                    onChanged: (value) =>
                        setState(() => _selectedImageUrl = value),
                    decoration: const InputDecoration(
                      labelText: 'Primary Image URL (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/image.jpg',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preview Image
                  if (_selectedImageUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 64, color: AppColors.textSecondary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Image Gallery (up to 50)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            labelText:
                                'Add Image URL (${_imageUrls.length}/50)',
                            border: const OutlineInputBorder(),
                            hintText: 'https://...',
                          ),
                          onSubmitted: (_) => _addImageUrl(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addImageUrl,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_imageUrls.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _imageUrls.asMap().entries.map((e) {
                        final url = e.value;
                        return InputChip(
                          label: Text(url, overflow: TextOverflow.ellipsis),
                          onDeleted: () =>
                              setState(() => _imageUrls.removeAt(e.key)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // PDF Attachments (up to 20)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pdfUrlController,
                          decoration: InputDecoration(
                            labelText: 'Add PDF URL (${_pdfUrls.length}/20)',
                            border: const OutlineInputBorder(),
                            hintText: 'https://.../file.pdf',
                          ),
                          onSubmitted: (_) => _addPdfUrl(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addPdfUrl,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_pdfUrls.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pdfUrls.asMap().entries.map((e) {
                        final url = e.value;
                        return InputChip(
                          avatar: const Icon(Icons.picture_as_pdf,
                              size: 16, color: Colors.red),
                          label: Text(url, overflow: TextOverflow.ellipsis),
                          onDeleted: () =>
                              setState(() => _pdfUrls.removeAt(e.key)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                    onPressed: _isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Create Post'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createPost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageUrls.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 50 images')),
      );
      return;
    }
    if (_pdfUrls.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can attach a maximum of 20 PDFs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create new post
      final newPost = ProfilePost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _selectedImageUrl.isNotEmpty
            ? _selectedImageUrl
            : 'https://via.placeholder.com/400',
        imageUrls: List<String>.from(_imageUrls),
        pdfUrls: List<String>.from(_pdfUrls),
        category: widget.category,
        tags: _tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        author: 'Current User',
        publishDate: DateTime.now(),
        likes: 0,
        comments: 0,
      );

      // Add post to the entity using StateInfoEditStore
      final store =
          ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
      store.addPostToEntity(widget.entityId, newPost);

      setState(() => _isLoading = false);
      Navigator.pop(context);
      widget.onPostCreated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) return;
    if (_imageUrls.length >= 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 50 images per post')),
      );
      return;
    }
    setState(() {
      _imageUrls.add(url);
      _imageUrlController.clear();
    });
  }

  void _addPdfUrl() {
    final url = _pdfUrlController.text.trim();
    if (url.isEmpty || !url.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid PDF URL ending with .pdf')),
      );
      return;
    }
    if (_pdfUrls.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 PDFs per post')),
      );
      return;
    }
    setState(() {
      _pdfUrls.add(url);
      _pdfUrlController.clear();
    });
  }
}

/// Bottom Sheet for Editing Existing Posts
class _EditPostBottomSheet extends StatefulWidget {
  final ProfilePost post;
  final String entityId;
  final VoidCallback onPostUpdated;

  const _EditPostBottomSheet({
    required this.post,
    required this.entityId,
    required this.onPostUpdated,
  });

  @override
  State<_EditPostBottomSheet> createState() => _EditPostBottomSheetState();
}

class _EditPostBottomSheetState extends State<_EditPostBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late String _selectedImageUrl;
  late TextEditingController _imageUrlController;
  late TextEditingController _pdfUrlController;
  late List<String> _imageUrls;
  late List<String> _pdfUrls;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _tagsController = TextEditingController(text: widget.post.tags.join(', '));
    _selectedImageUrl = widget.post.imageUrl;
    _imageUrls = List<String>.from(widget.post.imageUrls);
    _pdfUrls = List<String>.from(widget.post.pdfUrls);
    _imageUrlController = TextEditingController();
    _pdfUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                const Text(
                  'Edit Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      hintText: 'Enter post title',
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // Content Field
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      hintText: 'Enter post content',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 6,
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 16),

                  // Tags Field
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., technology, innovation, energy',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image URL Field
                  TextField(
                    controller: TextEditingController(text: _selectedImageUrl),
                    onChanged: (value) =>
                        setState(() => _selectedImageUrl = value),
                    decoration: const InputDecoration(
                      labelText: 'Primary Image URL (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/image.jpg',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preview Image
                  if (_selectedImageUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 64, color: AppColors.textSecondary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Image Gallery (up to 50)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            labelText:
                                'Add Image URL (${_imageUrls.length}/50)',
                            border: const OutlineInputBorder(),
                            hintText: 'https://...',
                          ),
                          onSubmitted: (_) => _addImageUrl(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addImageUrl,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_imageUrls.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _imageUrls.asMap().entries.map((e) {
                        final url = e.value;
                        return InputChip(
                          label: Text(url, overflow: TextOverflow.ellipsis),
                          onDeleted: () =>
                              setState(() => _imageUrls.removeAt(e.key)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // PDF Attachments (up to 20)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pdfUrlController,
                          decoration: InputDecoration(
                            labelText: 'Add PDF URL (${_pdfUrls.length}/20)',
                            border: const OutlineInputBorder(),
                            hintText: 'https://.../file.pdf',
                          ),
                          onSubmitted: (_) => _addPdfUrl(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addPdfUrl,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_pdfUrls.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pdfUrls.asMap().entries.map((e) {
                        final url = e.value;
                        return InputChip(
                          avatar: const Icon(Icons.picture_as_pdf,
                              size: 16, color: Colors.red),
                          label: Text(url, overflow: TextOverflow.ellipsis),
                          onDeleted: () =>
                              setState(() => _pdfUrls.removeAt(e.key)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                    onPressed: _isLoading ? null : _updatePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Post'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updatePost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageUrls.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 50 images')),
      );
      return;
    }
    if (_pdfUrls.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can attach a maximum of 20 PDFs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create updated post
      final updatedPost = ProfilePost(
        id: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _selectedImageUrl.isNotEmpty
            ? _selectedImageUrl
            : 'https://via.placeholder.com/400',
        imageUrls: List<String>.from(_imageUrls),
        pdfUrls: List<String>.from(_pdfUrls),
        category: widget.post.category,
        tags: _tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        author: widget.post.author,
        publishDate: widget.post.publishDate,
        likes: widget.post.likes,
        comments: widget.post.comments,
      );

      // Update post in the entity using StateInfoEditStore
      final store =
          ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
      store.updatePostInEntity(widget.entityId, updatedPost);

      setState(() => _isLoading = false);
      Navigator.pop(context);
      widget.onPostUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) return;
    if (_imageUrls.length >= 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 50 images per post')),
      );
      return;
    }
    setState(() {
      _imageUrls.add(url);
      _imageUrlController.clear();
    });
  }

  void _addPdfUrl() {
    final url = _pdfUrlController.text.trim();
    if (url.isEmpty || !url.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid PDF URL ending with .pdf')),
      );
      return;
    }
    if (_pdfUrls.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 PDFs per post')),
      );
      return;
    }
    setState(() {
      _pdfUrls.add(url);
      _pdfUrlController.clear();
    });
  }
}

/// Data Management Bottom Sheet for JSON Export/Import
class _DataManagementBottomSheet extends StatefulWidget {
  const _DataManagementBottomSheet();

  @override
  State<_DataManagementBottomSheet> createState() =>
      _DataManagementBottomSheetState();
}

class _DataManagementBottomSheetState
    extends State<_DataManagementBottomSheet> {
  bool _isLoading = false;

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
                const Icon(Icons.data_object, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Export Section
                  _buildSection(
                    title: 'Export Data',
                    description:
                        'Export all StateInfo data to JSON format for backup or sharing.',
                    icon: Icons.download,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _exportToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy JSON to Clipboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _exportToFile,
                        icon: const Icon(Icons.file_download),
                        label: const Text('Download JSON File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Import Section
                  _buildSection(
                    title: 'Import Data',
                    description:
                        'Import StateInfo data from a JSON file to restore or update content.',
                    icon: Icons.upload,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _importFromFile,
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Import from JSON File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Reset Section
                  _buildSection(
                    title: 'Reset Data',
                    description: 'Reset all data to the original demo content.',
                    icon: Icons.refresh,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _resetData,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: const Text('Reset to Default',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _exportToClipboard() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON export functionality coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportToFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON export functionality coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _importFromFile() async {
    setState(() => _isLoading = true);

    try {
      // This would need file picker implementation
      // For now, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'File picker not implemented yet. Use clipboard import instead.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
            'Are you sure you want to reset all data to default? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final store =
            ProviderScope.containerOf(context).read(stateInfoEditStoreProvider);
        store.resetToDefault();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data reset to default successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pop(context); // Close the bottom sheet
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
