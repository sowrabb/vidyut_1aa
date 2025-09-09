import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/tokens.dart';
import '../../app/layout/adaptive.dart';
import 'store/seller_store.dart';
import 'widgets/simple_custom_fields.dart';
import 'widgets/materials_selector.dart';
import '../home/widgets/location_picker.dart';
import '../../app/app_state.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
// For demo, we will accept a banner URL instead of file picker to avoid
// external dependencies. Integrate image_picker later if needed.
// removed duplicate imports

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _gstinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _bannerUrlController = TextEditingController();

  LocationResult? _pendingLocation;

  @override
  void initState() {
    super.initState();
    // TODO: Load existing profile data
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _gstinController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerStore>(
      builder: (context, store, child) {
        return Scaffold(
          body: SafeArea(
            child: ContentClamp(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile & Settings',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your business information and preferences',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // Business Location Section
                      const _SectionHeader(
                        title: 'Business Location',
                        icon: Ionicons.location_outline,
                      ),
                      const SizedBox(height: 12),
                      Builder(builder: (context) {
                        return OutlinedButton.icon(
                          onPressed: () async {
                            final res =
                                await showModalBottomSheet<LocationResult>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: LocationPicker(
                                  city: context.read<AppState>().city,
                                  state: context.read<AppState>().state,
                                  radiusKm: context.read<AppState>().radiusKm,
                                ),
                              ),
                            );
                            if (!mounted) return;
                            if (res != null) {
                              setState(() => _pendingLocation = res);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Preview your new location, then confirm to save')),
                              );
                            }
                          },
                          icon: const Icon(Ionicons.location_outline),
                          label: const Text('Set Business Location on Map'),
                        );
                      }),
                      if (_pendingLocation != null) ...[
                        const SizedBox(height: 12),
                        _LocationPreview(
                          pending: _pendingLocation!,
                          onDiscard: () {
                            setState(() => _pendingLocation = null);
                          },
                          onConfirm: () async {
                            final res = _pendingLocation!;
                            context.read<AppState>().setLocation(
                                  city: res.city,
                                  state: res.state,
                                  radiusKm: res.radiusKm,
                                  mode: res.isAuto
                                      ? LocationMode.auto
                                      : LocationMode.manual,
                                  latitude: res.latitude,
                                  longitude: res.longitude,
                                );
                            if (!mounted) return;
                            setState(() => _pendingLocation = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Business location updated')),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Business Information Section
                      const _SectionHeader(
                        title: 'Business Information',
                        icon: Ionicons.business_outline,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _legalNameController,
                        decoration: const InputDecoration(
                          labelText: 'Legal Business Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      ResponsiveRow(
                        children: [
                          TextFormField(
                            controller: _gstinController,
                            decoration: const InputDecoration(
                              labelText: 'GSTIN',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Support Phone *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Business Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Business Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Banner Section
                      const _SectionHeader(
                        title: 'Seller Banner',
                        icon: Ionicons.image_outline,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bannerUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Banner Image URL (1000×1000)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context
                                .read<SellerStore>()
                                .setBannerUrl(_bannerUrlController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Banner saved')));
                          },
                          icon: const Icon(Ionicons.save_outline),
                          label: const Text('Save Banner'),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Materials Used Section
                      const _SectionHeader(
                        title: 'Materials Used',
                        icon: Ionicons.cube_outline,
                      ),
                      const SizedBox(height: 12),
                      MaterialsSelector(
                        value: store.profileMaterials,
                        onChanged: (v) => store.setProfileMaterials(v),
                        label: 'Add materials you commonly use',
                      ),
                      const SizedBox(height: 32),

                      // Custom Fields Section (simple title + content)
                      const _SectionHeader(
                        title: 'Additional Info (Custom Fields)',
                        icon: Ionicons.add_circle_outline,
                      ),
                      const SizedBox(height: 16),
                      SimpleCustomFields(
                        entries: const [],
                        onChanged: (v) {
                          // TODO: persist to backend; store map in profile
                        },
                        title: 'Add Extra Details',
                      ),
                      const SizedBox(height: 32),

                      // Preferences Section
                      const _SectionHeader(
                        title: 'Preferences',
                        icon: Ionicons.settings_outline,
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: AppElevation.level1,
                        shadowColor: AppColors.shadowSoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.outlineSoft),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _PreferenceItem(
                                title: 'Email Notifications',
                                subtitle:
                                    'Receive notifications for new leads and orders',
                                value: true,
                                onChanged: (value) {
                                  // TODO: Update preference
                                },
                              ),
                              const Divider(),
                              _PreferenceItem(
                                title: 'Auto-Quote',
                                subtitle:
                                    'Automatically generate quotes for standard products',
                                value: true,
                                onChanged: (value) {
                                  // TODO: Update preference
                                },
                              ),
                              const Divider(),
                              _PreferenceItem(
                                title: 'Lead Alerts',
                                subtitle:
                                    'Get instant alerts for new B2B inquiries',
                                value: false,
                                onChanged: (value) {
                                  // TODO: Update preference
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saveProfile,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    // TODO(firebase): Save to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _PreferenceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LocationPreview extends StatelessWidget {
  final LocationResult pending;
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;
  const _LocationPreview({
    required this.pending,
    required this.onConfirm,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final lat = pending.latitude;
    final lng = pending.longitude;
    final center = LatLng(lat ?? 17.3850, lng ?? 78.4867);
    final googleMapsUrl = (lat != null && lng != null)
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : null;

    return Card(
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
                const Icon(Icons.map_outlined),
                const SizedBox(width: 8),
                Text('Preview New Location',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.vidyut.app',
                    ),
                    if (lat != null && lng != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 32),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${pending.city}, ${pending.state}' + (pending.area != null && pending.area!.isNotEmpty ? ' • ${pending.area}' : ''),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (lat != null && lng != null)
              Text('Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDiscard,
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                if (googleMapsUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Open in Google Maps'),
                    ),
                  ),
                if (googleMapsUrl != null) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    child: const Text('Confirm & Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
