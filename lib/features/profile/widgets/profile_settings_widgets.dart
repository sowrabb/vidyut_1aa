import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/tokens.dart';
import '../../../app/provider_registry.dart';
import '../store/user_store.dart';

class ProfileSection extends ConsumerWidget {
  final UserProfile profile;

  const ProfileSection({required this.profile, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(Icons.person_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: profile.profileImageUrl != null
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
                child: profile.profileImageUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(profile.name),
              subtitle: Text(profile.email),
              trailing: OutlinedButton(
                onPressed: () => _showEditProfileDialog(context, ref),
                child: const Text('Edit'),
              ),
            ),
            const Divider(),
            InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: profile.email,
              isVerified: profile.isEmailVerified,
              onAction: () => _showEmailVerificationDialog(context, ref),
            ),
            InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: profile.phone,
              isVerified: profile.isPhoneVerified,
              onAction: () => _showPhoneVerificationDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final userStore = ref.read(userStoreProvider);
    final nameController = TextEditingController(text: userStore.profile.name);
    final emailController =
        TextEditingController(text: userStore.profile.email);
    final phoneController =
        TextEditingController(text: userStore.profile.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await userStore.updateProfile(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmailVerificationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification'),
        content: const Text('Send verification email to this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final userStore = ref.read(userStoreProvider);
              await userStore.sendEmailVerification();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerificationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Verification'),
        content: const Text('Send verification SMS to this number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final userStore = ref.read(userStoreProvider);
              await userStore.sendPhoneVerification();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification SMS sent')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isVerified;
  final VoidCallback? onAction;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isVerified = false,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value),
              ],
            ),
          ),
          if (isVerified)
            Icon(Icons.verified, color: Colors.green, size: 16)
          else
            TextButton(
              onPressed: onAction,
              child: const Text('Verify'),
            ),
        ],
      ),
    );
  }
}

class SecuritySection extends ConsumerWidget {
  final UserStore userStore;

  const SecuritySection({required this.userStore, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(Icons.security_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context, ref),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add an extra layer of security'),
              trailing: Switch(
                value: false, // Demo value
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Two-factor authentication coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final request = PasswordChangeRequest(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                  confirmPassword: confirmPasswordController.text,
                );

                final success = await userStore.changePassword(request);
                if (context.mounted) {
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password changed successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              userStore.error ?? 'Failed to change password')),
                    );
                  }
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}

class NotificationsSection extends ConsumerWidget {
  final NotificationSettings settings;

  const NotificationsSection({required this.settings, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStore = ref.read(userStoreProvider);

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
                Icon(Icons.notifications_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            NotificationSwitch(
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: settings.emailEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(emailEnabled: value),
                );
              },
            ),
            NotificationSwitch(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications',
              value: settings.pushEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(pushEnabled: value),
                );
              },
            ),
            NotificationSwitch(
              title: 'SMS Notifications',
              subtitle: 'Receive notifications via SMS',
              value: settings.smsEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(smsEnabled: value),
                );
              },
            ),
            const Divider(),
            NotificationSwitch(
              title: 'Marketing Emails',
              subtitle: 'Receive promotional content',
              value: settings.marketingEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(marketingEnabled: value),
                );
              },
            ),
            NotificationSwitch(
              title: 'Weekly Digest',
              subtitle: 'Get weekly summary emails',
              value: settings.weeklyDigestEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(weeklyDigestEnabled: value),
                );
              },
            ),
            NotificationSwitch(
              title: 'New Message Alerts',
              subtitle: 'Notify about new messages',
              value: settings.messageAlertsEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(messageAlertsEnabled: value),
                );
              },
            ),
            NotificationSwitch(
              title: 'Order Updates',
              subtitle: 'Notify about order status changes',
              value: settings.orderUpdatesEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(orderUpdatesEnabled: value),
                );
              },
            ),
            NotificationSwitch(
              title: 'Price Alerts',
              subtitle: 'Notify when product prices change',
              value: settings.priceAlertsEnabled,
              onChanged: (value) async {
                await userStore.updateNotificationSettings(
                  settings.copyWith(priceAlertsEnabled: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
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
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
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

class PreferencesSection extends ConsumerWidget {
  final UserPreferences preferences;

  const PreferencesSection({required this.preferences, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStore = ref.read(userStoreProvider);

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
                Icon(Icons.settings_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PreferenceDropdown(
              title: 'Language',
              subtitle: 'Choose your preferred language',
              value: preferences.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                DropdownMenuItem(value: 'te', child: Text('Telugu')),
              ],
              onChanged: (value) async {
                await userStore.updatePreferences(
                  preferences.copyWith(language: value),
                );
              },
            ),
            PreferenceDropdown(
              title: 'Theme',
              subtitle: 'Choose your preferred theme',
              value: preferences.theme,
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (value) async {
                await userStore.updatePreferences(
                  preferences.copyWith(theme: value),
                );
              },
            ),
            const Divider(),
            PreferenceSwitch(
              title: 'Auto Save',
              subtitle: 'Automatically save your work',
              value: preferences.autoSave,
              onChanged: (value) async {
                await userStore.updatePreferences(
                  preferences.copyWith(autoSave: value),
                );
              },
            ),
            PreferenceSwitch(
              title: 'Location Tracking',
              subtitle: 'Allow location-based features',
              value: preferences.locationTracking,
              onChanged: (value) async {
                await userStore.updatePreferences(
                  preferences.copyWith(locationTracking: value),
                );
              },
            ),
            const Divider(),
            PreferenceSlider(
              title: 'Search Radius',
              subtitle: 'Default search radius in kilometers',
              value: preferences.searchRadius,
              min: 5.0,
              max: 100.0,
              divisions: 19,
              onChanged: (value) async {
                await userStore.updatePreferences(
                  preferences.copyWith(searchRadius: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PreferenceDropdown extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const PreferenceDropdown({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class PreferenceSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
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
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
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

class PreferenceSlider extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const PreferenceSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text('${value.round()} km'),
            ],
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class AccountActionsSection extends ConsumerWidget {
  final UserStore userStore;

  const AccountActionsSection({required this.userStore, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(Icons.account_circle_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Account Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export Data'),
              subtitle: const Text('Download your account data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _exportData(context),
            ),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('Import Data'),
              subtitle: const Text('Restore from backup'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _importData(context, ref),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    final data = userStore.exportData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported successfully')),
    );
    // In a real app, you would trigger a download
    print('Exported data: $data');
  }

  void _importData(BuildContext context, WidgetRef ref) {
    // In a real app, you would show a file picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content:
            const Text('File picker would open here to select backup file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data imported successfully')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your password to confirm',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success =
                  await userStore.deleteAccount(passwordController.text);
              if (context.mounted) {
                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Account deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            userStore.error ?? 'Failed to delete account')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
