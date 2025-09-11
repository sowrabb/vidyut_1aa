// Admin models for State Flow Management
// Comprehensive content management system for all state flow entities

import '../../stateinfo/models/state_info_models.dart';

// Custom Field System
enum CustomFieldType {
  text,
  multilineText,
  richText,
  number,
  currency,
  percentage,
  date,
  dateTime,
  email,
  phone,
  url,
  dropdown,
  multiSelect,
  checkbox,
  radio,
  file,
  image,
  location,
  relationship,
}

class CustomField {
  final String id;
  final String name;
  final String label;
  final CustomFieldType type;
  final bool isRequired;
  final String? placeholder;
  final String? helpText;
  final Map<String, dynamic>? options; // For dropdowns, validation rules, etc.
  final List<String>? choices; // For dropdown/radio/checkbox options
  final dynamic defaultValue;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomField({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.placeholder,
    this.helpText,
    this.options,
    this.choices,
    this.defaultValue,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'label': label,
        'type': type.name,
        'isRequired': isRequired,
        'placeholder': placeholder,
        'helpText': helpText,
        'options': options,
        'choices': choices,
        'defaultValue': defaultValue,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        id: json['id'] as String,
        name: json['name'] as String,
        label: json['label'] as String,
        type: CustomFieldType.values.byName(json['type'] as String),
        isRequired: json['isRequired'] as bool? ?? false,
        placeholder: json['placeholder'] as String?,
        helpText: json['helpText'] as String?,
        options: json['options'] as Map<String, dynamic>?,
        choices: (json['choices'] as List<dynamic>?)?.cast<String>(),
        defaultValue: json['defaultValue'],
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  CustomField copyWith({
    String? name,
    String? label,
    CustomFieldType? type,
    bool? isRequired,
    String? placeholder,
    String? helpText,
    Map<String, dynamic>? options,
    List<String>? choices,
    dynamic defaultValue,
    bool? isActive,
    DateTime? updatedAt,
  }) => CustomField(
        id: id,
        name: name ?? this.name,
        label: label ?? this.label,
        type: type ?? this.type,
        isRequired: isRequired ?? this.isRequired,
        placeholder: placeholder ?? this.placeholder,
        helpText: helpText ?? this.helpText,
        options: options ?? this.options,
        choices: choices ?? this.choices,
        defaultValue: defaultValue ?? this.defaultValue,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}

// Custom Tab System
class CustomTab {
  final String id;
  final String name;
  final String label;
  final String? icon;
  final String? description;
  final int order;
  final bool isActive;
  final List<CustomField> fields;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomTab({
    required this.id,
    required this.name,
    required this.label,
    this.icon,
    this.description,
    this.order = 0,
    this.isActive = true,
    this.fields = const [],
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'label': label,
        'icon': icon,
        'description': description,
        'order': order,
        'isActive': isActive,
        'fields': fields.map((f) => f.toJson()).toList(),
        'settings': settings,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CustomTab.fromJson(Map<String, dynamic> json) => CustomTab(
        id: json['id'] as String,
        name: json['name'] as String,
        label: json['label'] as String,
        icon: json['icon'] as String?,
        description: json['description'] as String?,
        order: json['order'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        fields: (json['fields'] as List<dynamic>?)
                ?.map((f) => CustomField.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [],
        settings: json['settings'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  CustomTab copyWith({
    String? name,
    String? label,
    String? icon,
    String? description,
    int? order,
    bool? isActive,
    List<CustomField>? fields,
    Map<String, dynamic>? settings,
    DateTime? updatedAt,
  }) => CustomTab(
        id: id,
        name: name ?? this.name,
        label: label ?? this.label,
        icon: icon ?? this.icon,
        description: description ?? this.description,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
        fields: fields ?? this.fields,
        settings: settings ?? this.settings,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}

// Entity Template System
enum EntityType {
  powerGenerator,
  transmissionLine,
  distributionCompany,
  indianState,
  mandal,
}

class EntityTemplate {
  final String id;
  final String name;
  final EntityType entityType;
  final String description;
  final List<CustomTab> tabs;
  final List<CustomField> globalFields;
  final Map<String, dynamic>? defaultValues;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EntityTemplate({
    required this.id,
    required this.name,
    required this.entityType,
    required this.description,
    this.tabs = const [],
    this.globalFields = const [],
    this.defaultValues,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'entityType': entityType.name,
        'description': description,
        'tabs': tabs.map((t) => t.toJson()).toList(),
        'globalFields': globalFields.map((f) => f.toJson()).toList(),
        'defaultValues': defaultValues,
        'isDefault': isDefault,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory EntityTemplate.fromJson(Map<String, dynamic> json) => EntityTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        entityType: EntityType.values.byName(json['entityType'] as String),
        description: json['description'] as String,
        tabs: (json['tabs'] as List<dynamic>?)
                ?.map((t) => CustomTab.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
        globalFields: (json['globalFields'] as List<dynamic>?)
                ?.map((f) => CustomField.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [],
        defaultValues: json['defaultValues'] as Map<String, dynamic>?,
        isDefault: json['isDefault'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

// Extended Entity Models with Custom Data
class AdminPowerGenerator extends PowerGenerator {
  final Map<String, dynamic> customFields;
  final List<String> activeTabIds;
  final bool isPublished;
  final DateTime? publishedAt;
  final String? featuredImageUrl;
  final List<String> tags;
  final Map<String, dynamic>? seoData;

  const AdminPowerGenerator({
    required super.id,
    required super.name,
    required super.type,
    required super.capacity,
    required super.location,
    required super.logo,
    required super.established,
    required super.founder,
    required super.ceo,
    required super.ceoPhoto,
    required super.headquarters,
    required super.phone,
    required super.email,
    required super.website,
    required super.description,
    required super.totalPlants,
    required super.employees,
    required super.revenue,
    required super.posts,
    this.customFields = const {},
    this.activeTabIds = const [],
    this.isPublished = true,
    this.publishedAt,
    this.featuredImageUrl,
    this.tags = const [],
    this.seoData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'capacity': capacity,
        'location': location,
        'logo': logo,
        'established': established,
        'founder': founder,
        'ceo': ceo,
        'ceoPhoto': ceoPhoto,
        'headquarters': headquarters,
        'phone': phone,
        'email': email,
        'website': website,
        'description': description,
        'totalPlants': totalPlants,
        'employees': employees,
        'revenue': revenue,
        'posts': posts.map((p) => {
              'id': p.id,
              'title': p.title,
              'content': p.content,
              'author': p.author,
              'time': p.time,
              'tags': p.tags,
              'imageUrl': p.imageUrl,
            }).toList(),
        'customFields': customFields,
        'activeTabIds': activeTabIds,
        'isPublished': isPublished,
        'publishedAt': publishedAt?.toIso8601String(),
        'featuredImageUrl': featuredImageUrl,
        'tags': tags,
        'seoData': seoData,
      };

  factory AdminPowerGenerator.fromJson(Map<String, dynamic> json) {
    final postsData = json['posts'] as List<dynamic>? ?? [];
    final posts = postsData.map((p) => Post(
          id: p['id'] as String,
          title: p['title'] as String,
          content: p['content'] as String,
          author: p['author'] as String,
          time: p['time'] as String,
          tags: (p['tags'] as List<dynamic>?)?.cast<String>() ?? [],
          imageUrl: p['imageUrl'] as String?,
        )).toList();

    return AdminPowerGenerator(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      capacity: json['capacity'] as String,
      location: json['location'] as String,
      logo: json['logo'] as String,
      established: json['established'] as String,
      founder: json['founder'] as String,
      ceo: json['ceo'] as String,
      ceoPhoto: json['ceoPhoto'] as String,
      headquarters: json['headquarters'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      description: json['description'] as String,
      totalPlants: json['totalPlants'] as int,
      employees: json['employees'] as String,
      revenue: json['revenue'] as String,
      posts: posts,
      customFields: json['customFields'] as Map<String, dynamic>? ?? {},
      activeTabIds: (json['activeTabIds'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublished: json['isPublished'] as bool? ?? true,
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      featuredImageUrl: json['featuredImageUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      seoData: json['seoData'] as Map<String, dynamic>?,
    );
  }

  AdminPowerGenerator copyWith({
    String? name,
    String? type,
    String? capacity,
    String? location,
    String? logo,
    String? established,
    String? founder,
    String? ceo,
    String? ceoPhoto,
    String? headquarters,
    String? phone,
    String? email,
    String? website,
    String? description,
    int? totalPlants,
    String? employees,
    String? revenue,
    List<Post>? posts,
    Map<String, dynamic>? customFields,
    List<String>? activeTabIds,
    bool? isPublished,
    DateTime? publishedAt,
    String? featuredImageUrl,
    List<String>? tags,
    Map<String, dynamic>? seoData,
  }) => AdminPowerGenerator(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        capacity: capacity ?? this.capacity,
        location: location ?? this.location,
        logo: logo ?? this.logo,
        established: established ?? this.established,
        founder: founder ?? this.founder,
        ceo: ceo ?? this.ceo,
        ceoPhoto: ceoPhoto ?? this.ceoPhoto,
        headquarters: headquarters ?? this.headquarters,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        website: website ?? this.website,
        description: description ?? this.description,
        totalPlants: totalPlants ?? this.totalPlants,
        employees: employees ?? this.employees,
        revenue: revenue ?? this.revenue,
        posts: posts ?? this.posts,
        customFields: customFields ?? this.customFields,
        activeTabIds: activeTabIds ?? this.activeTabIds,
        isPublished: isPublished ?? this.isPublished,
        publishedAt: publishedAt ?? this.publishedAt,
        featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
        tags: tags ?? this.tags,
        seoData: seoData ?? this.seoData,
      );
}

// Similar extended models for other entities would follow the same pattern
// AdminTransmissionLine, AdminDistributionCompany, AdminIndianState, AdminMandal

// Search and Filter Models
class StateFlowSearchFilter {
  final String? query;
  final EntityType? entityType;
  final List<String>? tags;
  final bool? isPublished;
  final String? location;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final Map<String, dynamic>? customFilters;

  const StateFlowSearchFilter({
    this.query,
    this.entityType,
    this.tags,
    this.isPublished,
    this.location,
    this.createdAfter,
    this.createdBefore,
    this.customFilters,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'entityType': entityType?.name,
        'tags': tags,
        'isPublished': isPublished,
        'location': location,
        'createdAfter': createdAfter?.toIso8601String(),
        'createdBefore': createdBefore?.toIso8601String(),
        'customFilters': customFilters,
      };

  StateFlowSearchFilter copyWith({
    String? query,
    EntityType? entityType,
    List<String>? tags,
    bool? isPublished,
    String? location,
    DateTime? createdAfter,
    DateTime? createdBefore,
    Map<String, dynamic>? customFilters,
  }) => StateFlowSearchFilter(
        query: query ?? this.query,
        entityType: entityType ?? this.entityType,
        tags: tags ?? this.tags,
        isPublished: isPublished ?? this.isPublished,
        location: location ?? this.location,
        createdAfter: createdAfter ?? this.createdAfter,
        createdBefore: createdBefore ?? this.createdBefore,
        customFilters: customFilters ?? this.customFilters,
      );
}

// Analytics and Reporting Models
class StateFlowAnalytics {
  final String entityId;
  final EntityType entityType;
  final int viewCount;
  final int uniqueViewers;
  final double avgTimeSpent;
  final Map<String, int> tabViews;
  final Map<String, int> searchTerms;
  final Map<String, int> deviceTypes;
  final Map<String, int> locations;
  final DateTime startDate;
  final DateTime endDate;

  const StateFlowAnalytics({
    required this.entityId,
    required this.entityType,
    required this.viewCount,
    required this.uniqueViewers,
    required this.avgTimeSpent,
    required this.tabViews,
    required this.searchTerms,
    required this.deviceTypes,
    required this.locations,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'entityType': entityType.name,
        'viewCount': viewCount,
        'uniqueViewers': uniqueViewers,
        'avgTimeSpent': avgTimeSpent,
        'tabViews': tabViews,
        'searchTerms': searchTerms,
        'deviceTypes': deviceTypes,
        'locations': locations,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}

// Media Management Models
class MediaAsset {
  final String id;
  final String filename;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String url;
  final String? thumbnailUrl;
  final Map<String, String>? variants; // Different sizes/formats
  final String? altText;
  final String? caption;
  final List<String> tags;
  final String uploadedBy;
  final DateTime uploadedAt;
  final bool isActive;

  const MediaAsset({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.url,
    this.thumbnailUrl,
    this.variants,
    this.altText,
    this.caption,
    this.tags = const [],
    required this.uploadedBy,
    required this.uploadedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'originalName': originalName,
        'mimeType': mimeType,
        'fileSize': fileSize,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'variants': variants,
        'altText': altText,
        'caption': caption,
        'tags': tags,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt.toIso8601String(),
        'isActive': isActive,
      };

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
        id: json['id'] as String,
        filename: json['filename'] as String,
        originalName: json['originalName'] as String,
        mimeType: json['mimeType'] as String,
        fileSize: json['fileSize'] as int,
        url: json['url'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        variants: (json['variants'] as Map<String, dynamic>?)?.cast<String, String>(),
        altText: json['altText'] as String?,
        caption: json['caption'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        uploadedBy: json['uploadedBy'] as String,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        isActive: json['isActive'] as bool? ?? true,
      );
}
