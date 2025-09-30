import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/tokens.dart';
import '../data/profile_posts_data.dart';

/// Professional bottom sheet for post details
class ProfessionalBottomSheet extends StatefulWidget {
  final ProfilePost post;

  const ProfessionalBottomSheet({
    super.key,
    required this.post,
  });

  @override
  State<ProfessionalBottomSheet> createState() =>
      _ProfessionalBottomSheetState();
}

class _ProfessionalBottomSheetState extends State<ProfessionalBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                _buildHandleBar(),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        const SizedBox(height: 20),

                        // Media gallery & attachments
                        _buildMediaSection(),
                        const SizedBox(height: 20),

                        // Title
                        _buildTitle(),
                        const SizedBox(height: 12),

                        // Content
                        _buildContent(),
                        const SizedBox(height: 20),

                        // Tags
                        _buildTags(),
                        const SizedBox(height: 20),

                        // Actions
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.outlineSoft,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.author,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatDate(widget.post.publishDate),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.post.category == PostCategory.update
                ? Colors.blue.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.post.category.displayName,
            style: TextStyle(
              color: widget.post.category == PostCategory.update
                  ? Colors.blue
                  : Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    final images = widget.post.imageUrls.isNotEmpty
        ? widget.post.imageUrls
        : [widget.post.imageUrl];
    final pdfs = widget.post.pdfUrls;

    return Column(
      children: [
        // Primary image
        GestureDetector(
          onTap: () => _showImageZoom(url: images.first),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              images.first,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: AppColors.outlineSoft,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported,
                    size: 64, color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Thumbnails and PDF chips
        if (images.length > 1 || pdfs.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...images.skip(1).map((url) => GestureDetector(
                    onTap: () => _showImageZoom(url: url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              width: 64,
                              height: 64,
                              color: AppColors.outlineSoft,
                              child: const Icon(Icons.image_not_supported,
                                  size: 18))),
                    ),
                  )),
              ...pdfs.map((pdf) => ActionChip(
                    avatar: const Icon(Icons.picture_as_pdf,
                        color: Colors.red, size: 16),
                    label: const Text('PDF'),
                    onPressed: () => _openPdf(pdf),
                  )),
            ],
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.post.title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post.content,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTags() {
    if (widget.post.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.post.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '#$tag',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _ActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: 'Like',
          count: widget.post.likes + (_isLiked ? 1 : 0),
          color: _isLiked ? Colors.red : AppColors.textSecondary,
          onPressed: _toggleLike,
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'Comment',
          count: widget.post.comments,
          onPressed: () {
            // Pending: Implement comment functionality
          },
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            // Pending: Implement share functionality
          },
          icon: const Icon(Icons.share),
          iconSize: 20,
        ),
      ],
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _showImageZoom({required String url}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageZoomPage(imageUrl: url),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri,
        mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.count,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _formatCount(count),
              style: TextStyle(
                color: color ?? AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}

/// Professional image zoom page
class _ImageZoomPage extends StatelessWidget {
  final String imageUrl;

  const _ImageZoomPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Pending: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download functionality coming soon'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Removed in-app PDF viewer; links open externally on all platforms.
