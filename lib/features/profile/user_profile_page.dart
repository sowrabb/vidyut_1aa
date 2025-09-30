import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/tokens.dart';
import '../../../app/provider_registry.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;
  bool _showPrivacySettings = false;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    final session = ref.read(sessionControllerProvider);
    final profileService = ref.read(userProfileServiceProvider);

    final userId = session.userId;
    if (userId != null) {
      await profileService.initializeProfile(userId);
      _loadProfileData();
    }
  }

  void _loadProfileData() {
    final profileService = ref.read(userProfileServiceProvider);
    final profile = profileService.userProfile;

    if (profile != null) {
      _nameController.text = profile['displayName'] ?? '';
      _phoneController.text = profile['phoneNumber'] ?? '';
      _bioController.text = profile['bio'] ?? '';
      _companyController.text = profile['company'] ?? '';
      _addressController.text = profile['address'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(sessionControllerProvider);
    final profileService = ref.read(userProfileServiceProvider);

    final userId = session.userId;
    if (userId == null) return;

    final success = await profileService.updateProfile(
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      bio: _bioController.text.trim().isNotEmpty
          ? _bioController.text.trim()
          : null,
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  Future<void> _changeProfileImage() async {
    final session = ref.read(sessionControllerProvider);
    final profileService = ref.read(userProfileServiceProvider);

    final userId = session.userId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await profileService.pickImageFromGallery();
                if (image != null) {
                  await profileService.uploadProfileImage(userId, image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await profileService.pickImageFromCamera();
                if (image != null) {
                  await profileService.uploadProfileImage(userId, image);
                }
              },
            ),
            if (profileService.userProfile?['photoURL'] != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await profileService.deleteProfileImage(userId);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    final session = ref.read(sessionControllerProvider);
    final profileService = ref.read(userProfileServiceProvider);

    final userId = session.userId;
    if (userId == null) return;

    final data = await profileService.exportUserData(userId);
    if (data != null && mounted) {
      // In a real app, you would save this to a file or show it to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully!')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final session = ref.read(sessionControllerProvider);
      final profileService = ref.read(userProfileServiceProvider);

      final userId = session.userId;
      if (userId != null) {
        final success = await profileService.deleteUserAccount(userId);
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final profileService = ref.watch(userProfileServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadProfileData();
              },
              child: const Text('Cancel'),
            ),
          ] else
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _isEditing ? _changeProfileImage : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage:
                                profileService.userProfile?['photoURL'] != null
                                    ? NetworkImage(
                                        profileService.userProfile!['photoURL'])
                                    : null,
                            child:
                                profileService.userProfile?['photoURL'] == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.primary,
                                      )
                                    : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      session.displayName ?? 'User',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: session.isGuest ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        session.isGuest ? 'Guest User' : 'Registered User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Information
              Text(
                'Profile Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                enabled: _isEditing,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                  hintText: 'Tell us about yourself...',
                ),
              ),
              const SizedBox(height: 16),

              // Company
              TextFormField(
                controller: _companyController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                enabled: _isEditing,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Privacy Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showPrivacySettings = !_showPrivacySettings;
                      });
                    },
                    icon: Icon(
                      _showPrivacySettings
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                  ),
                ],
              ),
              if (_showPrivacySettings) ...[
                const SizedBox(height: 16),
                _buildPrivacySettings(),
                const SizedBox(height: 32),
              ],

              // Account Actions
              Text(
                'Account Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Export Data
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export My Data'),
                subtitle: const Text('Download a copy of your data'),
                onTap: _exportData,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Delete Account
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Account',
                    style: TextStyle(color: Colors.red)),
                subtitle: const Text('Permanently delete your account'),
                onTap: _deleteAccount,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    final profileService = ref.watch(userProfileServiceProvider);
    final privacy = profileService.userProfile?['privacy'] ?? {};

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Profile Visible'),
          subtitle: const Text('Allow others to see your profile'),
          value: privacy['profileVisible'] ?? true,
          onChanged: _isEditing
              ? (value) async {
                  await profileService.updatePrivacySettings(
                      profileVisible: value);
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Email Visible'),
          subtitle: const Text('Show email to other users'),
          value: privacy['emailVisible'] ?? false,
          onChanged: _isEditing
              ? (value) async {
                  await profileService.updatePrivacySettings(
                      emailVisible: value);
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Phone Visible'),
          subtitle: const Text('Show phone number to other users'),
          value: privacy['phoneVisible'] ?? false,
          onChanged: _isEditing
              ? (value) async {
                  await profileService.updatePrivacySettings(
                      phoneVisible: value);
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Allow Messages'),
          subtitle: const Text('Allow other users to message you'),
          value: privacy['allowMessages'] ?? true,
          onChanged: _isEditing
              ? (value) async {
                  await profileService.updatePrivacySettings(
                      allowMessages: value);
                }
              : null,
        ),
      ],
    );
  }
}
