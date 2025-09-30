import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../models/state_info_models.dart';
import '../store/state_info_store.dart';
import '../widgets/selection_screen.dart';
import '../widgets/power_flow_screens.dart';
import '../widgets/state_flow_screens.dart';
import '../widgets/responsive_layout.dart';

class ComprehensiveStateInfoPage extends ConsumerWidget {
  const ComprehensiveStateInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _StateInfoPageContent();
  }
}

class _StateInfoPageContent extends ConsumerWidget {
  const _StateInfoPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(localStateInfoStoreProvider);
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: store.currentTitle,
        leading: store.canGoBack && ResponsiveLayout.isMobile(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(context, store),
              )
            : null,
        automaticallyImplyLeading:
            store.canGoBack && !ResponsiveLayout.isMobile(context),
        actions: [
          if (store.mainPath != MainPath.selection &&
              !ResponsiveLayout.isMobile(context))
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => store.resetToSelection(),
              tooltip: 'Start Over',
            ),
          if (ResponsiveLayout.isMobile(context) &&
              store.mainPath != MainPath.selection)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => store.resetToSelection(),
                  child: const Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 8),
                      Text('Start Over'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: _buildCurrentScreen(store),
        ),
      ),
      // Add floating action button for mobile navigation
      floatingActionButton:
          ResponsiveLayout.isMobile(context) && store.canGoNext
              ? FloatingActionButton.extended(
                  onPressed: () => _handleNext(context, store),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                )
              : null,
    );
  }

  Widget _buildCurrentScreen(StateInfoStore store) {
    switch (store.mainPath) {
      case MainPath.selection:
        return const SelectionScreen();
      case MainPath.powerFlow:
        return _buildPowerFlowScreen(store);
      case MainPath.stateFlow:
        return _buildStateFlowScreen(store);
    }
  }

  Widget _buildPowerFlowScreen(StateInfoStore store) {
    switch (store.powerFlowStep) {
      case PowerFlowStep.generator:
        return const GeneratorSelectionScreen();
      case PowerFlowStep.generatorProfile:
        return const GeneratorProfileScreen();
      case PowerFlowStep.transmission:
        return const TransmissionSelectionScreen();
      case PowerFlowStep.transmissionProfile:
        return const TransmissionProfileScreen();
      case PowerFlowStep.distribution:
        return const DistributionSelectionScreen();
      case PowerFlowStep.profile:
        return const DistributionProfileScreen();
    }
  }

  Widget _buildStateFlowScreen(StateInfoStore store) {
    switch (store.stateFlowStep) {
      case StateFlowStep.states:
        return const StatesSelectionScreen();
      case StateFlowStep.stateDetail:
        return const StateDetailScreen();
      case StateFlowStep.mandalDetail:
        return const MandalDetailScreen();
    }
  }

  void _handleBack(BuildContext context, StateInfoStore store) {
    if (store.mainPath == MainPath.powerFlow) {
      store.backToPowerFlow();
    } else if (store.mainPath == MainPath.stateFlow) {
      store.backToStateFlow();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleNext(BuildContext context, StateInfoStore store) {
    if (store.mainPath == MainPath.powerFlow) {
      store.nextToPowerFlow();
    }
    // Note: State flow doesn't have a generic "next" - users select specific items
  }
}

// Progress Indicator Widget
class StateProgressIndicator extends StatelessWidget {
  final int total;
  final int current;

  const StateProgressIndicator({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = (i + 1) == current;
        final isCompleted = (i + 1) < current;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isCompleted
                  ? AppColors.primary
                  : AppColors.outlineSoft,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        color:
                            isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}

// Legacy NavigationButtons - kept for backward compatibility
// Use ResponsiveNavigationButtons for new implementations
class NavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onStartOver;
  final String? nextLabel;
  final String? backLabel;

  const NavigationButtons({
    super.key,
    this.onBack,
    this.onNext,
    this.onStartOver,
    this.nextLabel,
    this.backLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigationButtons(
      onBack: onBack,
      onNext: onNext,
      onStartOver: onStartOver,
      nextLabel: nextLabel,
      backLabel: backLabel,
    );
  }
}
