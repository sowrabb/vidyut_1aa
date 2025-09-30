import 'package:flutter/foundation.dart';

enum PlanStatus { draft, published, archived }

enum BillingInterval { monthly, quarterly, annual }

enum PriceStatus { active, deprecated }

enum SubscriptionState { active, pastDue, canceled, paused }

@immutable
class Plan {
  final String id;
  final String name;
  final String code;
  final String description;
  final PlanStatus status;
  final int defaultPointsPerCycle;
  final bool visiblePublicly;
  final int version;

  const Plan({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.status = PlanStatus.draft,
    this.defaultPointsPerCycle = 0,
    this.visiblePublicly = true,
    this.version = 1,
  });

  Plan copyWith({
    String? name,
    String? code,
    String? description,
    PlanStatus? status,
    int? defaultPointsPerCycle,
    bool? visiblePublicly,
    int? version,
  }) =>
      Plan(
        id: id,
        name: name ?? this.name,
        code: code ?? this.code,
        description: description ?? this.description,
        status: status ?? this.status,
        defaultPointsPerCycle:
            defaultPointsPerCycle ?? this.defaultPointsPerCycle,
        visiblePublicly: visiblePublicly ?? this.visiblePublicly,
        version: version ?? this.version,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'description': description,
        'status': status.toString().split('.').last,
        'default_points_per_cycle': defaultPointsPerCycle,
        'visible_publicly': visiblePublicly,
        'version': version,
      };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        description: json['description'] as String? ?? '',
        status: PlanStatus.values
            .firstWhere((s) => s.toString().split('.').last == json['status']),
        defaultPointsPerCycle: json['default_points_per_cycle'] as int? ?? 0,
        visiblePublicly: json['visible_publicly'] as bool? ?? true,
        version: json['version'] as int? ?? 1,
      );
}

@immutable
class Price {
  final String id;
  final String planId;
  final String currency;
  final BillingInterval interval;
  final int amountMinor; // e.g., paise
  final PriceStatus status;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;

  const Price({
    required this.id,
    required this.planId,
    this.currency = 'INR',
    this.interval = BillingInterval.monthly,
    required this.amountMinor,
    this.status = PriceStatus.active,
    this.effectiveFrom,
    this.effectiveTo,
  });

  Price copyWith({
    String? currency,
    BillingInterval? interval,
    int? amountMinor,
    PriceStatus? status,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
  }) =>
      Price(
        id: id,
        planId: planId,
        currency: currency ?? this.currency,
        interval: interval ?? this.interval,
        amountMinor: amountMinor ?? this.amountMinor,
        status: status ?? this.status,
        effectiveFrom: effectiveFrom ?? this.effectiveFrom,
        effectiveTo: effectiveTo ?? this.effectiveTo,
      );
}

@immutable
class PointsRule {
  final String id;
  final String planId;
  final int pointsPerCycle;
  final int rolloverCap;
  final int expirationDays;
  final int overageUnit;
  final int overagePriceMinor;

  const PointsRule({
    required this.id,
    required this.planId,
    required this.pointsPerCycle,
    this.rolloverCap = 0,
    this.expirationDays = 0,
    this.overageUnit = 0,
    this.overagePriceMinor = 0,
  });
}

@immutable
class Addon {
  final String id;
  final String name;
  final String description;
  final bool recurring;
  final int amountMinor;
  final String currency;
  final int pointsGranted;

  const Addon({
    required this.id,
    required this.name,
    this.description = '',
    this.recurring = false,
    this.amountMinor = 0,
    this.currency = 'INR',
    this.pointsGranted = 0,
  });
}

@immutable
class Promotion {
  final String id;
  final String code;
  final String description;
  final int percentOff; // 0-100
  final int amountOffMinor; // fixed
  final int bonusPoints; // optional
  final DateTime? startAt;
  final DateTime? endAt;

  const Promotion({
    required this.id,
    required this.code,
    this.description = '',
    this.percentOff = 0,
    this.amountOffMinor = 0,
    this.bonusPoints = 0,
    this.startAt,
    this.endAt,
  });
}

@immutable
class InvoiceLineItem {
  final String description;
  final int amountMinor;
  const InvoiceLineItem({required this.description, required this.amountMinor});
}

@immutable
class Invoice {
  final String id;
  final String subscriptionId;
  final int amountMinor;
  final String currency;
  final List<InvoiceLineItem> items;
  final String status; // paid | open | refunded
  const Invoice({
    required this.id,
    required this.subscriptionId,
    required this.amountMinor,
    this.currency = 'INR',
    this.items = const [],
    this.status = 'paid',
  });
}

@immutable
class Subscription {
  final String id;
  final String sellerId;
  final String planId;
  final String priceId;
  final SubscriptionState state;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final int accumulatedPoints;
  final int consumedPoints;

  const Subscription({
    required this.id,
    required this.sellerId,
    required this.planId,
    required this.priceId,
    this.state = SubscriptionState.active,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.accumulatedPoints = 0,
    this.consumedPoints = 0,
  });
}

@immutable
class PlanCardConfig {
  final String id;
  final String title;
  final String priceLabel;
  final String periodLabel; // e.g., "per year"; can be empty
  final List<String> features;
  final bool isPopular;

  const PlanCardConfig({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.periodLabel,
    required this.features,
    this.isPopular = false,
  });

  PlanCardConfig copyWith({
    String? title,
    String? priceLabel,
    String? periodLabel,
    List<String>? features,
    bool? isPopular,
  }) =>
      PlanCardConfig(
        id: id,
        title: title ?? this.title,
        priceLabel: priceLabel ?? this.priceLabel,
        periodLabel: periodLabel ?? this.periodLabel,
        features: features ?? this.features,
        isPopular: isPopular ?? this.isPopular,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priceLabel': priceLabel,
        'periodLabel': periodLabel,
        'features': features,
        'isPopular': isPopular,
      };
  String toJsonString() => toJson().toString();
  static PlanCardConfig fromJson(Map<String, dynamic> json) => PlanCardConfig(
        id: json['id'] as String,
        title: json['title'] as String,
        priceLabel: json['priceLabel'] as String,
        periodLabel: json['periodLabel'] as String? ?? '',
        features: (json['features'] as List).map((e) => e.toString()).toList(),
        isPopular: json['isPopular'] as bool? ?? false,
      );

  static PlanCardConfig fromJsonString(String s) {
    // naive parser for demo: expect Map-like string from toString().
    // For robustness, prefer real JSON; keeping light here.
    final content = s.substring(1, s.length - 1); // remove { }
    final parts = content.split(', ');
    final map = <String, dynamic>{};
    for (final p in parts) {
      final idx = p.indexOf(':');
      if (idx == -1) continue;
      final k = p.substring(0, idx).trim().replaceAll("'", '');
      final v = p.substring(idx + 1).trim();
      map[k] = v;
    }
    // features parsing is best-effort
    final featuresStr = map['features']?.toString() ?? '[]';
    final feats = featuresStr.length >= 2
        ? featuresStr
            .substring(1, featuresStr.length - 1)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];
    return PlanCardConfig(
      id: map['id']?.toString() ??
          'card_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title']?.toString() ?? '',
      priceLabel: map['priceLabel']?.toString() ?? '',
      periodLabel: map['periodLabel']?.toString() ?? '',
      features: feats,
      isPopular: map['isPopular']?.toString() == 'true',
    );
  }
}
