import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../app/tokens.dart';
import '../widgets/lightweight_image_widget.dart';
import 'image_gallery_widget.dart';

class ProductImageGallery extends ConsumerStatefulWidget {
  final List<String> imageUrls;
  final bool loop;
  final String? heroPrefix;

  const ProductImageGallery(
      {super.key, required this.imageUrls, this.loop = false, this.heroPrefix});

  @override
  ConsumerState<ProductImageGallery> createState() =>
      _ProductImageGalleryState();
}

class _ProductImageGalleryState extends ConsumerState<ProductImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAround(_currentIndex);
    });
    // Analytics: gallery opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(analyticsServiceProvider)
          .logEvent(type: 'gallery.gallery_opened', entityType: 'product');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _precacheAround(int index) {
    if (!mounted) return;
    if (widget.imageUrls.isEmpty) return;
    final contextRef = context;
    // Preload current, previous, next
    for (final i in {index, index - 1, index + 1}) {
      if (i >= 0 && i < widget.imageUrls.length) {
        final url = widget.imageUrls[i];
        if (url.startsWith('http')) {
          precacheImage(NetworkImage(url), contextRef);
        }
      }
    }
  }

  void _goTo(int index, {String source = 'unknown'}) {
    if (widget.imageUrls.isEmpty) return;
    int next = index;
    if (widget.loop) {
      next = (index % widget.imageUrls.length + widget.imageUrls.length) %
          widget.imageUrls.length;
    } else {
      next = next.clamp(0, widget.imageUrls.length - 1);
    }
    if (next == _currentIndex) return;
    _pageController.animateToPage(next,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    ref
        .read(analyticsServiceProvider)
        .logEvent(type: 'gallery.arrow_nav', entityType: 'product');
  }

  void _openFullScreen() {
    ref
        .read(analyticsServiceProvider)
        .logEvent(type: 'gallery.viewer_opened', entityType: 'product');
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _FullScreenGallery(
          imageUrls: widget.imageUrls,
          initialIndex: _currentIndex,
          heroPrefix: widget.heroPrefix,
          onPageChanged: (i) {
            setState(() => _currentIndex = i);
            _precacheAround(i);
          },
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls.isEmpty
        ? List<String>.generate(
            1, (i) => 'https://picsum.photos/seed/detail_$i/1200/800')
        : widget.imageUrls;

    return FocusableActionDetector(
      autofocus: false,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            DirectionalFocusIntent(TraversalDirection.left),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            DirectionalFocusIntent(TraversalDirection.right),
      },
      actions: <Type, Action<Intent>>{
        DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: (intent) {
            if (intent.direction == TraversalDirection.left) {
              _goTo(_currentIndex - 1, source: 'key');
            } else if (intent.direction == TraversalDirection.right) {
              _goTo(_currentIndex + 1, source: 'key');
            }
            return null;
          },
        ),
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              children: [
                Semantics(
                  label:
                      'Product image ${_currentIndex + 1} of ${images.length}',
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) {
                      setState(() => _currentIndex = i);
                      _precacheAround(i);
                      ref.read(analyticsServiceProvider).logEvent(
                          type: 'gallery.swipe_nav', entityType: 'product');
                    },
                    itemCount: images.length,
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _openFullScreen,
                        child: Hero(
                          tag: '${widget.heroPrefix ?? 'product'}_$i',
                          child: LightweightImageWidget(
                            imagePath: images[i],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                            placeholder: _MainImageSkeleton(),
                            errorWidget: _ErrorPlaceholder(
                              onRetry: () {
                                // No-op: LightweightImageWidget rebuilds on setState
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (images.length > 1)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ArrowButton(
                      tooltip: 'Previous image',
                      onTap: () => _goTo(_currentIndex - 1, source: 'arrow'),
                      enabled: widget.loop || _currentIndex > 0,
                      icon: Icons.chevron_left,
                    ),
                  ),
                if (images.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _ArrowButton(
                      tooltip: 'Next image',
                      onTap: () => _goTo(_currentIndex + 1, source: 'arrow'),
                      enabled: widget.loop || _currentIndex < images.length - 1,
                      icon: Icons.chevron_right,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ThumbnailStrip(
            images: images,
            selectedIndex: _currentIndex,
            onSelect: (i) {
              ref.read(analyticsServiceProvider).logEvent(
                  type: 'gallery.thumbnail_clicked', entityType: 'product');
              _goTo(i, source: 'thumb');
            },
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  final IconData icon;
  final String tooltip;

  const _ArrowButton(
      {required this.onTap,
      required this.enabled,
      required this.icon,
      required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineSoft),
                ),
                child: Icon(icon,
                    size: 28,
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ThumbnailStrip(
      {required this.images,
      required this.selectedIndex,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return Semantics(
            selected: selected,
            label: 'Thumbnail ${i + 1} of ${images.length}',
            child: FocusableActionDetector(
              onShowHoverHighlight: (_) {},
              onShowFocusHighlight: (_) {},
              child: InkWell(
                onTap: () => onSelect(i),
                onLongPress: () => onSelect(i),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.outlineSoft,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: LightweightImageWidget(
                      imagePath: images[i],
                      width: 96,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: _ThumbSkeleton(),
                      errorWidget: _ThumbError(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroPrefix;
  final ValueChanged<int>? onPageChanged;

  const _FullScreenGallery(
      {required this.imageUrls,
      required this.initialIndex,
      this.heroPrefix,
      this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ImageGalleryWidget(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        heroTag: heroPrefix,
        showPageIndicator: true,
        backgroundColor: Colors.black,
        onPageChanged: onPageChanged,
      ),
    );
  }
}

class _MainImageSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.thumbBg,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ThumbSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.thumbBg);
  }
}

class _ThumbError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.thumbBg,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image));
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorPlaceholder({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRetry,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.thumbBg,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
