// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_messaging_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseConversationsHash() =>
    r'c1c66dcccc9b036e58618f6339c9738b610e380f';

/// Stream all conversations for the current user
///
/// Copied from [firebaseConversations].
@ProviderFor(firebaseConversations)
final firebaseConversationsProvider =
    AutoDisposeStreamProvider<List<Conversation>>.internal(
  firebaseConversations,
  name: r'firebaseConversationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseConversationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseConversationsRef
    = AutoDisposeStreamProviderRef<List<Conversation>>;
String _$firebaseMessagesHash() => r'45b5a828bd4a6067b097deb70b72d105776bde73';

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

/// Stream messages for a specific conversation
///
/// Copied from [firebaseMessages].
@ProviderFor(firebaseMessages)
const firebaseMessagesProvider = FirebaseMessagesFamily();

/// Stream messages for a specific conversation
///
/// Copied from [firebaseMessages].
class FirebaseMessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// Stream messages for a specific conversation
  ///
  /// Copied from [firebaseMessages].
  const FirebaseMessagesFamily();

  /// Stream messages for a specific conversation
  ///
  /// Copied from [firebaseMessages].
  FirebaseMessagesProvider call(
    String conversationId,
  ) {
    return FirebaseMessagesProvider(
      conversationId,
    );
  }

  @override
  FirebaseMessagesProvider getProviderOverride(
    covariant FirebaseMessagesProvider provider,
  ) {
    return call(
      provider.conversationId,
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
  String? get name => r'firebaseMessagesProvider';
}

/// Stream messages for a specific conversation
///
/// Copied from [firebaseMessages].
class FirebaseMessagesProvider
    extends AutoDisposeStreamProvider<List<Message>> {
  /// Stream messages for a specific conversation
  ///
  /// Copied from [firebaseMessages].
  FirebaseMessagesProvider(
    String conversationId,
  ) : this._internal(
          (ref) => firebaseMessages(
            ref as FirebaseMessagesRef,
            conversationId,
          ),
          from: firebaseMessagesProvider,
          name: r'firebaseMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseMessagesHash,
          dependencies: FirebaseMessagesFamily._dependencies,
          allTransitiveDependencies:
              FirebaseMessagesFamily._allTransitiveDependencies,
          conversationId: conversationId,
        );

  FirebaseMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<List<Message>> Function(FirebaseMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseMessagesProvider._internal(
        (ref) => create(ref as FirebaseMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Message>> createElement() {
    return _FirebaseMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseMessagesProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseMessagesRef on AutoDisposeStreamProviderRef<List<Message>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _FirebaseMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<Message>>
    with FirebaseMessagesRef {
  _FirebaseMessagesProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as FirebaseMessagesProvider).conversationId;
}

String _$firebaseConversationHash() =>
    r'fd6de73059de3029c89fa5011ab78f8401a03ef0';

/// Get a single conversation by ID
///
/// Copied from [firebaseConversation].
@ProviderFor(firebaseConversation)
const firebaseConversationProvider = FirebaseConversationFamily();

/// Get a single conversation by ID
///
/// Copied from [firebaseConversation].
class FirebaseConversationFamily extends Family<AsyncValue<Conversation?>> {
  /// Get a single conversation by ID
  ///
  /// Copied from [firebaseConversation].
  const FirebaseConversationFamily();

  /// Get a single conversation by ID
  ///
  /// Copied from [firebaseConversation].
  FirebaseConversationProvider call(
    String conversationId,
  ) {
    return FirebaseConversationProvider(
      conversationId,
    );
  }

  @override
  FirebaseConversationProvider getProviderOverride(
    covariant FirebaseConversationProvider provider,
  ) {
    return call(
      provider.conversationId,
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
  String? get name => r'firebaseConversationProvider';
}

/// Get a single conversation by ID
///
/// Copied from [firebaseConversation].
class FirebaseConversationProvider
    extends AutoDisposeStreamProvider<Conversation?> {
  /// Get a single conversation by ID
  ///
  /// Copied from [firebaseConversation].
  FirebaseConversationProvider(
    String conversationId,
  ) : this._internal(
          (ref) => firebaseConversation(
            ref as FirebaseConversationRef,
            conversationId,
          ),
          from: firebaseConversationProvider,
          name: r'firebaseConversationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firebaseConversationHash,
          dependencies: FirebaseConversationFamily._dependencies,
          allTransitiveDependencies:
              FirebaseConversationFamily._allTransitiveDependencies,
          conversationId: conversationId,
        );

  FirebaseConversationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<Conversation?> Function(FirebaseConversationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirebaseConversationProvider._internal(
        (ref) => create(ref as FirebaseConversationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Conversation?> createElement() {
    return _FirebaseConversationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirebaseConversationProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FirebaseConversationRef on AutoDisposeStreamProviderRef<Conversation?> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _FirebaseConversationProviderElement
    extends AutoDisposeStreamProviderElement<Conversation?>
    with FirebaseConversationRef {
  _FirebaseConversationProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as FirebaseConversationProvider).conversationId;
}

String _$messagingServiceHash() => r'c68ef8788836bcbdfcbb98a6cb65f9e89631ae3e';

/// Service for messaging operations (send, create conversation, etc.)
///
/// Copied from [messagingService].
@ProviderFor(messagingService)
final messagingServiceProvider = AutoDisposeProvider<MessagingService>.internal(
  messagingService,
  name: r'messagingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messagingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MessagingServiceRef = AutoDisposeProviderRef<MessagingService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
