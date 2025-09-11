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
import '../../widgets/image_upload_widget.dart';

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
  final _websiteController = TextEditingController();

  LocationResult? _pendingLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
    // Add listeners for auto-save
    _addTextControllerListeners();
  }

  void _addTextControllerListeners() {
    _legalNameController.addListener(_autoSave);
    _gstinController.addListener(_autoSave);
    _phoneController.addListener(_autoSave);
    _emailController.addListener(_autoSave);
    _addressController.addListener(_autoSave);
    _websiteController.addListener(_autoSave);
  }

  void _autoSave() {
    // Auto-save form data to prevent loss
    _saveFormState();
  }

  void _saveFormState() {
    // Save form state to local storage
    // This would typically use SharedPreferences or similar
    // For now, we'll just store in memory
  }

  void _loadProfileData() async {
    final store = context.read<SellerStore>();
    await store.loadProfileData();
    
    if (mounted) {
      final profileData = store.profileData;
      _legalNameController.text = profileData['legalName'] ?? '';
      _gstinController.text = profileData['gstin'] ?? '';
      _phoneController.text = profileData['phone'] ?? '';
      _emailController.text = profileData['email'] ?? '';
      _addressController.text = profileData['address'] ?? '';
      _websiteController.text = profileData['website'] ?? '';
    }
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
                          if (value.length < 2) {
                            return 'Business name must be at least 2 characters';
                          }
                          if (value.length > 100) {
                            return 'Business name must be less than 100 characters';
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
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                // Basic GSTIN validation (15 characters, alphanumeric)
                                final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
                                if (!gstinRegex.hasMatch(value.toUpperCase())) {
                                  return 'Please enter a valid GSTIN';
                                }
                              }
                              return null;
                            },
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
                              // Basic phone number validation
                              final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,15}$');
                              if (!phoneRegex.hasMatch(value)) {
                                return 'Please enter a valid phone number';
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
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
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
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website URL',
                          border: OutlineInputBorder(),
                          hintText: 'https://www.yourwebsite.com',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Additional Contact Information Section
                      const _SectionHeader(
                        title: 'Additional Contact Information',
                        icon: Ionicons.call_outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Add extra phone numbers and email addresses for better customer reach',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AdditionalContactFields(),
                      const SizedBox(height: 32),

                      // Banner Section
                      const _SectionHeader(
                        title: 'Seller Banner',
                        icon: Ionicons.image_outline,
                      ),
                      const SizedBox(height: 12),
                      ImageUploadWidget(
                        currentImagePath: context.watch<SellerStore>().bannerUrl,
                        onImageSelected: (result) {
                          context.read<SellerStore>().setBannerUrl(result.path);
                        },
                        onImageRemoved: (_) {
                          context.read<SellerStore>().setBannerUrl('');
                        },
                        width: double.infinity,
                        height: 200,
                        label: 'Banner Image',
                        hint: 'Upload a banner image for your seller profile (recommended: 1000×1000)',
                        showPreview: true,
                        allowMultipleSources: true,
                        borderRadius: BorderRadius.circular(12),
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

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final store = context.read<SellerStore>();
    
    await store.saveProfileData(
      legalName: _legalNameController.text.trim(),
      gstin: _gstinController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      website: _websiteController.text.trim(),
      materials: store.profileMaterials,
      customFields: store.profileFields,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
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

class _AdditionalContactFields extends StatefulWidget {
  @override
  State<_AdditionalContactFields> createState() => _AdditionalContactFieldsState();
}

class _AdditionalContactFieldsState extends State<_AdditionalContactFields> {
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _emailControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one empty field for each type
    _phoneControllers.add(TextEditingController());
    _emailControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    if (_phoneControllers.length > 1) {
      setState(() {
        _phoneControllers[index].dispose();
        _phoneControllers.removeAt(index);
      });
    }
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  void _removeEmailField(int index) {
    if (_emailControllers.length > 1) {
      setState(() {
        _emailControllers[index].dispose();
        _emailControllers.removeAt(index);
      });
    }
  }

  void _saveContactInfo() {
    final store = context.read<SellerStore>();
    
    // Get primary contact from main form
    final primaryPhone = context.findAncestorStateOfType<_ProfileSettingsPageState>()?._phoneController.text ?? '';
    final primaryEmail = context.findAncestorStateOfType<_ProfileSettingsPageState>()?._emailController.text ?? '';
    final website = context.findAncestorStateOfType<_ProfileSettingsPageState>()?._websiteController.text ?? '';
    
    // Update primary contact
    store.setPrimaryPhone(primaryPhone);
    store.setPrimaryEmail(primaryEmail);
    store.setWebsite(website);
    
    // Get additional contacts
    final additionalPhones = _phoneControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    final additionalEmails = _emailControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    store.setAdditionalPhones(additionalPhones);
    store.setAdditionalEmails(additionalEmails);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact information saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Additional Phone Numbers
        Text('Additional Phone Numbers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(_phoneControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Phone ${index + 1}',
                      border: const OutlineInputBorder(),
                      hintText: '+91 98765 43210',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                if (_phoneControllers.length > 1)
                  IconButton(
                    onPressed: () => _removePhoneField(index),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addPhoneField,
          icon: const Icon(Icons.add),
          label: const Text('Add Phone Number'),
        ),
        const SizedBox(height: 16),

        // Additional Email Addresses
        Text('Additional Email Addresses', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(_emailControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Email ${index + 1}',
                      border: const OutlineInputBorder(),
                      hintText: 'example@company.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                if (_emailControllers.length > 1)
                  IconButton(
                    onPressed: () => _removeEmailField(index),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addEmailField,
          icon: const Icon(Icons.add),
          label: const Text('Add Email Address'),
        ),
        const SizedBox(height: 16),

        // Save Button
        FilledButton.icon(
          onPressed: _saveContactInfo,
          icon: const Icon(Icons.save),
          label: const Text('Save Contact Information'),
        ),
      ],
    );
  }
}
