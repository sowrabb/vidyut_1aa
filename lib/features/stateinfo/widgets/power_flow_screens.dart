import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/state_info_store.dart';
import '../pages/comprehensive_state_info_page.dart';
import 'profile_widgets.dart';
import 'responsive_layout.dart';

// Generator Selection Screen
class GeneratorSelectionScreen extends StatelessWidget {
  const GeneratorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<StateInfoStore>();
    
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
          child: ListView.separated(
            padding: ResponsiveLayout.getScreenPadding(context),
            itemCount: store.powerGenerators.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final generator = store.powerGenerators[index];
              return Card(
                child: ListTile(
                  title: Text(generator.name),
                  subtitle: Text('${generator.type} - ${generator.capacity}'),
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
class GeneratorProfileScreen extends StatelessWidget {
  const GeneratorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StateInfoStore>();
    final generator = store.selectedGeneratorData;
    
    if (generator == null) {
      return const Center(child: Text('Generator not found'));
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
class TransmissionSelectionScreen extends StatelessWidget {
  const TransmissionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<StateInfoStore>();
    
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
          child: ListView.separated(
            padding: ResponsiveLayout.getScreenPadding(context),
            itemCount: store.transmissionLines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final transmission = store.transmissionLines[index];
              return Card(
                child: ListTile(
                  title: Text(transmission.name),
                  subtitle: Text('${transmission.voltage} - ${transmission.coverage}'),
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
class TransmissionProfileScreen extends StatelessWidget {
  const TransmissionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StateInfoStore>();
    final transmission = store.selectedTransmissionData;
    
    if (transmission == null) {
      return const Center(child: Text('Transmission line not found'));
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
class DistributionSelectionScreen extends StatelessWidget {
  const DistributionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<StateInfoStore>();
    
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
          child: ListView.separated(
            padding: ResponsiveLayout.getScreenPadding(context),
            itemCount: store.distributionCompanies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
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
class DistributionProfileScreen extends StatelessWidget {
  const DistributionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StateInfoStore>();
    final distribution = store.selectedDistributionData;
    
    if (distribution == null) {
      return const Center(child: Text('Distribution company not found'));
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