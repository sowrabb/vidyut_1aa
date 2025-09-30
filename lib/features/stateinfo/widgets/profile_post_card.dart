import 'package:flutter/material.dart';
import '../../../app/tokens.dart';
import '../../../widgets/lightweight_image_widget.dart';
import '../data/profile_posts_data.dart';

/// Professional, Instagram-style post card.
class ProfilePostCard extends StatelessWidget {
  final ProfilePost post;
  final VoidCallback? onTap;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onEdit;
  final bool showEditButton;

  const ProfilePostCard({
    super.key,
    required this.post,
    this.onTap,
    this.isLiked = false,
    this.onLike,
    this.onEdit,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive values based on card width
    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 400;
      final bool isTablet = constraints.maxWidth > 350;

      final EdgeInsets cardPadding =
          EdgeInsets.all(isDesktop ? 14 : (isTablet ? 12 : 10));
      final double avatarRadius = isDesktop ? 20 : 18;
      final double titleFont = isDesktop ? 15 : 14;
      final double contentFont = isDesktop ? 14 : 13;
      final int titleChars = isDesktop ? 45 : 35;
      final int contentChars = isDesktop ? 90 : 70;
      final int maxTags = isDesktop ? 3 : 2;

      return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PostHeader(
                  post: post, padding: cardPadding, avatarRadius: avatarRadius),
              // 16:9 image to match reference; allow variable content height for masonry
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _PostMediaPreview(post: post, onTap: onTap),
              ),
              Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PostContent(
                      post: post,
                      titleFontSize: titleFont,
                      contentFontSize: contentFont,
                      titleCharLimit: titleChars,
                      contentCharLimit: contentChars,
                    ),
                    const SizedBox(height: 8),
                    _PostTags(tags: post.tags, maxTags: maxTags),
                    const SizedBox(height: 8),
                    _PostActions(
                      post: post,
                      isLiked: isLiked,
                      onLike: onLike,
                      onEdit: showEditButton ? onEdit : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// --- Sub-widgets for the Post Card ---

class _PostHeader extends StatelessWidget {
  final ProfilePost post;
  final EdgeInsets padding;
  final double avatarRadius;

  const _PostHeader(
      {required this.post, required this.padding, required this.avatarRadius});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person,
                color: AppColors.primary, size: avatarRadius),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.author,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(_formatDate(post.publishDate),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: post.category == PostCategory.update
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              post.category.displayName,
              style: TextStyle(
                color: post.category == PostCategory.update
                    ? Colors.blue
                    : Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d ago';
  }
}

class _PostMediaPreview extends StatelessWidget {
  final ProfilePost post;
  final VoidCallback? onTap;

  const _PostMediaPreview({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasGallery = post.imageUrls.isNotEmpty;
    final hasPdf = post.pdfUrls.isNotEmpty;
    final baseImage = post.imageUrl;

    Widget imageWidget = GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LightweightImageWidget(
            imagePath: baseImage,
            fit: BoxFit.cover,
            cacheWidth: 400,
            cacheHeight: 300,
            placeholder:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: const Center(
                child: Icon(Icons.image_not_supported,
                    size: 48, color: AppColors.outlineSoft)),
          ),
          if (hasGallery || hasPdf)
            Positioned(
              top: 8,
              right: 8,
              child: _BadgeOverlay(
                galleryCount: hasGallery ? post.imageUrls.length : 0,
                pdfCount: hasPdf ? post.pdfUrls.length : 0,
              ),
            ),
        ],
      ),
    );

    return imageWidget;
  }
}

class _BadgeOverlay extends StatelessWidget {
  final int galleryCount;
  final int pdfCount;

  const _BadgeOverlay({required this.galleryCount, required this.pdfCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (galleryCount > 0) ...[
            const Icon(Icons.photo_library_outlined,
                color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text('$galleryCount',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
          if (galleryCount > 0 && pdfCount > 0) const SizedBox(width: 8),
          if (pdfCount > 0) ...[
            const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text('$pdfCount',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final ProfilePost post;
  final double titleFontSize;
  final double contentFontSize;
  final int titleCharLimit;
  final int contentCharLimit;

  const _PostContent({
    required this.post,
    required this.titleFontSize,
    required this.contentFontSize,
    required this.titleCharLimit,
    required this.contentCharLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _truncate(post.title, titleCharLimit),
          style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              height: 1.3),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _truncate(post.content, contentCharLimit),
          style: TextStyle(
              fontSize: contentFontSize,
              height: 1.4,
              color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _truncate(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars).trimRight()}...';
  }
}

class _PostTags extends StatelessWidget {
  final List<String> tags;
  final int maxTags;

  const _PostTags({required this.tags, required this.maxTags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .take(maxTags)
          .map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('#$tag',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ))
          .toList(),
    );
  }
}

class _PostActions extends StatelessWidget {
  final ProfilePost post;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onEdit;

  const _PostActions({
    required this.post,
    this.isLiked = false,
    this.onLike,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 18;
    return Row(
      children: [
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          count: post.likes + (isLiked ? 1 : 0),
          color: isLiked ? Colors.red : AppColors.textSecondary,
          onTap: onLike,
          iconSize: iconSize,
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          count: post.comments,
          onTap: () {},
          iconSize: iconSize,
        ),
        const Spacer(),
        if (onEdit != null) ...[
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
            tooltip: 'Edit Post',
          ),
          const SizedBox(width: 8),
        ],
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share),
          iconSize: iconSize,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;
  final Color? color;
  final double iconSize;

  const _ActionButton({
    required this.icon,
    required this.count,
    this.onTap,
    this.color,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(
                  color: color ?? AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
}
