// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_hero_sections_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseActiveHeroSectionsHash() =>
    r'6f62b4ef5fa08b974ab31bfd79297cc5a12043c2';

/// Stream all active hero sections sorted by priority
///
/// Copied from [firebaseActiveHeroSections].
@ProviderFor(firebaseActiveHeroSections)
final firebaseActiveHeroSectionsProvider =
    AutoDisposeStreamProvider<List<HeroSection>>.internal(
  firebaseActiveHeroSections,
  name: r'firebaseActiveHeroSectionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseActiveHeroSectionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseActiveHeroSectionsRef
    = AutoDisposeStreamProviderRef<List<HeroSection>>;
String _$firebaseAllHeroSectionsHash() =>
    r'37ed52a4cba1cd891510118a8db11a01d91e0aac';

/// Stream all hero sections (admin view - includes inactive)
///
/// Copied from [firebaseAllHeroSections].
@ProviderFor(firebaseAllHeroSections)
final firebaseAllHeroSectionsProvider =
    AutoDisposeStreamProvider<List<HeroSection>>.internal(
  firebaseAllHeroSections,
  name: r'firebaseAllHeroSectionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAllHeroSectionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAllHeroSectionsRef
    = AutoDisposeStreamProviderRef<List<HeroSection>>;
String _$firebaseHeroSectionHash() =>
    r'8309ed56908f691d2b8bec866d852e313e12fa5c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get a single hero section by ID
///
/// Copied from [firebaseHeroSection].
@ProviderFor(firebaseHeroSection)
const firebaseHeroSectionProvider = FirebaseHeroSectionFamily();

/// Get a single hero section by ID
///
/// Copied from [firebaseHeroSection].
class FirebaseHeroSectionFamily extends Family<AsyncValue<HeroSection?>> {
  /// Get a single hero section by ID
  ///
  /// Copied from [firebaseHeroSection].
  const FirebaseHeroSectionFamily();

  /// Get a single hero section by ID
  ///
  /// Copied from [firebaseHeroSection].
  FirebaseHeroSectionProvider call(
    String heroSectionId,
  ) {
    return FirebaseHeroSectionProvider(
      heroSectionId,
    );
  }

  @override
  FirebaseHeroSectionProvider getProviderOverride(
    covariant FirebaseHeroSectionProvider provider,
  ) {
    return call(
      provider.heroSectionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'firebaseHeroSectionProvider';
}

/// Get a single hero section by ID
///
/// Copied from [firebaseHeroSection].
class FirebaseHeroSectionProvider
    extends AutoDisposeStreamProvider<HeroSection?> {
  /// Get a single hero section by ID
  ///
  /// Copied from [firebaseHeroSection].
  FirebaseHeroSectionProvider(
    String heroSectionId,
  ) : this._internal(
          (ref) => firebaseHeroSection(
            ref as FirebaseHeroSectionRef,
            heroSectionId,
          ),
          from: firebaseHeroSectionProvider,
          name: r'firebaseHeroSectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseHeroSectionHash,
          dependencies: FirebaseHeroSectionFamily._dependencies,
          allTransitiveDependencies:
              FirebaseHeroSectionFamily._allTransitiveDependencies,
          heroSectionId: heroSectionId,
        );

  FirebaseHeroSectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.heroSectionId,
  }) : super.internal();

  final String heroSectionId;

  @override
  Override overrideWith(
    Stream<HeroSection?> Function(FirebaseHeroSectionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseHeroSectionProvider._internal(
        (ref) => create(ref as FirebaseHeroSectionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        heroSectionId: heroSectionId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<HeroSection?> createElement() {
    return _FirebaseHeroSectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseHeroSectionProvider &&
        other.heroSectionId == heroSectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, heroSectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseHeroSectionRef on AutoDisposeStreamProviderRef<HeroSection?> {
  /// The parameter `heroSectionId` of this provider.
  String get heroSectionId;
}

class _FirebaseHeroSectionProviderElement
    extends AutoDisposeStreamProviderElement<HeroSection?>
    with FirebaseHeroSectionRef {
  _FirebaseHeroSectionProviderElement(super.provider);

  @override
  String get heroSectionId =>
      (origin as FirebaseHeroSectionProvider).heroSectionId;
}

String _$heroSectionServiceHash() =>
    r'13ff853d435997816d0f4c6beb5da7936d8bd161';

/// Service for hero section operations (admin only)
///
/// Copied from [heroSectionService].
@ProviderFor(heroSectionService)
final heroSectionServiceProvider =
    AutoDisposeProvider<HeroSectionService>.internal(
  heroSectionService,
  name: r'heroSectionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heroSectionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeroSectionServiceRef = AutoDisposeProviderRef<HeroSectionService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
