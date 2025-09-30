import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'attachments.dart';
import 'models.dart';

class MessagingBackendService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MessagingBackendService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<String> allocateMessageId(String conversationId) async {
    final ref = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();
    return ref.id;
  }

  Reference _pathForAttachment(
      String conversationId, String messageId, StagedAttachment a) {
    final folder = a.isImage ? 'images' : 'pdfs';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${a.name}';
    return _storage
        .ref()
        .child('chats/$conversationId/messages/$messageId/$folder/$fileName');
  }

  Future<Attachment> _uploadOne(
    String conversationId,
    String messageId,
    StagedAttachment a,
    void Function(double p)? onProgress,
    void Function(String e)? onError,
  ) async {
    try {
      final ref = _pathForAttachment(conversationId, messageId, a);
      SettableMetadata meta;
      if (a.isImage) {
        meta = SettableMetadata(contentType: 'image/jpeg');
      } else {
        meta = SettableMetadata(contentType: 'application/pdf');
      }

      // We expect file bytes available for web PDFs and image thumbnails; for real files in mobile, pickers provide path
      UploadTask? task;
      if (a.isPdf && kIsWeb && a.previewThumbnailBytes == null) {
        // PDF on web: we don't have original bytes here; FilePicker provided bytes in service when staging PDF
        // But we didn't keep them to avoid memory; so we cannot upload here without bytes.
        // For this iteration, skip thumbnail and only upload if bytes were set on previewThumbnailBytes (not ideal for pdf).
      }

      if (a.originalBytes != null) {
        task = ref.putData(a.originalBytes!, meta);
      } else if (a.isImage && a.previewThumbnailBytes != null) {
        // Fallback to thumbnail bytes if original not present (web-only fallback)
        task = ref.putData(a.previewThumbnailBytes!, meta);
      } else if (a.isPdf && a.previewThumbnailBytes != null) {
        // Not ideal: pdf thumbnail is not the document; skip
      }

      if (task == null) {
        throw Exception('Attachment data unavailable for upload');
      }

      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0) onProgress?.call(s.bytesTransferred / s.totalBytes);
      });

      final snap = await task;
      final url = await snap.ref.getDownloadURL();

      return Attachment(
        id: a.localId,
        name: a.name,
        type: a.isImage ? 'image' : 'pdf',
        sizeBytes: snap.totalBytes.toInt(),
        storagePath: snap.ref.fullPath,
        downloadUrl: url,
        thumbnailUrl: a.isImage ? url : null,
        width: a.imageWidth,
        height: a.imageHeight,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      onError?.call(e.toString());
      rethrow;
    }
  }

  Future<List<Attachment>> uploadAll(
    String conversationId,
    String messageId,
    List<StagedAttachment> items, {
    void Function(int index, double p)? onProgress,
    void Function(int index, String e)? onError,
  }) async {
    final List<Attachment> out = [];
    for (int i = 0; i < items.length; i++) {
      final a = items[i];
      final uploaded = await _uploadOne(
        conversationId,
        messageId,
        a,
        (p) => onProgress?.call(i, p),
        (e) => onError?.call(i, e),
      );
      out.add(uploaded);
    }
    return out;
  }

  Future<void> writeMessage(
    String conversationId,
    String messageId,
    String text,
    List<Attachment> attachments, {
    String? replyTo,
  }) async {
    final docRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    await docRef.set({
      'sender_id': 'me', // replace with auth uid
      'text': text,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'reply_to': replyTo,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}


