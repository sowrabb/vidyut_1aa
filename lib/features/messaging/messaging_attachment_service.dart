import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'attachments.dart';

class MessagingAttachmentService {
  final ImagePicker _imagePicker = ImagePicker();

  // Defaults; can be tuned or injected
  final int maxAttachmentsPerMessage;
  final int maxFileSizeBytes;
  final List<String> allowedImageMimeTypes;

  MessagingAttachmentService({
    this.maxAttachmentsPerMessage = 10,
    this.maxFileSizeBytes = 20 * 1024 * 1024, // 20 MB
    this.allowedImageMimeTypes = const [
      'image/jpeg',
      'image/png',
      'image/webp',
    ],
  });

  Future<List<StagedAttachment>> pickImages({bool allowMultiple = true}) async {
    final List<StagedAttachment> results = [];
    final List<XFile> picked = allowMultiple
        ? (await _imagePicker.pickMultiImage(imageQuality: 90))
        : ([
            if ((await _imagePicker.pickImage(source: ImageSource.gallery)) !=
                null)
              (await _imagePicker.pickImage(source: ImageSource.gallery))!
          ]);

    for (final x in picked) {
      final bytes = await x.readAsBytes();
      if (bytes.length > maxFileSizeBytes) {
        continue; // skip oversize
      }
      final thumb = await _createImageThumbnail(bytes, maxWidth: 320);
      results.add(StagedAttachment(
        localId: UniqueKey().toString(),
        name: x.name,
        type: StagedAttachmentType.image,
        sizeBytes: bytes.length,
        originalBytes: bytes,
        previewThumbnailBytes: thumb.bytes,
        imageWidth: thumb.width,
        imageHeight: thumb.height,
      ));
    }
    return results;
  }

  Future<List<StagedAttachment>> pickPdfs({bool allowMultiple = true}) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: allowMultiple,
      withData: kIsWeb, // get bytes on web
    );
    if (res == null) return [];
    final List<StagedAttachment> out = [];
    for (final f in res.files) {
      final int size = f.size;
      if (size > maxFileSizeBytes) continue;
      final bytes = f.bytes; // may be null on mobile
      Uint8List? thumbBytes;
      if (bytes != null) {
        thumbBytes = await _createPdfFirstPageThumbnail(bytes);
      }
      out.add(StagedAttachment(
        localId: UniqueKey().toString(),
        name: f.name,
        type: StagedAttachmentType.pdf,
        sizeBytes: size,
        originalBytes: bytes,
        previewThumbnailBytes: thumbBytes,
      ));
    }
    return out;
  }

  Future<_Thumbnail> _createImageThumbnail(Uint8List sourceBytes,
      {int maxWidth = 320}) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      sourceBytes,
      targetWidth: maxWidth,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image img = frame.image;
    final ByteData? pngBytes =
        await img.toByteData(format: ui.ImageByteFormat.png);
    return _Thumbnail(
      bytes: pngBytes!.buffer.asUint8List(),
      width: img.width,
      height: img.height,
    );
  }

  Future<Uint8List?> _createPdfFirstPageThumbnail(Uint8List pdfBytes) async {
    try {
      final doc = await PdfDocument.openData(pdfBytes);
      if (doc.pagesCount == 0) return null;
      final page = await doc.getPage(1);
      final pageImage = await page.render(width: 720, height: 720, format: PdfPageImageFormat.png);
      await page.close();
      await doc.close();
      return pageImage?.bytes;
    } catch (_) {
      return null;
    }
  }
}

class _Thumbnail {
  final Uint8List bytes;
  final int width;
  final int height;
  _Thumbnail({required this.bytes, required this.width, required this.height});
}


