// PDF preview widget for first-page thumbnails and full viewer
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../../app/tokens.dart';
import '../models/media_models.dart';

/// PDF preview widget with thumbnail and full viewer
class PdfPreviewWidget extends StatelessWidget {
  final MediaItem pdfItem;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showFileName;
  final bool showFileSize;

  const PdfPreviewWidget({
    super.key,
    required this.pdfItem,
    this.onTap,
    this.width,
    this.height,
    this.showFileName = true,
    this.showFileSize = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _openPdf(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PDF icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 28,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // File name
            if (showFileName) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  pdfItem.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
            ],
            
            // File size
            if (showFileSize) ...[
              Text(
                _formatFileSize(pdfItem.sizeBytes),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openPdf(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PdfViewerModal(pdfItem: pdfItem),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = (bytes / 1024).floor();
    int suffixIndex = 0;
    
    while (i > 1024 && suffixIndex < suffixes.length - 1) {
      i = (i / 1024).floor();
      suffixIndex++;
    }
    
    return '$i ${suffixes[suffixIndex]}';
  }
}

/// PDF viewer modal for full-screen PDF viewing
class _PdfViewerModal extends StatefulWidget {
  final MediaItem pdfItem;

  const _PdfViewerModal({required this.pdfItem});

  @override
  State<_PdfViewerModal> createState() => _PdfViewerModalState();
}

class _PdfViewerModalState extends State<_PdfViewerModal> {
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.outlineSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pdfItem.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(widget.pdfItem.sizeBytes),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openInExternalApp(),
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Open in external app',
                ),
                IconButton(
                  onPressed: () => _sharePdf(),
                  icon: const Icon(Icons.share),
                  tooltip: 'Share PDF',
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // Content
          Expanded(
            child: _buildPdfContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInExternalApp,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in External App'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    // For now, show a placeholder with options to open in external app
    // In production, you might want to integrate a PDF viewer library
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'PDF Preview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'PDF preview is not available in-app.\nTap the button below to open in your default PDF viewer.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openInExternalApp,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _sharePdf,
            icon: const Icon(Icons.share),
            label: const Text('Share PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInExternalApp() async {
    try {
      final uri = Uri.parse(widget.pdfItem.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open PDF in external app');
      }
    } catch (e) {
      _showError('Failed to open PDF: $e');
    }
  }

  Future<void> _sharePdf() async {
    try {
      // In a real implementation, you might want to download the PDF first
      // and then share it using the share_plus package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF sharing will be implemented'),
        ),
      );
    } catch (e) {
      _showError('Failed to share PDF: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = (bytes / 1024).floor();
    int suffixIndex = 0;
    
    while (i > 1024 && suffixIndex < suffixes.length - 1) {
      i = (i / 1024).floor();
      suffixIndex++;
    }
    
    return '$i ${suffixes[suffixIndex]}';
  }
}

/// PDF thumbnail generator (placeholder implementation)
class PdfThumbnailGenerator {
  /// Generate thumbnail for PDF first page
  /// In production, you might want to use libraries like pdfx or pdf_render
  static Future<String?> generateThumbnail({
    required String pdfUrl,
    required String postId,
    required String fileId,
    int width = 300,
    int height = 300,
  }) async {
    try {
      // Placeholder implementation
      // In production, implement actual PDF thumbnail generation
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract first page as image
  static Future<Uint8List?> extractFirstPage({
    required String pdfUrl,
    int width = 300,
    int height = 300,
  }) async {
    try {
      // Placeholder implementation
      // In production, use pdf_render or similar library
      return null;
    } catch (e) {
      return null;
    }
  }
}

