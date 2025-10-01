// User profile models for the profile settings page

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
    );
  }
}

class UserPreferences {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool marketingEmails;
  final bool weeklyDigest;
  final bool newMessageAlerts;
  final bool orderUpdates;
  final bool priceAlerts;
  final String language;
  final String theme;
  final bool autoSave;
  final bool locationTracking;
  final double searchRadius;

  const UserPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.marketingEmails = false,
    this.weeklyDigest = true,
    this.newMessageAlerts = true,
    this.orderUpdates = true,
    this.priceAlerts = false,
    this.language = 'en',
    this.theme = 'system',
    this.autoSave = true,
    this.locationTracking = true,
    this.searchRadius = 25.0,
  });

  UserPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? marketingEmails,
    bool? weeklyDigest,
    bool? newMessageAlerts,
    bool? orderUpdates,
    bool? priceAlerts,
    String? language,
    String? theme,
    bool? autoSave,
    bool? locationTracking,
    double? searchRadius,
  }) {
    return UserPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      newMessageAlerts: newMessageAlerts ?? this.newMessageAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSave: autoSave ?? this.autoSave,
      locationTracking: locationTracking ?? this.locationTracking,
      searchRadius: searchRadius ?? this.searchRadius,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'marketingEmails': marketingEmails,
      'weeklyDigest': weeklyDigest,
      'newMessageAlerts': newMessageAlerts,
      'orderUpdates': orderUpdates,
      'priceAlerts': priceAlerts,
      'language': language,
      'theme': theme,
      'autoSave': autoSave,
      'locationTracking': locationTracking,
      'searchRadius': searchRadius,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      marketingEmails: json['marketingEmails'] as bool? ?? false,
      weeklyDigest: json['weeklyDigest'] as bool? ?? true,
      newMessageAlerts: json['newMessageAlerts'] as bool? ?? true,
      orderUpdates: json['orderUpdates'] as bool? ?? true,
      priceAlerts: json['priceAlerts'] as bool? ?? false,
      language: json['language'] as String? ?? 'en',
      theme: json['theme'] as String? ?? 'system',
      autoSave: json['autoSave'] as bool? ?? true,
      locationTracking: json['locationTracking'] as bool? ?? true,
      searchRadius: (json['searchRadius'] as num?)?.toDouble() ?? 25.0,
    );
  }
}

class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  bool get isValid =>
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      newPassword == confirmPassword &&
      newPassword.length >= 8;

  String? validate() {
    if (currentPassword.isEmpty) return 'Current password is required';
    if (newPassword.isEmpty) return 'New password is required';
    if (confirmPassword.isEmpty) return 'Confirm password is required';
    if (newPassword != confirmPassword) return 'Passwords do not match';
    if (newPassword.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
}

class NotificationSettings {
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool marketingEnabled;
  final bool weeklyDigestEnabled;
  final bool messageAlertsEnabled;
  final bool orderUpdatesEnabled;
  final bool priceAlertsEnabled;

  const NotificationSettings({
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.marketingEnabled = false,
    this.weeklyDigestEnabled = true,
    this.messageAlertsEnabled = true,
    this.orderUpdatesEnabled = true,
    this.priceAlertsEnabled = false,
  });

  NotificationSettings copyWith({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? marketingEnabled,
    bool? weeklyDigestEnabled,
    bool? messageAlertsEnabled,
    bool? orderUpdatesEnabled,
    bool? priceAlertsEnabled,
  }) {
    return NotificationSettings(
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      messageAlertsEnabled: messageAlertsEnabled ?? this.messageAlertsEnabled,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'marketingEnabled': marketingEnabled,
      'weeklyDigestEnabled': weeklyDigestEnabled,
      'messageAlertsEnabled': messageAlertsEnabled,
      'orderUpdatesEnabled': orderUpdatesEnabled,
      'priceAlertsEnabled': priceAlertsEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      marketingEnabled: json['marketingEnabled'] as bool? ?? false,
      weeklyDigestEnabled: json['weeklyDigestEnabled'] as bool? ?? true,
      messageAlertsEnabled: json['messageAlertsEnabled'] as bool? ?? true,
      orderUpdatesEnabled: json['orderUpdatesEnabled'] as bool? ?? true,
      priceAlertsEnabled: json['priceAlertsEnabled'] as bool? ?? false,
    );
  }
}
