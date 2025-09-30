import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class NextImageIntent extends Intent {
  const NextImageIntent();
}

class PrevImageIntent extends Intent {
  const PrevImageIntent();
}

/// Image gallery widget with zoom functionality
class ImageGalleryWidget extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;
  final bool showPageIndicator;
  final Color? backgroundColor;
  final BoxFit fit;
  final ValueChanged<int>? onPageChanged;

  const ImageGalleryWidget({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
    this.showPageIndicator = true,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.onPageChanged,
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  late PageController _pageController;
  late int _currentIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadImage(),
          ),
        ],
      ),
      body: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): PrevImageIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): NextImageIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(onInvoke: (intent) {
              Navigator.of(context).maybePop();
              return null;
            }),
            PrevImageIntent:
                CallbackAction<PrevImageIntent>(onInvoke: (intent) {
              if (_currentIndex > 0) {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut);
              }
              return null;
            }),
            NextImageIntent:
                CallbackAction<NextImageIntent>(onInvoke: (intent) {
              if (_currentIndex < widget.imageUrls.length - 1) {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut);
              }
              return null;
            }),
          },
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: true,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    widget.onPageChanged?.call(index);
                  },
                  builder: (context, index) {
                    final String imageUrl = widget.imageUrls[index];
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(imageUrl),
                      heroAttributes: widget.heroTag != null
                          ? PhotoViewHeroAttributes(
                              tag: '${widget.heroTag}_$index')
                          : null,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.contained * 3.5,
                      initialScale: PhotoViewComputedScale.contained,
                      basePosition: Alignment.center,
                      filterQuality: FilterQuality.high,
                    );
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.black,
                  ),
                  allowImplicitScrolling: true,
                ),
                if (widget.imageUrls.length > 1)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _FSArrowButton(
                      tooltip: 'Previous image',
                      onTap: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut);
                        }
                      },
                      enabled: _currentIndex > 0,
                      icon: Icons.chevron_left,
                    ),
                  ),
                if (widget.imageUrls.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _FSArrowButton(
                      tooltip: 'Next image',
                      onTap: () {
                        if (_currentIndex < widget.imageUrls.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut);
                        }
                      },
                      enabled: _currentIndex < widget.imageUrls.length - 1,
                      icon: Icons.chevron_right,
                    ),
                  ),
                if (widget.showPageIndicator && widget.imageUrls.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: _buildPageIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imageUrls.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  void _shareImage() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _downloadImage() {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
  }
}

class _FSArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  final IconData icon;
  final String tooltip;

  const _FSArrowButton(
      {required this.onTap,
      required this.enabled,
      required this.icon,
      required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(icon,
                    size: 32, color: enabled ? Colors.white : Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail gallery widget
class ThumbnailGalleryWidget extends StatelessWidget {
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int>? onImageSelected;
  final double thumbnailSize;
  final double spacing;

  const ThumbnailGalleryWidget({
    super.key,
    required this.imageUrls,
    this.selectedIndex = 0,
    this.onImageSelected,
    this.thumbnailSize = 60,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: thumbnailSize + 8,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onImageSelected?.call(index),
            child: Container(
              margin: EdgeInsets.only(right: spacing),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  imageUrls[index],
                  width: thumbnailSize,
                  height: thumbnailSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: thumbnailSize,
                      height: thumbnailSize,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Image preview widget with zoom
class ImagePreviewWidget extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final BoxFit fit;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const ImagePreviewWidget({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showFullScreen(context),
      child: Hero(
        tag: heroTag ?? imageUrl,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageGalleryWidget(
          imageUrls: [imageUrl],
          heroTag: heroTag,
        ),
      ),
    );
  }
}
