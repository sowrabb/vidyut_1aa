import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../models/state_info_models.dart';
import 'responsive_layout.dart';

class SelectionScreen extends ConsumerWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(stateInfoStoreProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      child: Padding(
        padding: ResponsiveLayout.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: isMobile ? 8 : 12),

            // Header Section
            _HeaderSection(isMobile: isMobile),

            SizedBox(height: isMobile ? 12 : 16),

            // Flow Selection Cards
            if (isMobile)
              _MobileFlowSelection(store: store)
            else
              _DesktopFlowSelection(store: store),

            SizedBox(height: isMobile ? 8 : 12),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isMobile;

  const _HeaderSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Choose Information Flow',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 24 : 32,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          'Select how you want to explore India\'s electricity infrastructure',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: isMobile ? 16 : 18,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MobileFlowSelection extends ConsumerWidget {
  final dynamic store;

  const _MobileFlowSelection({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _FlowSelectionCard(
          title: 'Power Generation Flow',
          subtitle: 'Follow the complete electricity journey',
          description: 'Generator → Transmission → Distribution → Profile',
          icon: Icons.bolt,
          color: Colors.orange,
          features: const [
            'Explore power generators (NTPC, NHPC, etc.)',
            'Understand transmission infrastructure',
            'Learn about distribution companies',
            'View detailed company profiles'
          ],
          onTap: () => store.selectPath(MainPath.powerFlow),
          isMobile: true,
        ),
        const SizedBox(height: 16),
        _FlowSelectionCard(
          title: 'State-Based Flow',
          subtitle: 'Explore by geographic regions',
          description: 'State → Districts → Mandals → Details',
          icon: Icons.map,
          color: Colors.blue,
          features: const [
            'Browse states and their energy profiles',
            'Discover district-wise information',
            'Explore mandal-level details',
            'Access local administration contacts'
          ],
          onTap: () => store.selectPath(MainPath.stateFlow),
          isMobile: true,
        ),
      ],
    );
  }
}

class _DesktopFlowSelection extends ConsumerWidget {
  final dynamic store;

  const _DesktopFlowSelection({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 400,
      child: Row(
        children: [
          Expanded(
            child: _FlowSelectionCard(
              title: 'Power Generation Flow',
              subtitle: 'Follow the complete electricity journey',
              description: 'Generator → Transmission → Distribution → Profile',
              icon: Icons.bolt,
              color: Colors.orange,
              features: const [
                'Explore power generators (NTPC, NHPC, etc.)',
                'Understand transmission infrastructure',
                'Learn about distribution companies',
                'View detailed company profiles'
              ],
              onTap: () => store.selectPath(MainPath.powerFlow),
              isMobile: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _FlowSelectionCard(
              title: 'State-Based Flow',
              subtitle: 'Explore by geographic regions',
              description: 'State → Districts → Mandals → Details',
              icon: Icons.map,
              color: Colors.blue,
              features: const [
                'Browse states and their energy profiles',
                'Discover district-wise information',
                'Explore mandal-level details',
                'Access local administration contacts'
              ],
              onTap: () => store.selectPath(MainPath.stateFlow),
              isMobile: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final VoidCallback onTap;
  final bool isMobile;

  const _FlowSelectionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isMobile ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),

              SizedBox(height: isMobile ? 16 : 20),

              // Flow Description
              _buildFlowDescription(context),

              SizedBox(height: isMobile ? 16 : 20),

              // Features List
              if (isMobile)
                _buildMobileFeatures(context)
              else
                _buildDesktopFeatures(context),

              // Action hint for mobile
              if (isMobile) ...[
                const SizedBox(height: 16),
                _buildActionHint(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isMobile ? 16 : 12),
          ),
          child: Icon(
            icon,
            color: color,
            size: isMobile ? 28 : 32,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 20 : 24,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 14 : 16,
                    ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
      ],
    );
  }

  Widget _buildFlowDescription(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            color: color,
            size: isMobile ? 20 : 16,
          ),
          SizedBox(width: isMobile ? 12 : 8),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: isMobile ? 16 : 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you\'ll explore:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        ...features.take(3).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
        if (features.length > 3)
          Text(
            '... and more',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
          ),
      ],
    );
  }

  Widget _buildDesktopFeatures(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you\'ll explore:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tap to explore',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.touch_app,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}
