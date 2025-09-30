import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports
// import '../features/sell/models.dart';
import '../features/admin/models/hero_section.dart';
import '../features/admin/models/billing_models.dart';
import '../features/admin/models/notification.dart' as admin_notif;

// Service imports
import '../services/user_role_service.dart';
import '../services/analytics_service.dart';
import '../services/otp_auth_service.dart';
import '../services/phone_auth_service.dart';
import '../services/simple_phone_auth_service.dart';
import '../services/user_profile_service.dart';
import '../services/search_service.dart';
import '../services/location_service.dart';

// Store imports
import '../features/profile/store/user_store.dart';
import '../features/messaging/messaging_store.dart';
import '../features/categories/categories_store.dart' as categories_store;
import '../services/location_aware_filter_service.dart';
import '../services/reviews_repository.dart';

// Store imports
import '../features/admin/store/admin_store.dart';
import '../features/admin/store/enhanced_admin_store.dart';
import '../features/admin/auth/admin_auth_service.dart';
import '../services/enhanced_admin_api_service.dart';
import '../features/sell/store/seller_store.dart';
import '../features/stateinfo/store/lightweight_state_info_store.dart';
import '../features/stateinfo/store/state_info_edit_store.dart';
import 'app_state_notifier.dart';
import 'app_state.dart';

// Import the base providers
import 'review_models.dart';
import 'unified_providers.dart';

// =============================================================================
// REVIEWS PROVIDERS
// =============================================================================

class ReviewsList {
  final List<Review> reviews;
  final double averageRating;
  final int totalCount;
  final Map<int, int> ratingDistribution; // rating -> count

  const ReviewsList({
    required this.reviews,
    required this.averageRating,
    required this.totalCount,
    required this.ratingDistribution,
  });
}

final reviewsProvider =
    AsyncNotifierProvider.family<ReviewsStore, ReviewsList, String>(
        ReviewsStore.new);

class ReviewsStore extends FamilyAsyncNotifier<ReviewsList, String> {
  @override
  Future<ReviewsList> build(String productId) async {
    return _loadReviews(productId);
  }

  Future<ReviewsList> _loadReviews(String productId) async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final allProducts = demoDataService.allProducts;

    final product = allProducts.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      throw Exception('Product not found: $productId');
    }

    // For demo purposes, generate some mock reviews
    final reviews = <Review>[];
    final ratingDistribution = <int, int>{};
    double totalRating = 0;

    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = 0;
    }

    // Generate mock reviews
    for (int i = 0; i < 10; i++) {
      final rating = (i % 5) + 1;
      final review = Review(
        id: 'review_${productId}_$i',
        productId: productId,
        userId: 'user_$i',
        authorDisplay: 'User $i',
        rating: rating,
        body: 'This is a great product! Highly recommended.',
        createdAt: DateTime.now().subtract(Duration(days: i)),
        images: [],
      );

      reviews.add(review);
      ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      totalRating += rating;
    }

    final averageRating =
        reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

    return ReviewsList(
      reviews: reviews,
      averageRating: averageRating,
      totalCount: reviews.length,
      ratingDistribution: ratingDistribution,
    );
  }
}

class ReviewDraft {
  final String productId;
  final int rating;
  final String comment;
  final List<String> imageUrls;

  const ReviewDraft({
    required this.productId,
    required this.rating,
    required this.comment,
    required this.imageUrls,
  });

  ReviewDraft copyWith({
    String? productId,
    int? rating,
    String? comment,
    List<String>? imageUrls,
  }) {
    return ReviewDraft(
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

final reviewComposerProvider =
    NotifierProvider<ReviewComposerStore, ReviewDraft?>(
        ReviewComposerStore.new);

class ReviewComposerStore extends Notifier<ReviewDraft?> {
  @override
  ReviewDraft? build() {
    return null;
  }

  void startComposing(String productId) {
    state = ReviewDraft(
      productId: productId,
      rating: 5,
      comment: '',
      imageUrls: [],
    );
  }

  void updateRating(int rating) {
    if (state != null) {
      state = state!.copyWith(rating: rating);
    }
  }

  void updateComment(String comment) {
    if (state != null) {
      state = state!.copyWith(comment: comment);
    }
  }

  void addImage(String imageUrl) {
    if (state != null) {
      final images = List<String>.from(state!.imageUrls);
      images.add(imageUrl);
      state = state!.copyWith(imageUrls: images);
    }
  }

  void removeImage(String imageUrl) {
    if (state != null) {
      final images = List<String>.from(state!.imageUrls);
      images.remove(imageUrl);
      state = state!.copyWith(imageUrls: images);
    }
  }

  Future<void> submit() async {
    if (state == null) return;

    // In real app, this would call reviews service
    // For now, just clear the draft
    state = null;

    // Invalidate reviews provider for this product
    ref.invalidate(reviewsProvider(state!.productId));
  }

  void cancel() {
    state = null;
  }
}

// =============================================================================
// STATE INFO PROVIDERS
// =============================================================================

class StateInfoFeed {
  final List<StateInfoItem> items;
  final Map<String, dynamic> metadata;

  const StateInfoFeed({
    required this.items,
    required this.metadata,
  });
}

class StateInfoItem {
  final String id;
  final String title;
  final String content;
  final String type; // 'article', 'video', 'infographic'
  final String? imageUrl;
  final List<String> tags;
  final DateTime publishedAt;

  const StateInfoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.imageUrl,
    required this.tags,
    required this.publishedAt,
  });
}

final stateInfoProvider = AsyncNotifierProvider.family<StateInfoStore,
    StateInfoFeed, Map<String, dynamic>>(StateInfoStore.new);

class StateInfoStore
    extends FamilyAsyncNotifier<StateInfoFeed, Map<String, dynamic>> {
  @override
  Future<StateInfoFeed> build(Map<String, dynamic> filters) async {
    return _loadStateInfo(filters);
  }

  Future<StateInfoFeed> _loadStateInfo(Map<String, dynamic> filters) async {
    // Generate mock state info items based on filters
    final items = <StateInfoItem>[];

    final region = filters['region'] as String?;
    final topic = filters['topic'] as String?;

    // Create mock items
    for (int i = 0; i < 10; i++) {
      final item = StateInfoItem(
        id: 'state_info_$i',
        title: '${region ?? 'National'} Power Sector Update $i',
        content: 'This is detailed content about power sector developments...',
        type: ['article', 'video', 'infographic'][i % 3],
        imageUrl: 'https://example.com/image_$i.jpg',
        tags: [region ?? 'national', topic ?? 'power', 'energy'],
        publishedAt: DateTime.now().subtract(Duration(days: i)),
      );

      items.add(item);
    }

    return StateInfoFeed(
      items: items,
      metadata: {
        'region': region,
        'topic': topic,
        'totalItems': items.length,
      },
    );
  }
}

class CompareResult {
  final String region1;
  final String region2;
  final Map<String, dynamic> comparison;

  const CompareResult({
    required this.region1,
    required this.region2,
    required this.comparison,
  });
}

final stateInfoCompareProvider = AsyncNotifierProvider.family<
    StateInfoCompareStore,
    CompareResult,
    List<String>>(StateInfoCompareStore.new);

class StateInfoCompareStore
    extends FamilyAsyncNotifier<CompareResult, List<String>> {
  @override
  Future<CompareResult> build(List<String> regions) async {
    if (regions.length != 2) {
      throw Exception('Exactly 2 regions required for comparison');
    }

    return _compareRegions(regions[0], regions[1]);
  }

  Future<CompareResult> _compareRegions(String region1, String region2) async {
    // Mock comparison data
    final comparison = {
      'powerGeneration': {
        region1: {'total': 1000, 'renewable': 300, 'thermal': 700},
        region2: {'total': 800, 'renewable': 400, 'thermal': 400},
      },
      'consumption': {
        region1: {'residential': 400, 'commercial': 300, 'industrial': 300},
        region2: {'residential': 350, 'commercial': 250, 'industrial': 200},
      },
      'efficiency': {
        region1: 85.5,
        region2: 92.3,
      },
    };

    return CompareResult(
      region1: region1,
      region2: region2,
      comparison: comparison,
    );
  }
}

// =============================================================================
// LOCATION PROVIDERS
// =============================================================================

class LocationPrefs {
  final String selectedRegion;
  final double radiusKm;
  final List<String> savedPlaces;
  final double? latitude;
  final double? longitude;

  const LocationPrefs({
    required this.selectedRegion,
    required this.radiusKm,
    required this.savedPlaces,
    this.latitude,
    this.longitude,
  });

  LocationPrefs copyWith({
    String? selectedRegion,
    double? radiusKm,
    List<String>? savedPlaces,
    double? latitude,
    double? longitude,
  }) {
    return LocationPrefs(
      selectedRegion: selectedRegion ?? this.selectedRegion,
      radiusKm: radiusKm ?? this.radiusKm,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

final locationProvider =
    NotifierProvider<LocationStore, LocationPrefs>(LocationStore.new);

class LocationStore extends Notifier<LocationPrefs> {
  @override
  LocationPrefs build() {
    _loadLocationPrefs();
    return const LocationPrefs(
      selectedRegion: 'Hyderabad',
      radiusKm: 25.0,
      savedPlaces: [],
    );
  }

  void _loadLocationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final region = prefs.getString('selected_region') ?? 'Hyderabad';
    final radius = prefs.getDouble('radius_km') ?? 25.0;
    final savedPlaces = prefs.getStringList('saved_places') ?? [];
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');

    state = LocationPrefs(
      selectedRegion: region,
      radiusKm: radius,
      savedPlaces: savedPlaces,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> updateRegion(String region,
      {double? latitude, double? longitude}) async {
    state = state.copyWith(
      selectedRegion: region,
      latitude: latitude,
      longitude: longitude,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_region', region);
    if (latitude != null) await prefs.setDouble('latitude', latitude);
    if (longitude != null) await prefs.setDouble('longitude', longitude);
  }

  Future<void> updateRadius(double radiusKm) async {
    state = state.copyWith(radiusKm: radiusKm);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('radius_km', radiusKm);
  }

  Future<void> addSavedPlace(String place) async {
    final places = List<String>.from(state.savedPlaces);
    if (!places.contains(place)) {
      places.add(place);
      state = state.copyWith(savedPlaces: places);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_places', places);
    }
  }

  Future<void> removeSavedPlace(String place) async {
    final places = List<String>.from(state.savedPlaces);
    places.remove(place);
    state = state.copyWith(savedPlaces: places);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_places', places);
  }
}

class Region {
  final String id;
  final String name;
  final String type; // 'state', 'district', 'city'
  final String? parentId;
  final double? latitude;
  final double? longitude;

  const Region({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.latitude,
    this.longitude,
  });
}

final geodataProvider =
    AsyncNotifierProvider<GeodataStore, List<Region>>(GeodataStore.new);

class GeodataStore extends AsyncNotifier<List<Region>> {
  @override
  Future<List<Region>> build() async {
    return _loadRegions();
  }

  Future<List<Region>> _loadRegions() async {
    // Mock region data
    final regions = <Region>[
      const Region(
          id: 'tg',
          name: 'Telangana',
          type: 'state',
          latitude: 17.3850,
          longitude: 78.4867),
      const Region(
          id: 'ap',
          name: 'Andhra Pradesh',
          type: 'state',
          latitude: 15.9129,
          longitude: 79.7400),
      const Region(
          id: 'ka',
          name: 'Karnataka',
          type: 'state',
          latitude: 12.9716,
          longitude: 77.5946),
      const Region(
          id: 'mh',
          name: 'Maharashtra',
          type: 'state',
          latitude: 19.0760,
          longitude: 72.8777),
      const Region(
          id: 'hyd',
          name: 'Hyderabad',
          type: 'city',
          parentId: 'tg',
          latitude: 17.3850,
          longitude: 78.4867),
      const Region(
          id: 'vizag',
          name: 'Visakhapatnam',
          type: 'city',
          parentId: 'ap',
          latitude: 17.6868,
          longitude: 83.2185),
      const Region(
          id: 'blr',
          name: 'Bangalore',
          type: 'city',
          parentId: 'ka',
          latitude: 12.9716,
          longitude: 77.5946),
      const Region(
          id: 'mum',
          name: 'Mumbai',
          type: 'city',
          parentId: 'mh',
          latitude: 19.0760,
          longitude: 72.8777),
    ];

    return regions;
  }
}

// =============================================================================
// STATE INFO NAVIGATION PROVIDER
// =============================================================================

class StateInfoNavState {
  final List<String> anchors; // Table of contents
  final String? currentSection;
  final Map<String, double> sectionPositions; // For scroll sync

  const StateInfoNavState({
    required this.anchors,
    this.currentSection,
    required this.sectionPositions,
  });

  StateInfoNavState copyWith({
    List<String>? anchors,
    String? currentSection,
    Map<String, double>? sectionPositions,
  }) {
    return StateInfoNavState(
      anchors: anchors ?? this.anchors,
      currentSection: currentSection ?? this.currentSection,
      sectionPositions: sectionPositions ?? this.sectionPositions,
    );
  }
}

final stateInfoNavProvider =
    NotifierProvider<StateInfoNavStore, StateInfoNavState>(
        StateInfoNavStore.new);

class StateInfoNavStore extends Notifier<StateInfoNavState> {
  @override
  StateInfoNavState build() {
    return const StateInfoNavState(
      anchors: [],
      sectionPositions: {},
    );
  }

  void updateAnchors(List<String> anchors) {
    state = state.copyWith(anchors: anchors);
  }

  void setCurrentSection(String section) {
    state = state.copyWith(currentSection: section);
  }

  void updateSectionPosition(String section, double position) {
    final positions = Map<String, double>.from(state.sectionPositions);
    positions[section] = position;
    state = state.copyWith(sectionPositions: positions);
  }
}

// =============================================================================
// ADMIN NOTIFICATIONS PROVIDER
// =============================================================================

class BroadcastCenter {
  final List<admin_notif.NotificationTemplate> templates;
  final List<Map<String, dynamic>> history; // Placeholder for BroadcastHistory
  final List<Map<String, dynamic>>
      deliverySummaries; // Placeholder for DeliverySummary

  const BroadcastCenter({
    required this.templates,
    required this.history,
    required this.deliverySummaries,
  });
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsStore, BroadcastCenter>(
        NotificationsStore.new);

class NotificationsStore extends AsyncNotifier<BroadcastCenter> {
  @override
  Future<BroadcastCenter> build() async {
    return _loadBroadcastCenter();
  }

  Future<BroadcastCenter> _loadBroadcastCenter() async {
    // For demo, create mock data
    final templates = <admin_notif.NotificationTemplate>[];
    final history = <Map<String, dynamic>>[];
    final deliverySummaries = <Map<String, dynamic>>[];

    return BroadcastCenter(
      templates: templates,
      history: history,
      deliverySummaries: deliverySummaries,
    );
  }
}

// =============================================================================
// ADMIN KYC PROVIDER
// =============================================================================

class Paginated<T> {
  final List<T> items;
  final int totalCount;
  final bool hasMore;

  const Paginated({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });
}

class KycSubmission {
  final String id;
  final String userId;
  final String userName;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  final Map<String, dynamic> documents;

  const KycSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.submittedAt,
    required this.documents,
  });
}

final kycSubmissionsProvider =
    AsyncNotifierProvider<KycSubmissionsStore, Paginated<KycSubmission>>(
        KycSubmissionsStore.new);

class KycSubmissionsStore extends AsyncNotifier<Paginated<KycSubmission>> {
  @override
  Future<Paginated<KycSubmission>> build() async {
    return _loadKycSubmissions();
  }

  Future<Paginated<KycSubmission>> _loadKycSubmissions() async {
    // Mock KYC submissions
    final submissions = <KycSubmission>[];

    for (int i = 0; i < 20; i++) {
      final submission = KycSubmission(
        id: 'kyc_$i',
        userId: 'user_$i',
        userName: 'User $i',
        status: const ['pending', 'approved', 'rejected'][i % 3],
        submittedAt: DateTime.now().subtract(Duration(days: i)),
        documents: {
          'pan': 'https://example.com/pan_$i.pdf',
          'aadhar': 'https://example.com/aadhar_$i.pdf',
        },
      );

      submissions.add(submission);
    }

    return Paginated(
      items: submissions,
      totalCount: submissions.length,
      hasMore: false,
    );
  }

  Future<void> approveSubmission(String submissionId) async {
    // In real app, this would call KYC service
    ref.invalidateSelf();
  }

  Future<void> rejectSubmission(String submissionId, String reason) async {
    // In real app, this would call KYC service
    ref.invalidateSelf();
  }
}

// =============================================================================
// ADMIN HERO SECTIONS PROVIDER
// =============================================================================

final heroSectionsProvider =
    AsyncNotifierProvider<HeroSectionsStore, List<HeroSection>>(
        HeroSectionsStore.new);

class HeroSectionsStore extends AsyncNotifier<List<HeroSection>> {
  @override
  Future<List<HeroSection>> build() async {
    return _loadHeroSections();
  }

  Future<List<HeroSection>> _loadHeroSections() async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    return demoDataService.heroSections;
  }

  Future<void> updateHeroSection(HeroSection heroSection) async {
    // In real app, this would call hero sections service
    ref.invalidateSelf();
  }

  Future<void> reorderHeroSections(List<String> orderedIds) async {
    // In real app, this would call hero sections service
    ref.invalidateSelf();
  }
}

// =============================================================================
// ADMIN PRODUCT DESIGNS PROVIDER
// =============================================================================

class ProductDesignSchema {
  final String id;
  final String name;
  final Map<String, dynamic> attributes;
  final List<String> requiredFields;
  final DateTime createdAt;

  const ProductDesignSchema({
    required this.id,
    required this.name,
    required this.attributes,
    required this.requiredFields,
    required this.createdAt,
  });
}

final productDesignsProvider =
    AsyncNotifierProvider<ProductDesignsStore, List<ProductDesignSchema>>(
        ProductDesignsStore.new);

class ProductDesignsStore extends AsyncNotifier<List<ProductDesignSchema>> {
  @override
  Future<List<ProductDesignSchema>> build() async {
    return _loadProductDesigns();
  }

  Future<List<ProductDesignSchema>> _loadProductDesigns() async {
    // Mock product design schemas
    final schemas = <ProductDesignSchema>[];

    for (int i = 0; i < 5; i++) {
      final schema = ProductDesignSchema(
        id: 'design_$i',
        name: 'Product Design $i',
        attributes: {
          'category': 'string',
          'brand': 'string',
          'model': 'string',
          'specifications': 'object',
        },
        requiredFields: ['category', 'brand', 'model'],
        createdAt: DateTime.now().subtract(Duration(days: i)),
      );

      schemas.add(schema);
    }

    return schemas;
  }

  Future<void> createDesignSchema(ProductDesignSchema schema) async {
    // In real app, this would call product designs service
    ref.invalidateSelf();
  }

  Future<void> updateDesignSchema(ProductDesignSchema schema) async {
    // In real app, this would call product designs service
    ref.invalidateSelf();
  }
}

// =============================================================================
// SELLER ADS PROVIDERS
// =============================================================================

class AdCampaign {
  final String id;
  final String name;
  final String status; // 'active', 'paused', 'completed'
  final double budget;
  final double spent;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic> targeting;

  const AdCampaign({
    required this.id,
    required this.name,
    required this.status,
    required this.budget,
    required this.spent,
    required this.startDate,
    this.endDate,
    required this.targeting,
  });
}

final adsProvider =
    AsyncNotifierProvider<AdsStore, List<AdCampaign>>(AdsStore.new);

class AdsStore extends AsyncNotifier<List<AdCampaign>> {
  @override
  Future<List<AdCampaign>> build() async {
    return _loadAdCampaigns();
  }

  Future<List<AdCampaign>> _loadAdCampaigns() async {
    // Mock ad campaigns
    final campaigns = <AdCampaign>[];

    for (int i = 0; i < 3; i++) {
      final campaign = AdCampaign(
        id: 'ad_$i',
        name: 'Campaign $i',
        status: const ['active', 'paused', 'completed'][i],
        budget: 1000.0 + (i * 500),
        spent: 200.0 + (i * 100),
        startDate: DateTime.now().subtract(Duration(days: i * 10)),
        endDate: i == 2 ? DateTime.now().add(const Duration(days: 10)) : null,
        targeting: {
          'categories': ['electrical', 'tools'],
          'location': 'Hyderabad',
          'radius': 25.0,
        },
      );

      campaigns.add(campaign);
    }

    return campaigns;
  }
}

class AdDraft {
  final String? id;
  final String objective; // 'brand_awareness', 'lead_generation', 'sales'
  final Map<String, dynamic> audience;
  final List<String> placements;
  final double budget;
  final String status; // 'draft', 'review', 'approved'

  const AdDraft({
    this.id,
    required this.objective,
    required this.audience,
    required this.placements,
    required this.budget,
    required this.status,
  });

  AdDraft copyWith({
    String? id,
    String? objective,
    Map<String, dynamic>? audience,
    List<String>? placements,
    double? budget,
    String? status,
  }) {
    return AdDraft(
      id: id ?? this.id,
      objective: objective ?? this.objective,
      audience: audience ?? this.audience,
      placements: placements ?? this.placements,
      budget: budget ?? this.budget,
      status: status ?? this.status,
    );
  }
}

final adDraftProvider =
    NotifierProvider<AdDraftStore, AdDraft?>(AdDraftStore.new);

class AdDraftStore extends Notifier<AdDraft?> {
  @override
  AdDraft? build() {
    return null;
  }

  void startDraft() {
    state = const AdDraft(
      objective: 'brand_awareness',
      audience: {},
      placements: [],
      budget: 0.0,
      status: 'draft',
    );
  }

  void updateObjective(String objective) {
    if (state != null) {
      state = state!.copyWith(objective: objective);
    }
  }

  void updateAudience(Map<String, dynamic> audience) {
    if (state != null) {
      state = state!.copyWith(audience: audience);
    }
  }

  void updatePlacements(List<String> placements) {
    if (state != null) {
      state = state!.copyWith(placements: placements);
    }
  }

  void updateBudget(double budget) {
    if (state != null) {
      state = state!.copyWith(budget: budget);
    }
  }

  Future<void> submit() async {
    if (state == null) return;

    // In real app, this would call ads service
    state = state!.copyWith(status: 'review');

    // Refresh ads list
    ref.invalidate(adsProvider);
  }

  void cancel() {
    state = null;
  }
}

// =============================================================================
// SUBSCRIPTIONS & BILLING PROVIDERS
// =============================================================================

class Plan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingPeriod; // 'monthly', 'yearly'
  final List<String> features;
  final bool isPopular;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.features,
    required this.isPopular,
  });
}

final subscriptionPlansProvider =
    AsyncNotifierProvider<SubscriptionPlansStore, List<Plan>>(
        SubscriptionPlansStore.new);

class SubscriptionPlansStore extends AsyncNotifier<List<Plan>> {
  @override
  Future<List<Plan>> build() async {
    return _loadPlans();
  }

  Future<List<Plan>> _loadPlans() async {
    // Mock subscription plans
    final plans = <Plan>[
      const Plan(
        id: 'free',
        name: 'Free',
        description: 'Basic features for getting started',
        price: 0.0,
        billingPeriod: 'monthly',
        features: ['Basic listings', 'Limited messaging', 'Basic analytics'],
        isPopular: false,
      ),
      const Plan(
        id: 'pro',
        name: 'Pro',
        description: 'Advanced features for growing businesses',
        price: 999.0,
        billingPeriod: 'monthly',
        features: [
          'Unlimited listings',
          'Priority support',
          'Advanced analytics',
          'Custom branding'
        ],
        isPopular: true,
      ),
      const Plan(
        id: 'enterprise',
        name: 'Enterprise',
        description: 'Full-featured solution for large businesses',
        price: 2999.0,
        billingPeriod: 'monthly',
        features: [
          'Everything in Pro',
          'API access',
          'Dedicated support',
          'Custom integrations'
        ],
        isPopular: false,
      ),
    ];

    return plans;
  }
}

class BillingSnapshot {
  final List<Invoice> invoices;
  final List<Payment> payments;
  final double totalRevenue;
  final double pendingAmount;
  final Map<String, double> revenueByMonth;

  const BillingSnapshot({
    required this.invoices,
    required this.payments,
    required this.totalRevenue,
    required this.pendingAmount,
    required this.revenueByMonth,
  });
}

final billingProvider =
    AsyncNotifierProvider<BillingStore, BillingSnapshot>(BillingStore.new);

class BillingStore extends AsyncNotifier<BillingSnapshot> {
  @override
  Future<BillingSnapshot> build() async {
    return _loadBillingSnapshot();
  }

  Future<BillingSnapshot> _loadBillingSnapshot() async {
    final demoDataService = ref.read(lightweightDemoDataServiceProvider);
    final invoices = demoDataService.allInvoices;
    final payments = demoDataService.allPayments;

    double totalRevenue = 0.0;
    double pendingAmount = 0.0;
    final revenueByMonth = <String, double>{};

    for (final payment in payments) {
      totalRevenue += payment.amount;

      final monthKey =
          '${payment.createdAt.year}-${payment.createdAt.month.toString().padLeft(2, '0')}';
      revenueByMonth[monthKey] =
          (revenueByMonth[monthKey] ?? 0.0) + payment.amount;
    }

    for (final invoice in invoices) {
      if (invoice.status == InvoiceStatus.pending) {
        pendingAmount += invoice.totalAmount;
      }
    }

    return BillingSnapshot(
      invoices: invoices,
      payments: payments,
      totalRevenue: totalRevenue,
      pendingAmount: pendingAmount,
      revenueByMonth: revenueByMonth,
    );
  }
}

// =============================================================================
// MEDIA PROVIDERS
// =============================================================================

class MediaListing {
  final List<MediaItem> items;
  final Map<String, int> categoryCounts;

  const MediaListing({
    required this.items,
    required this.categoryCounts,
  });
}

class MediaItem {
  final String id;
  final String url;
  final String filename;
  final String type; // 'image', 'video', 'document'
  final int size;
  final DateTime uploadedAt;
  final String? category;

  const MediaItem({
    required this.id,
    required this.url,
    required this.filename,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.category,
  });
}

final mediaLibraryProvider =
    AsyncNotifierProvider<MediaLibraryStore, MediaListing>(
        MediaLibraryStore.new);

class MediaLibraryStore extends AsyncNotifier<MediaListing> {
  @override
  Future<MediaListing> build() async {
    return _loadMediaLibrary();
  }

  Future<MediaListing> _loadMediaLibrary() async {
    // Mock media library
    final items = <MediaItem>[];
    final categoryCounts = <String, int>{};

    for (int i = 0; i < 20; i++) {
      final type = ['image', 'video', 'document'][i % 3];
      final category = ['products', 'banners', 'documents'][i % 3];

      final item = MediaItem(
        id: 'media_$i',
        url: 'https://example.com/media_$i',
        filename:
            'file_$i.${type == 'image' ? 'jpg' : type == 'video' ? 'mp4' : 'pdf'}',
        type: type,
        size: 1024 * (i + 1),
        uploadedAt: DateTime.now().subtract(Duration(days: i)),
        category: category,
      );

      items.add(item);
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return MediaListing(
      items: items,
      categoryCounts: categoryCounts,
    );
  }
}

class UploadQueue {
  final List<UploadItem> items;

  const UploadQueue({
    required this.items,
  });

  UploadQueue copyWith({
    List<UploadItem>? items,
  }) {
    return UploadQueue(
      items: items ?? this.items,
    );
  }
}

class UploadItem {
  final String id;
  final String filename;
  final String status; // 'pending', 'uploading', 'completed', 'failed'
  final double progress;
  final String? error;

  const UploadItem({
    required this.id,
    required this.filename,
    required this.status,
    required this.progress,
    this.error,
  });

  UploadItem copyWith({
    String? id,
    String? filename,
    String? status,
    double? progress,
    String? error,
  }) {
    return UploadItem(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

final imageUploadProvider =
    NotifierProvider<ImageUploadStore, UploadQueue>(ImageUploadStore.new);

class ImageUploadStore extends Notifier<UploadQueue> {
  @override
  UploadQueue build() {
    return const UploadQueue(items: []);
  }

  void addUpload(String filename) {
    final item = UploadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filename: filename,
      status: 'pending',
      progress: 0.0,
    );

    final items = List<UploadItem>.from(state.items);
    items.add(item);
    state = UploadQueue(items: items);
  }

  void updateProgress(String itemId, double progress) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          status: progress >= 1.0 ? 'completed' : 'uploading',
          progress: progress,
        );
      }
      return item;
    }).toList();

    state = UploadQueue(items: items);
  }

  void markFailed(String itemId, String error) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(status: 'failed', error: error);
      }
      return item;
    }).toList();

    state = UploadQueue(items: items);
  }

  void removeItem(String itemId) {
    final items = state.items.where((item) => item.id != itemId).toList();
    state = UploadQueue(items: items);
  }
}

// =============================================================================
// FEATURE FLAGS PROVIDER
// =============================================================================

final featureFlagsProvider =
    AsyncNotifierProvider<FeatureFlagsStore, Map<String, bool>>(
        FeatureFlagsStore.new);

class FeatureFlagsStore extends AsyncNotifier<Map<String, bool>> {
  @override
  Future<Map<String, bool>> build() async {
    return _loadFeatureFlags();
  }

  Future<Map<String, bool>> _loadFeatureFlags() async {
    // Mock feature flags
    return {
      'push_notifications': true,
      'advanced_search': true,
      'video_reviews': false,
      'social_login': true,
      'dark_mode': true,
      'offline_mode': false,
      'analytics_tracking': true,
      'beta_features': false,
    };
  }

  Future<void> updateFlag(String flag, bool value) async {
    final current = await future;
    final updated = Map<String, bool>.from(current);
    updated[flag] = value;
    state = AsyncValue.data(updated);
  }
}

// =============================================================================
// ANALYTICS PROVIDER
// =============================================================================

class AnalyticsSnapshot {
  final Map<String, dynamic> metrics;
  final List<Map<String, dynamic>> events;
  final DateTime lastUpdated;

  const AnalyticsSnapshot({
    required this.metrics,
    required this.events,
    required this.lastUpdated,
  });
}

final analyticsProvider =
    AsyncNotifierProvider<AnalyticsStore, AnalyticsSnapshot>(
        AnalyticsStore.new);

class AnalyticsStore extends AsyncNotifier<AnalyticsSnapshot> {
  @override
  Future<AnalyticsSnapshot> build() async {
    return _loadAnalytics();
  }

  Future<AnalyticsSnapshot> _loadAnalytics() async {
    // Note: analyticsServiceProvider is not imported, using mock data for now

    // Get metrics from analytics service
    final metrics = {
      'total_users': 1000,
      'active_users': 750,
      'total_products': 5000,
      'total_leads': 250,
      'conversion_rate': 0.15,
    };

    final events = [
      {
        'type': 'user_signup',
        'count': 50,
        'date': DateTime.now().subtract(const Duration(days: 1))
      },
      {
        'type': 'product_view',
        'count': 1200,
        'date': DateTime.now().subtract(const Duration(days: 1))
      },
      {
        'type': 'lead_generated',
        'count': 25,
        'date': DateTime.now().subtract(const Duration(days: 1))
      },
    ];

    return AnalyticsSnapshot(
      metrics: metrics,
      events: events,
      lastUpdated: DateTime.now(),
    );
  }
}

// =============================================================================
// MIGRATED SERVICE PROVIDERS (from legacy riverpod_providers.dart)
// =============================================================================

// User Role Service Provider
final userRoleServiceProvider = ChangeNotifierProvider<UserRoleService>((ref) {
  return UserRoleService();
});

// Analytics Service Provider
final analyticsServiceProvider =
    ChangeNotifierProvider<AnalyticsService>((ref) {
  final svc = AnalyticsService()..seedDemoDataIfEmpty();
  return svc;
});

// OTP Authentication Service Provider
final otpAuthServiceProvider = ChangeNotifierProvider<OtpAuthService>((ref) {
  return OtpAuthService();
});

// Phone Authentication Service Provider
final phoneAuthServiceProvider =
    ChangeNotifierProvider<PhoneAuthService>((ref) {
  return PhoneAuthService();
});

// Simple Phone Authentication Service Provider
final simplePhoneAuthServiceProvider =
    ChangeNotifierProvider<SimplePhoneAuthService>((ref) {
  return SimplePhoneAuthService();
});

// User Profile Service Provider
final userProfileServiceProvider =
    ChangeNotifierProvider<UserProfileService>((ref) {
  return UserProfileService();
});

// Search Service Provider
final searchServiceProvider = FutureProvider<SearchService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final searchService =
      SearchService(prefs, firestore: FirebaseFirestore.instance);

  // Initialize with products from demo data service
  final demoDataService = ref.read(lightweightDemoDataServiceProvider);
  searchService.initializeWithProducts(demoDataService.allProducts);

  return searchService;
});

// Location Service Provider
final locationServiceProvider = FutureProvider<LocationService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LocationService(prefs);
});

// Location Aware Filter Service Provider
final locationAwareFilterServiceProvider =
    FutureProvider<LocationAwareFilterService>((ref) async {
  final locationServiceAsync = ref.watch(locationServiceProvider);
  final prefs = await SharedPreferences.getInstance();

  return locationServiceAsync.when(
    data: (locationService) {
      final filterService = LocationAwareFilterService(locationService, prefs);

      // Initialize with products from demo data service
      final demoDataService = ref.read(lightweightDemoDataServiceProvider);
      filterService.initializeWithProducts(demoDataService.allProducts);

      return filterService;
    },
    loading: () => throw Exception('LocationService not available'),
    error: (error, stack) => throw Exception('LocationService error: $error'),
  );
});

// Reviews Repository Provider
final reviewsRepositoryProvider =
    ChangeNotifierProvider<ReviewsRepository>((ref) {
  return ReviewsRepository(maxImagesPerReview: 6);
});

// =============================================================================
// MISSING SERVICE PROVIDERS
// =============================================================================

// Legacy Store Providers (for backward compatibility)
final appStateNotifierProvider =
    NotifierProvider<AppStateNotifier, AppStateData>(() {
  return AppStateNotifier();
});

final userStoreProvider = ChangeNotifierProvider<UserStore>((ref) {
  return UserStore();
});

// Alias for backward compatibility
final demoDataServiceProvider = lightweightDemoDataServiceProvider;

final messagingStoreProvider = ChangeNotifierProvider<MessagingStore>((ref) {
  final demo = ref.read(lightweightDemoDataServiceProvider);
  return MessagingStore(demo);
});

final categoriesStoreProvider =
    ChangeNotifierProvider<categories_store.CategoriesStore>((ref) {
  final appState = AppState();
  final demo = ref.read(lightweightDemoDataServiceProvider);
  return categories_store.CategoriesStore(appState, demo);
});

final adminStoreProvider = ChangeNotifierProvider<AdminStore>((ref) {
  final demo = ref.read(lightweightDemoDataServiceProvider);
  return AdminStore(demo);
});

final enhancedAdminStoreProvider =
    ChangeNotifierProvider<EnhancedAdminStore>((ref) {
  final demo = ref.read(lightweightDemoDataServiceProvider);
  return EnhancedAdminStore(
    apiService: EnhancedAdminApiService(),
    demoDataService: demo,
    useBackend: false,
  );
});

final sellerStoreProvider = ChangeNotifierProvider<SellerStore>((ref) {
  final demo = ref.read(lightweightDemoDataServiceProvider);
  return SellerStore(demo);
});

final stateInfoStoreProvider = Provider<StateInfoStore>((ref) {
  return StateInfoStore();
});

final lightweightStateInfoStoreProvider =
    ChangeNotifierProvider<LightweightStateInfoStore>((ref) {
  return LightweightStateInfoStore();
});

final stateInfoEditStoreProvider =
    ChangeNotifierProvider<StateInfoEditStore>((ref) {
  return StateInfoEditStore();
});

final adminAuthServiceProvider =
    ChangeNotifierProvider<AdminAuthService>((ref) {
  final enhanced = ref.read(enhancedAdminStoreProvider);
  final demo = ref.read(lightweightDemoDataServiceProvider);
  final rbac = ref.read(rbacServiceProvider);
  return AdminAuthService(enhanced, demo, rbac);
});

// Placeholder service classes for missing services
class DocumentManagementService extends ChangeNotifier {
  // TODO: Implement document management functionality
}

class ImageManagementService extends ChangeNotifier {
  // TODO: Implement image management functionality
}

class MediaStorageService extends ChangeNotifier {
  // TODO: Implement media storage functionality
}

// Document Management Service Provider
final documentManagementServiceProvider =
    ChangeNotifierProvider<DocumentManagementService>((ref) {
  return DocumentManagementService();
});

// Image Management Service Provider
final imageManagementServiceProvider =
    ChangeNotifierProvider<ImageManagementService>((ref) {
  return ImageManagementService();
});

// Media Storage Service Provider
final mediaStorageServiceProvider =
    ChangeNotifierProvider<MediaStorageService>((ref) {
  return MediaStorageService();
});

// =============================================================================
// ADMIN MANAGEMENT PROVIDERS
// =============================================================================

// Compliance Management Provider
final complianceManagementProvider =
    AsyncNotifierProvider<ComplianceManagementStore, ComplianceManagementData>(
        ComplianceManagementStore.new);

class ComplianceManagementData {
  final List<ComplianceItem> items;
  final Map<String, dynamic> statistics;
  final DateTime lastUpdated;

  const ComplianceManagementData({
    required this.items,
    required this.statistics,
    required this.lastUpdated,
  });
}

class ComplianceItem {
  final String id;
  final String name;
  final String status;
  final DateTime dueDate;
  final String description;

  const ComplianceItem({
    required this.id,
    required this.name,
    required this.status,
    required this.dueDate,
    required this.description,
  });
}

class ComplianceManagementStore
    extends AsyncNotifier<ComplianceManagementData> {
  @override
  Future<ComplianceManagementData> build() async {
    return _loadComplianceData();
  }

  Future<ComplianceManagementData> _loadComplianceData() async {
    // Mock compliance data
    final items = <ComplianceItem>[];
    final statistics = <String, dynamic>{
      'total_items': 0,
      'pending_items': 0,
      'completed_items': 0,
      'overdue_items': 0,
    };

    return ComplianceManagementData(
      items: items,
      statistics: statistics,
      lastUpdated: DateTime.now(),
    );
  }
}

// System Operations Management Provider
final systemOperationsManagementProvider = AsyncNotifierProvider<
    SystemOperationsManagementStore,
    SystemOperationsManagementData>(SystemOperationsManagementStore.new);

class SystemOperationsManagementData {
  final List<SystemOperation> operations;
  final Map<String, dynamic> metrics;
  final DateTime lastUpdated;

  const SystemOperationsManagementData({
    required this.operations,
    required this.metrics,
    required this.lastUpdated,
  });
}

class SystemOperation {
  final String id;
  final String name;
  final String status;
  final DateTime createdAt;
  final String description;

  const SystemOperation({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.description,
  });
}

class SystemOperationsManagementStore
    extends AsyncNotifier<SystemOperationsManagementData> {
  @override
  Future<SystemOperationsManagementData> build() async {
    return _loadSystemOperationsData();
  }

  Future<SystemOperationsManagementData> _loadSystemOperationsData() async {
    // Mock system operations data
    final operations = <SystemOperation>[];
    final metrics = <String, dynamic>{
      'total_operations': 0,
      'active_operations': 0,
      'completed_operations': 0,
      'failed_operations': 0,
    };

    return SystemOperationsManagementData(
      operations: operations,
      metrics: metrics,
      lastUpdated: DateTime.now(),
    );
  }
}

// Feature Flags Management Provider
final featureFlagsManagementProvider = AsyncNotifierProvider<
    FeatureFlagsManagementStore,
    FeatureFlagsManagementData>(FeatureFlagsManagementStore.new);

class FeatureFlagsManagementData {
  final Map<String, bool> flags;
  final List<FeatureFlagHistory> history;
  final DateTime lastUpdated;

  const FeatureFlagsManagementData({
    required this.flags,
    required this.history,
    required this.lastUpdated,
  });
}

class FeatureFlagHistory {
  final String flag;
  final bool value;
  final DateTime changedAt;
  final String changedBy;

  const FeatureFlagHistory({
    required this.flag,
    required this.value,
    required this.changedAt,
    required this.changedBy,
  });
}

class FeatureFlagsManagementStore
    extends AsyncNotifier<FeatureFlagsManagementData> {
  @override
  Future<FeatureFlagsManagementData> build() async {
    return _loadFeatureFlagsData();
  }

  Future<FeatureFlagsManagementData> _loadFeatureFlagsData() async {
    // Mock feature flags management data
    final flags = <String, bool>{
      'push_notifications': true,
      'advanced_search': true,
      'video_reviews': false,
      'social_login': true,
      'dark_mode': true,
      'offline_mode': false,
      'analytics_tracking': true,
      'beta_features': false,
    };

    final history = <FeatureFlagHistory>[];

    return FeatureFlagsManagementData(
      flags: flags,
      history: history,
      lastUpdated: DateTime.now(),
    );
  }
}

// Analytics Management Provider
final analyticsManagementProvider =
    AsyncNotifierProvider<AnalyticsManagementStore, AnalyticsManagementData>(
        AnalyticsManagementStore.new);

class AnalyticsManagementData {
  final Map<String, dynamic> metrics;
  final List<AnalyticsEvent> events;
  final Map<String, dynamic> configurations;
  final DateTime lastUpdated;

  const AnalyticsManagementData({
    required this.metrics,
    required this.events,
    required this.configurations,
    required this.lastUpdated,
  });
}

class AnalyticsEvent {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

class AnalyticsManagementStore extends AsyncNotifier<AnalyticsManagementData> {
  @override
  Future<AnalyticsManagementData> build() async {
    return _loadAnalyticsManagementData();
  }

  Future<AnalyticsManagementData> _loadAnalyticsManagementData() async {
    // Mock analytics management data
    final metrics = <String, dynamic>{
      'total_users': 1000,
      'active_users': 750,
      'total_products': 5000,
      'total_leads': 250,
      'conversion_rate': 0.15,
    };

    final events = <AnalyticsEvent>[];
    final configurations = <String, dynamic>{
      'tracking_enabled': true,
      'retention_days': 90,
      'real_time_enabled': true,
    };

    return AnalyticsManagementData(
      metrics: metrics,
      events: events,
      configurations: configurations,
      lastUpdated: DateTime.now(),
    );
  }
}

// Geo Data Management Provider
final geoDataManagementProvider =
    AsyncNotifierProvider<GeoDataManagementStore, GeoDataManagementData>(
        GeoDataManagementStore.new);

class GeoDataManagementData {
  final List<Region> regions;
  final Map<String, dynamic> statistics;
  final DateTime lastUpdated;

  const GeoDataManagementData({
    required this.regions,
    required this.statistics,
    required this.lastUpdated,
  });
}

class GeoDataManagementStore extends AsyncNotifier<GeoDataManagementData> {
  @override
  Future<GeoDataManagementData> build() async {
    return _loadGeoDataManagementData();
  }

  Future<GeoDataManagementData> _loadGeoDataManagementData() async {
    // Mock geo data management data
    final regions = <Region>[];
    final statistics = <String, dynamic>{
      'total_regions': 0,
      'active_regions': 0,
      'last_sync': DateTime.now(),
    };

    return GeoDataManagementData(
      regions: regions,
      statistics: statistics,
      lastUpdated: DateTime.now(),
    );
  }
}
