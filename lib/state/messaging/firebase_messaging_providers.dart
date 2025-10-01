/// Firebase-backed messaging providers for real-time chat
/// Replaces in-memory MessagingStore with Firestore streams
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/messaging/models.dart';
import '../core/firebase_providers.dart';
import '../session/session_controller.dart';

part 'firebase_messaging_providers.g.dart';

/// Stream all conversations for the current user
@riverpod
Stream<List<Conversation>> firebaseConversations(FirebaseConversationsRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('conversations')
      .where('participants', arrayContains: userId)
      .orderBy('updated_at', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    final conversations = <Conversation>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      
      // Get messages subcollection
      final messagesSnapshot = await doc.reference
          .collection('messages')
          .orderBy('sent_at', descending: false)
          .get();

      final messages = messagesSnapshot.docs.map((msgDoc) {
        final msgData = msgDoc.data();
        return Message.fromJson({...msgData, 'id': msgDoc.id});
      }).toList();

      conversations.add(Conversation(
        id: doc.id,
        title: data['title'] as String? ?? '',
        subtitle: data['subtitle'] as String? ?? '',
        isPinned: data['is_pinned'] as bool? ?? false,
        isSupport: data['is_support'] as bool? ?? false,
        messages: messages,
        participants: List<String>.from(data['participants'] ?? []),
        updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        unreadCount: _calculateUnreadCount(messages, userId),
      ));
    }

    // Sort: pinned first, then by latest message
    conversations.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return conversations;
  });
}

/// Stream messages for a specific conversation
@riverpod
Stream<List<Message>> firebaseMessages(
  FirebaseMessagesRef ref,
  String conversationId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .orderBy('sent_at', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Message.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single conversation by ID
@riverpod
Stream<Conversation?> firebaseConversation(
  FirebaseConversationRef ref,
  String conversationId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final session = ref.watch(sessionControllerProvider);
  final userId = session.userId;

  return firestore
      .collection('conversations')
      .doc(conversationId)
      .snapshots()
      .asyncMap((doc) async {
    if (!doc.exists) return null;

    final data = doc.data()!;

    // Get messages subcollection
    final messagesSnapshot = await doc.reference
        .collection('messages')
        .orderBy('sent_at', descending: false)
        .get();

    final messages = messagesSnapshot.docs.map((msgDoc) {
      final msgData = msgDoc.data();
      return Message.fromJson({...msgData, 'id': msgDoc.id});
    }).toList();

    return Conversation(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      isPinned: data['is_pinned'] as bool? ?? false,
      isSupport: data['is_support'] as bool? ?? false,
      messages: messages,
      participants: List<String>.from(data['participants'] ?? []),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: _calculateUnreadCount(messages, userId ?? ''),
    );
  });
}

/// Calculate unread message count
int _calculateUnreadCount(List<Message> messages, String userId) {
  return messages.where((msg) => 
    msg.senderType != MessageSenderType.me && 
    !msg.isRead
  ).length;
}

/// Service for messaging operations (send, create conversation, etc.)
@riverpod
MessagingService messagingService(MessagingServiceRef ref) {
  return MessagingService(
    firestore: ref.watch(firebaseFirestoreProvider),
    getCurrentUserId: () => ref.read(sessionControllerProvider).userId,
  );
}

/// Messaging service class
class MessagingService {
  final FirebaseFirestore firestore;
  final String? Function() getCurrentUserId;

  MessagingService({
    required this.firestore,
    required this.getCurrentUserId,
  });

  /// Send a message to a conversation
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    List<Attachment> attachments = const [],
    String? replyToMessageId,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final conversationRef = firestore.collection('conversations').doc(conversationId);
    final messagesRef = conversationRef.collection('messages');

    // Create message
    final messageData = {
      'conversation_id': conversationId,
      'sender_id': userId,
      'sender_type': 'me', // Will be mapped based on user viewing
      'sender_name': 'Me', // Will be replaced with actual name
      'text': text,
      'sent_at': FieldValue.serverTimestamp(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'reply_to_message_id': replyToMessageId,
      'is_read': false,
      'is_sending': false,
    };

    // Add message to subcollection
    await messagesRef.add(messageData);

    // Update conversation's last_message and updated_at
    await conversationRef.update({
      'last_message': {
        'text': text,
        'sender_id': userId,
        'sent_at': FieldValue.serverTimestamp(),
      },
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Create a new conversation
  Future<String> createConversation({
    required String title,
    required List<String> participantIds,
    String subtitle = '',
    bool isSupport = false,
    String? initialMessage,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Ensure current user is in participants
    final participants = {...participantIds, userId}.toList();

    final conversationData = {
      'title': title,
      'subtitle': subtitle,
      'participants': participants,
      'is_pinned': isSupport,
      'is_support': isSupport,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final conversationRef = await firestore
        .collection('conversations')
        .add(conversationData);

    // Send initial message if provided
    if (initialMessage != null) {
      await sendMessage(
        conversationId: conversationRef.id,
        text: initialMessage,
      );
    }

    return conversationRef.id;
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    final messagesRef = firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    // Get all unread messages not sent by current user
    final unreadMessages = await messagesRef
        .where('is_read', isEqualTo: false)
        .where('sender_id', isNotEqualTo: userId)
        .get();

    // Batch update to mark as read
    final batch = firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  /// Toggle conversation pin status
  Future<void> togglePin(String conversationId) async {
    final conversationRef = firestore.collection('conversations').doc(conversationId);
    final doc = await conversationRef.get();
    
    if (doc.exists) {
      final currentPinned = doc.data()?['is_pinned'] as bool? ?? false;
      await conversationRef.update({'is_pinned': !currentPinned});
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final conversationRef = firestore.collection('conversations').doc(conversationId);
    
    // Delete all messages in subcollection
    final messagesSnapshot = await conversationRef.collection('messages').get();
    final batch = firestore.batch();
    
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete conversation
    batch.delete(conversationRef);
    
    await batch.commit();
  }

  /// Get or create conversation between two users
  Future<String> getOrCreateDirectConversation({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Check if conversation already exists
    final existingConversations = await firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .get();

    for (final doc in existingConversations.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.length == 2 && participants.contains(otherUserId)) {
        return doc.id; // Conversation exists
      }
    }

    // Create new conversation
    return await createConversation(
      title: otherUserName,
      participantIds: [otherUserId],
      subtitle: 'Direct message',
    );
  }
}




