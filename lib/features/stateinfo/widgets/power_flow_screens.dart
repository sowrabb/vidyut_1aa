import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/tokens.dart';
import '../pages/comprehensive_state_info_page.dart';
import 'profile_widgets.dart';
import 'responsive_layout.dart';
import '../../../app/provider_registry.dart';

// Generator Selection Screen
class GeneratorSelectionScreen extends ConsumerWidget {
  const GeneratorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(localStateInfoStoreProvider);

    return Column(
      children: [
        Padding(
          padding: ResponsiveLayout.getScreenPadding(context),
          child: StateProgressIndicator(
            total: 3,
            current: store.powerFlowProgress,
          ),
        ),
        Expanded(
          child: store.powerGenerators.isEmpty
              ? _buildEmptyState(context, 'No power generators available')
              : ListView.separated(
                  padding: ResponsiveLayout.getScreenPadding(context),
                  itemCount: store.powerGenerators.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final generator = store.powerGenerators[index];
                    return Card(
                      child: ListTile(
                        title: Text(generator.name),
                        subtitle:
                            Text('${generator.type} - ${generator.capacity}'),
                        onTap: () => store.selectGenerator(generator.id),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
        ),
        if (!ResponsiveLayout.isMobile(context))
          NavigationButtons(
            onBack: () => store.backToPowerFlow(),
            onStartOver: () => store.resetToSelection(),
          ),
      ],
    );
  }
}

// Generator Profile Screen
class GeneratorProfileScreen extends ConsumerWidget {
  const GeneratorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(stateInfoStoreProvider);
    final generator = store.selectedGeneratorData;

    if (generator == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'Generator not found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please select a generator from the list',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: ResponsiveLayout.getScreenPadding(context),
          child: StateProgressIndicator(
            total: 3,
            current: store.powerFlowProgress,
          ),
        ),
        Expanded(
          child: CompanyProfileView(
            companyName: generator.name,
            companyType: '${generator.type} Power Generation',
            capacity: generator.capacity,
            location: generator.location,
            logo: generator.logo,
            established: generator.established,
            founder: generator.founder,
            leaderName: generator.ceo,
            leaderTitle: 'Chief Executive Officer',
            leaderPhoto: generator.ceoPhoto,
            headquarters: generator.headquarters,
            phone: generator.phone,
            email: generator.email,
            website: generator.website,
            description: generator.description,
            statistics: {
              'Total Plants': generator.totalPlants.toString(),
              'Employees': generator.employees,
              'Annual Revenue': generator.revenue,
            },
            posts: generator.posts,
            productDesigns: generator.productDesigns,
            sectorType: 'generator',
            sectorId: generator.id,
            isEditMode: false, // Pending: Pass from parent
          ),
        ),
        if (!ResponsiveLayout.isMobile(context))
          NavigationButtons(
            onBack: () => store.backToPowerFlow(),
            onNext: () => store.nextToPowerFlow(),
            onStartOver: () => store.resetToSelection(),
            nextLabel: 'View Transmission',
          ),
      ],
    );
  }
}

// Transmission Selection Screen
class TransmissionSelectionScreen extends ConsumerWidget {
  const TransmissionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(localStateInfoStoreProvider);

    return Column(
      children: [
        Padding(
          padding: ResponsiveLayout.getScreenPadding(context),
          child: StateProgressIndicator(
            total: 3,
            current: store.powerFlowProgress,
          ),
        ),
        Expanded(
          child: store.transmissionLines.isEmpty
              ? _buildEmptyState(context, 'No transmission lines available')
              : ListView.separated(
                  padding: ResponsiveLayout.getScreenPadding(context),
                  itemCount: store.transmissionLines.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transmission = store.transmissionLines[index];
                    return Card(
                      child: ListTile(
                        title: Text(transmission.name),
                        subtitle: Text(
                            '${transmission.voltage} - ${transmission.coverage}'),
                        onTap: () => store.selectTransmission(transmission.id),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
        ),
        if (!ResponsiveLayout.isMobile(context))
          NavigationButtons(
            onBack: () => store.backToPowerFlow(),
            onStartOver: () => store.resetToSelection(),
          ),
      ],
    );
  }
}

// Transmission Profile Screen
class TransmissionProfileScreen extends ConsumerWidget {
  const TransmissionProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(stateInfoStoreProvider);
    final transmission = store.selectedTransmissionData;

    if (transmission == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'Transmission line not found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please select a transmission line from the list',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: ResponsiveLayout.getScreenPadding(context),
          child: StateProgressIndicator(
            total: 3,
            current: store.powerFlowProgress,
          ),
        ),
        Expanded(
          child: CompanyProfileView(
            companyName: transmission.name,
            companyType: '${transmission.voltage} Transmission Network',
            capacity: '${transmission.coverage} Coverage',
            location: transmission.headquarters,
            logo: transmission.logo,
            established: transmission.established,
            founder: transmission.founder,
            leaderName: transmission.ceo,
            leaderTitle: 'Chief Executive Officer',
            leaderPhoto: transmission.ceoPhoto,
            headquarters: transmission.address,
            phone: transmission.phone,
            email: transmission.email,
            website: transmission.website,
            description: transmission.description,
            statistics: {
              'Total Substations': transmission.totalSubstations.toString(),
              'Employees': transmission.employees,
              'Annual Revenue': transmission.revenue,
            },
            posts: transmission.posts,
            productDesigns: transmission.productDesigns,
            sectorType: 'transmission',
            sectorId: transmission.id,
            isEditMode: false, // Pending: Pass from parent
          ),
        ),
        if (!ResponsiveLayout.isMobile(context))
          NavigationButtons(
            onBack: () => store.backToPowerFlow(),
            onNext: () => store.nextToPowerFlow(),
            onStartOver: () => store.resetToSelection(),
            nextLabel: 'View Distribution',
          ),
      ],
    );
  }
}

// Distribution Selection Screen
class DistributionSelectionScreen extends ConsumerWidget {
  const DistributionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(localStateInfoStoreProvider);

    return Column(
      children: [
        Padding(
          padding: ResponsiveLayout.getScreenPadding(context),
          child: StateProgressIndicator(
            total: 3,
            current: store.powerFlowProgress,
          ),
        ),
        Expanded(
          child: store.distributionCompanies.isEmpty
              ? _buildEmptyState(context, 'No distribution companies available')
              : ListView.separated(
                  padding: ResponsiveLayout.getScreenPadding(context),
                  itemCount: store.distributionCompanies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final distribution = store.distributionCompanies[index];
                    return Card(
                      child: ListTile(
                        title: Text(distribution.name),
                        subtitle: Text(distribution.customers),
                        onTap: () => store.selectDistribution(distribution.id),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
        ),
        if (!ResponsiveLayout.isMobile(context))
          NavigationButtons(
            onBack: () => store.backToPowerFlow(),
            onStartOver: () => store.resetToSelection(),
          ),
      ],
    );
  }
}

// Distribution Profile Screen
class DistributionProfileScreen extends ConsumerWidget {
  const DistributionProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(stateInfoStoreProvider);
    final distribution = store.selectedDistributionData;

    if (distribution == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'Distribution company not found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please select a distribution company from the list',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: ResponsiveLayout.getScreenPadding(context),
          child: StateProgressIndicator(
            total: 3,
            current: store.powerFlowProgress,
          ),
        ),
        Expanded(
          child: CompanyProfileView(
            companyName: distribution.name,
            companyType: 'Electricity Distribution Company',
            capacity: distribution.capacity,
            location: distribution.coverage,
            logo: distribution.logo,
            established: distribution.established,
            founder: '',
            leaderName: distribution.director,
            leaderTitle: 'Managing Director',
            leaderPhoto: distribution.directorPhoto,
            headquarters: distribution.address,
            phone: distribution.phone,
            email: distribution.email,
            website: distribution.website,
            description: distribution.description,
            statistics: {
              'Total Customers': distribution.customers,
              'Service Area': distribution.coverage,
              'Capacity': distribution.capacity,
            },
            posts: distribution.posts,
            productDesigns: distribution.productDesigns,
            sectorType: 'distribution',
            sectorId: distribution.id,
            isEditMode: false, // Pending: Pass from parent
          ),
        ),
        if (!ResponsiveLayout.isMobile(context))
          NavigationButtons(
            onBack: () => store.backToPowerFlow(),
            onStartOver: () => store.resetToSelection(),
            backLabel: 'Back to Distribution',
          ),
      ],
    );
  }
}

// Helper method for empty states
Widget _buildEmptyState(BuildContext context, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check back later or contact support',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
