/// Geo & Regions Management Models
library;

class Region {
  final String id;
  final String name;
  final String countryCode;
  final String stateCode;
  final String cityCode;
  final GeoLocation center;
  final GeoBoundary boundary;
  final List<ServiceArea> serviceAreas;
  final RegionSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  Region({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.stateCode,
    required this.cityCode,
    required this.center,
    required this.boundary,
    required this.serviceAreas,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as String,
        name: json['name'] as String,
        countryCode: json['country_code'] as String,
        stateCode: json['state_code'] as String,
        cityCode: json['city_code'] as String,
        center: GeoLocation.fromJson(json['center']),
        boundary: GeoBoundary.fromJson(json['boundary']),
        serviceAreas: (json['service_areas'] as List)
            .map((s) => ServiceArea.fromJson(s))
            .toList(),
        settings: RegionSettings.fromJson(json['settings']),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country_code': countryCode,
        'state_code': stateCode,
        'city_code': cityCode,
        'center': center.toJson(),
        'boundary': boundary.toJson(),
        'service_areas': serviceAreas.map((s) => s.toJson()).toList(),
        'settings': settings.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
        'is_active': isActive,
      };
}

class GeoLocation {
  final double latitude;
  final double longitude;
  final double? altitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: json['altitude'] != null
            ? (json['altitude'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (altitude != null) 'altitude': altitude,
      };
}

class GeoBoundary {
  final List<GeoLocation> coordinates;
  final String type;

  GeoBoundary({
    required this.coordinates,
    required this.type,
  });

  factory GeoBoundary.fromJson(Map<String, dynamic> json) => GeoBoundary(
        coordinates: (json['coordinates'] as List)
            .map((c) => GeoLocation.fromJson(c))
            .toList(),
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'coordinates': coordinates.map((c) => c.toJson()).toList(),
        'type': type,
      };
}

class ServiceArea {
  final String id;
  final String name;
  final GeoBoundary boundary;
  final double radiusKm;
  final List<String> serviceTypes;
  final ServiceAreaSettings settings;
  final bool isActive;

  ServiceArea({
    required this.id,
    required this.name,
    required this.boundary,
    required this.radiusKm,
    required this.serviceTypes,
    required this.settings,
    required this.isActive,
  });

  factory ServiceArea.fromJson(Map<String, dynamic> json) => ServiceArea(
        id: json['id'] as String,
        name: json['name'] as String,
        boundary: GeoBoundary.fromJson(json['boundary']),
        radiusKm: (json['radius_km'] as num).toDouble(),
        serviceTypes: List<String>.from(json['service_types'] ?? []),
        settings: ServiceAreaSettings.fromJson(json['settings']),
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'boundary': boundary.toJson(),
        'radius_km': radiusKm,
        'service_types': serviceTypes,
        'settings': settings.toJson(),
        'is_active': isActive,
      };
}

class RegionSettings {
  final String timezone;
  final String currency;
  final String language;
  final Map<String, dynamic> businessHours;
  final Map<String, dynamic> taxSettings;
  final Map<String, dynamic> deliverySettings;
  final Map<String, dynamic> customSettings;

  RegionSettings({
    required this.timezone,
    required this.currency,
    required this.language,
    required this.businessHours,
    required this.taxSettings,
    required this.deliverySettings,
    required this.customSettings,
  });

  factory RegionSettings.fromJson(Map<String, dynamic> json) => RegionSettings(
        timezone: json['timezone'] as String,
        currency: json['currency'] as String,
        language: json['language'] as String,
        businessHours: Map<String, dynamic>.from(json['business_hours'] ?? {}),
        taxSettings: Map<String, dynamic>.from(json['tax_settings'] ?? {}),
        deliverySettings:
            Map<String, dynamic>.from(json['delivery_settings'] ?? {}),
        customSettings:
            Map<String, dynamic>.from(json['custom_settings'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'timezone': timezone,
        'currency': currency,
        'language': language,
        'business_hours': businessHours,
        'tax_settings': taxSettings,
        'delivery_settings': deliverySettings,
        'custom_settings': customSettings,
      };
}

class ServiceAreaSettings {
  final double minOrderValue;
  final double deliveryFee;
  final int estimatedDeliveryDays;
  final List<String> supportedPaymentMethods;
  final Map<String, dynamic> restrictions;
  final Map<String, dynamic> features;

  ServiceAreaSettings({
    required this.minOrderValue,
    required this.deliveryFee,
    required this.estimatedDeliveryDays,
    required this.supportedPaymentMethods,
    required this.restrictions,
    required this.features,
  });

  factory ServiceAreaSettings.fromJson(Map<String, dynamic> json) =>
      ServiceAreaSettings(
        minOrderValue: (json['min_order_value'] as num).toDouble(),
        deliveryFee: (json['delivery_fee'] as num).toDouble(),
        estimatedDeliveryDays: json['estimated_delivery_days'] as int,
        supportedPaymentMethods:
            List<String>.from(json['supported_payment_methods'] ?? []),
        restrictions: Map<String, dynamic>.from(json['restrictions'] ?? {}),
        features: Map<String, dynamic>.from(json['features'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'min_order_value': minOrderValue,
        'delivery_fee': deliveryFee,
        'estimated_delivery_days': estimatedDeliveryDays,
        'supported_payment_methods': supportedPaymentMethods,
        'restrictions': restrictions,
        'features': features,
      };
}

class CityOverride {
  final String id;
  final String cityId;
  final String cityName;
  final Map<String, dynamic> overrides;
  final List<String> constraints;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  CityOverride({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.overrides,
    required this.constraints,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
  });

  factory CityOverride.fromJson(Map<String, dynamic> json) => CityOverride(
        id: json['id'] as String,
        cityId: json['city_id'] as String,
        cityName: json['city_name'] as String,
        overrides: Map<String, dynamic>.from(json['overrides'] ?? {}),
        constraints: List<String>.from(json['constraints'] ?? []),
        effectiveFrom: DateTime.parse(json['effective_from'] as String),
        effectiveUntil: json['effective_until'] != null
            ? DateTime.parse(json['effective_until'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdBy: json['created_by'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'city_id': cityId,
        'city_name': cityName,
        'overrides': overrides,
        'constraints': constraints,
        'effective_from': effectiveFrom.toIso8601String(),
        'effective_until': effectiveUntil?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'created_by': createdBy,
        'is_active': isActive,
      };
}

class AddressNormalization {
  final String id;
  final String originalAddress;
  final String normalizedAddress;
  final GeoLocation coordinates;
  final Map<String, dynamic> components;
  final double confidence;
  final DateTime processedAt;

  AddressNormalization({
    required this.id,
    required this.originalAddress,
    required this.normalizedAddress,
    required this.coordinates,
    required this.components,
    required this.confidence,
    required this.processedAt,
  });

  factory AddressNormalization.fromJson(Map<String, dynamic> json) =>
      AddressNormalization(
        id: json['id'] as String,
        originalAddress: json['original_address'] as String,
        normalizedAddress: json['normalized_address'] as String,
        coordinates: GeoLocation.fromJson(json['coordinates']),
        components: Map<String, dynamic>.from(json['components'] ?? {}),
        confidence: (json['confidence'] as num).toDouble(),
        processedAt: DateTime.parse(json['processed_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'original_address': originalAddress,
        'normalized_address': normalizedAddress,
        'coordinates': coordinates.toJson(),
        'components': components,
        'confidence': confidence,
        'processed_at': processedAt.toIso8601String(),
      };
}

// Request/Response Models

class CreateRegionRequest {
  final String name;
  final String countryCode;
  final String stateCode;
  final String cityCode;
  final GeoLocation center;
  final GeoBoundary boundary;
  final List<ServiceArea> serviceAreas;
  final RegionSettings settings;

  CreateRegionRequest({
    required this.name,
    required this.countryCode,
    required this.stateCode,
    required this.cityCode,
    required this.center,
    required this.boundary,
    required this.serviceAreas,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'country_code': countryCode,
        'state_code': stateCode,
        'city_code': cityCode,
        'center': center.toJson(),
        'boundary': boundary.toJson(),
        'service_areas': serviceAreas.map((s) => s.toJson()).toList(),
        'settings': settings.toJson(),
      };
}

class UpdateRegionRequest {
  final String? name;
  final GeoLocation? center;
  final GeoBoundary? boundary;
  final List<ServiceArea>? serviceAreas;
  final RegionSettings? settings;
  final bool? isActive;

  UpdateRegionRequest({
    this.name,
    this.center,
    this.boundary,
    this.serviceAreas,
    this.settings,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (center != null) 'center': center!.toJson(),
        if (boundary != null) 'boundary': boundary!.toJson(),
        if (serviceAreas != null)
          'service_areas': serviceAreas!.map((s) => s.toJson()).toList(),
        if (settings != null) 'settings': settings!.toJson(),
        if (isActive != null) 'is_active': isActive,
      };
}

class CreateCityOverrideRequest {
  final String cityId;
  final String cityName;
  final Map<String, dynamic> overrides;
  final List<String> constraints;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;

  CreateCityOverrideRequest({
    required this.cityId,
    required this.cityName,
    required this.overrides,
    required this.constraints,
    required this.effectiveFrom,
    this.effectiveUntil,
  });

  Map<String, dynamic> toJson() => {
        'city_id': cityId,
        'city_name': cityName,
        'overrides': overrides,
        'constraints': constraints,
        'effective_from': effectiveFrom.toIso8601String(),
        if (effectiveUntil != null)
          'effective_until': effectiveUntil!.toIso8601String(),
      };
}

class NormalizeAddressRequest {
  final String address;
  final String? countryCode;
  final bool validateCoordinates;

  NormalizeAddressRequest({
    required this.address,
    this.countryCode,
    required this.validateCoordinates,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        if (countryCode != null) 'country_code': countryCode,
        'validate_coordinates': validateCoordinates,
      };
}

class RegionListResponse {
  final List<Region> regions;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  RegionListResponse({
    required this.regions,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory RegionListResponse.fromJson(Map<String, dynamic> json) =>
      RegionListResponse(
        regions:
            (json['regions'] as List).map((r) => Region.fromJson(r)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class CityOverrideListResponse {
  final List<CityOverride> overrides;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  CityOverrideListResponse({
    required this.overrides,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory CityOverrideListResponse.fromJson(Map<String, dynamic> json) =>
      CityOverrideListResponse(
        overrides: (json['overrides'] as List)
            .map((o) => CityOverride.fromJson(o))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}
