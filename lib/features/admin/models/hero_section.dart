class HeroSection {
  final String id;
  final String title;
  final String subtitle;
  final String? ctaText;
  final String? ctaUrl;
  final String? imageUrl;
  final String? imagePath; // Local path for uploaded images
  final int priority; // Lower number = higher priority (shows first)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HeroSection({
    required this.id,
    required this.title,
    required this.subtitle,
    this.ctaText,
    this.ctaUrl,
    this.imageUrl,
    this.imagePath,
    this.priority = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  HeroSection copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? ctaText,
    String? ctaUrl,
    String? imageUrl,
    String? imagePath,
    int? priority,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HeroSection(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      ctaText: ctaText ?? this.ctaText,
      ctaUrl: ctaUrl ?? this.ctaUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'ctaText': ctaText,
      'ctaUrl': ctaUrl,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'priority': priority,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HeroSection.fromJson(Map<String, dynamic> json) {
    return HeroSection(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      ctaText: json['ctaText'] as String?,
      ctaUrl: json['ctaUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
      priority: json['priority'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeroSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class HeroSectionFormData {
  late String title;
  late String subtitle;
  String? ctaText;
  String? ctaUrl;
  String? imagePath;
  late int priority;
  late bool isActive;

  HeroSectionFormData({
    required this.title,
    required this.subtitle,
    this.ctaText,
    this.ctaUrl,
    this.imagePath,
    this.priority = 0,
    this.isActive = true,
  });

  HeroSectionFormData.fromHeroSection(HeroSection hero) {
    title = hero.title;
    subtitle = hero.subtitle;
    ctaText = hero.ctaText;
    ctaUrl = hero.ctaUrl;
    imagePath = hero.imagePath;
    priority = hero.priority;
    isActive = hero.isActive;
  }

  bool get isValid => title.isNotEmpty && subtitle.isNotEmpty;

  HeroSection toHeroSection({String? id}) {
    final now = DateTime.now();
    return HeroSection(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      ctaText: ctaText?.isEmpty == true ? null : ctaText,
      ctaUrl: ctaUrl?.isEmpty == true ? null : ctaUrl,
      imagePath: imagePath?.isEmpty == true ? null : imagePath,
      priority: priority,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }
}
