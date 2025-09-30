import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/provider_registry.dart';
import '../../../app/breakpoints.dart';
import '../../../app/tokens.dart';
import '../../../widgets/lightweight_image_widget.dart';
import '../../admin/models/hero_section.dart';

class HeroSlideshow extends ConsumerStatefulWidget {
  const HeroSlideshow({super.key});

  @override
  ConsumerState<HeroSlideshow> createState() => _HeroSlideshowState();
}

class _HeroSlideshowState extends ConsumerState<HeroSlideshow>
    with WidgetsBindingObserver {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  // Default slides as fallback
  static const _defaultSlides = [
    _DefaultSlideData(
      'First time in India, largest Electricity platform',
      '',
      imageAssetPath: 'assets/banner/1.JPG',
    ),
    _DefaultSlideData(
      'Find the right components fast',
      'Search by brand, spec, materials',
      imageAssetPath: 'assets/banner/2.webp',
    ),
    _DefaultSlideData(
      'Post RFQs & get quotes',
      'Verified sellers, transparent pricing',
      imageAssetPath: 'assets/banner/3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_getSlideDuration(), (_) {
      if (mounted) {
        final adminStore = ref.read(adminStoreProvider);
        final slides = adminStore.activeHeroSections;
        final totalSlides =
            slides.isNotEmpty ? slides.length : _defaultSlides.length;
        if (totalSlides > 0) {
          _index = (_index + 1) % totalSlides;
          _controller.animateToPage(
            _index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Duration _getSlideDuration() {
    final adminStore = ref.read(adminStoreProvider);
    final slides = adminStore.activeHeroSections;
    final currentSlides = slides.isNotEmpty ? slides : _defaultSlides;

    if (_index < currentSlides.length) {
      final currentSlide = currentSlides[_index];
      // Use admin store settings for slide durations
      if (currentSlide is HeroSection) {
        return currentSlide.title.contains('First time in India')
            ? Duration(seconds: adminStore.firstSlideDurationSeconds)
            : Duration(seconds: adminStore.otherSlidesDurationSeconds);
      } else if (currentSlide is _DefaultSlideData) {
        return currentSlide.title.contains('First time in India')
            ? Duration(seconds: adminStore.firstSlideDurationSeconds)
            : Duration(seconds: adminStore.otherSlidesDurationSeconds);
      }
    }
    return Duration(seconds: adminStore.otherSlidesDurationSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    // Pause when not visible to save resources
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final adminStore = ref.watch(adminStoreProvider);
        if (!adminStore.isInitialized) {
          // Show default slides while loading
          return _buildDefaultSlideshow(context);
        }

        final slides = adminStore.activeHeroSections;

        if (slides.isEmpty) {
          // Fallback to default slides if no admin sections are available
          return _buildDefaultSlideshow(context);
        }

        final w = MediaQuery.sizeOf(context).width;
        final isDesktop = w >= AppBreakpoints.desktop;
        final double height = isDesktop ? 420 : 320;

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // No background painter - clean white only
              PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                  });
                  // Restart timer with new duration
                  _startTimer();
                },
                itemBuilder: (_, i) {
                  final hero = slides[i];
                  final String? effectiveImagePath =
                      (hero.imagePath != null && hero.imagePath!.isNotEmpty)
                          ? hero.imagePath
                          : _defaultAssetForIndex(i);
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: isDesktop
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _SlideContent(
                                      hero: hero,
                                      isDesktop: true,
                                      showPoweredBy: i == 0,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: _HeroImage(
                                        imagePath: effectiveImagePath,
                                        isDesktop: true,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: _SlideContent(
                                      hero: hero,
                                      isDesktop: false,
                                      showPoweredBy: i == 0,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Flexible(
                                    child: AspectRatio(
                                      aspectRatio: 2 / 1,
                                      child: _HeroImage(
                                        imagePath: effectiveImagePath,
                                        isDesktop: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
              // Scroll indicators
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(slides.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _index == index
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Navigation arrows (desktop only)
              if (isDesktop && slides.length > 1) ...[
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          final newIndex =
                              _index > 0 ? _index - 1 : slides.length - 1;
                          _controller.animateToPage(
                            newIndex,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        icon: const Icon(Icons.chevron_left,
                            color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          final newIndex =
                              _index < slides.length - 1 ? _index + 1 : 0;
                          _controller.animateToPage(
                            newIndex,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultSlideshow(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= AppBreakpoints.desktop;
    final double height = isDesktop ? 420 : 400; // Increased mobile height

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Completely clean white background - no painters or decorations
          const Positioned.fill(child: ColoredBox(color: Colors.white)),
          // Completely clean white background - no painters or decorations
          const Positioned.fill(child: ColoredBox(color: Colors.white)),
          PageView.builder(
            controller: _controller,
            itemCount: _defaultSlides.length,
            onPageChanged: (index) {
              setState(() {
                _index = index;
              });
              // Restart timer with new duration
              _startTimer();
            },
            itemBuilder: (_, i) {
              final slide = _defaultSlides[i];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                child: _DefaultSlideContent(
                                  title: slide.title,
                                  subtitle: slide.subtitle,
                                  isDesktop: true,
                                  showPoweredBy: i == 0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: _buildDefaultImage(
                                      slide.imageAssetPath, true),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Give more space to text content
                              Expanded(
                                flex: 7, // 70% of height for text
                                child: _DefaultSlideContent(
                                  title: slide.title,
                                  subtitle: slide.subtitle,
                                  isDesktop: false,
                                  showPoweredBy: i == 0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Less space for image
                              Expanded(
                                flex: 3, // 30% of height for image
                                child: _buildDefaultImage(
                                    slide.imageAssetPath, false),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
          // Scroll indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_defaultSlides.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _index == index
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Navigation arrows (desktop only)
          if (isDesktop && _defaultSlides.length > 1) ...[
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      final newIndex =
                          _index > 0 ? _index - 1 : _defaultSlides.length - 1;
                      _controller.animateToPage(
                        newIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    icon: const Icon(Icons.chevron_left, color: Colors.black87),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      final newIndex =
                          _index < _defaultSlides.length - 1 ? _index + 1 : 0;
                      _controller.animateToPage(
                        newIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    icon:
                        const Icon(Icons.chevron_right, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.thumbBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineSoft,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: isDesktop ? 48 : 32,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDefaultImage(String? assetPath, bool isDesktop) {
    if (assetPath == null || assetPath.isEmpty) {
      return _buildPlaceholderImage(isDesktop);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        assetPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: isDesktop ? 800 : 400,
        cacheHeight: isDesktop ? 600 : 300,
        errorBuilder: (context, error, stack) =>
            _buildPlaceholderImage(isDesktop),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final HeroSection hero;
  final bool isDesktop;
  final bool showPoweredBy;

  const _SlideContent({
    required this.hero,
    required this.isDesktop,
    this.showPoweredBy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: hero.title.contains('First time in India')
              ? _AnimatedGradientText(
                  hero.title,
                  isDesktop: isDesktop,
                  maxLines: isDesktop ? 2 : 3,
                )
              : Text(
                  hero.title,
                  textAlign: TextAlign.center,
                  maxLines: isDesktop ? 2 : 3, // Reduced for better mobile fit
                  overflow: TextOverflow.ellipsis,
                  style: _heroTitleStyle(context, isDesktop, false).copyWith(
                    fontSize: isDesktop
                        ? null
                        : Theme.of(context).textTheme.headlineLarge!.fontSize! *
                            0.75, // Reduced mobile font size for better fit
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            hero.subtitle,
            textAlign: TextAlign.center,
            maxLines: isDesktop ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: isDesktop
                      ? null
                      : Theme.of(context).textTheme.titleMedium!.fontSize! *
                          0.9,
                ),
          ),
        ),
        if (showPoweredBy) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Powered by Madhu Powertech PVT LTD',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop
                            ? null
                            : (Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.fontSize ??
                                    14) *
                                0.95,
                      ) ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
        // No segmented bar or category chips per the new clean design
        // Show CTA button only if it's not the first slide
        if (hero.ctaText != null &&
            hero.ctaText!.isNotEmpty &&
            !hero.title.contains('First time in India')) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              // Handle CTA click - you can add navigation logic here
              if (hero.ctaUrl != null && hero.ctaUrl!.isNotEmpty) {
                // Navigate to the URL or handle the action
                debugPrint('CTA clicked: ${hero.ctaText} -> ${hero.ctaUrl}');
              }
            },
            child: Text(hero.ctaText!),
          ),
        ],
        // Company highlight removed for a clean, minimal hero
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imagePath;
  final bool isDesktop;

  const _HeroImage({
    this.imagePath,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.thumbBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineSoft,
        ),
      ),
      child: imagePath != null ? _buildImage() : _buildPlaceholder(),
    );
  }

  Widget _buildImage() {
    if (imagePath != null && imagePath!.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return HeroImageWidget(
      imagePath: imagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image,
        size: isDesktop ? 48 : 32,
        color: Colors.black54,
      ),
    );
  }
}

class _DefaultSlideData {
  final String title;
  final String subtitle;
  final String? imageAssetPath;
  const _DefaultSlideData(this.title, this.subtitle, {this.imageAssetPath});
}

String? _defaultAssetForIndex(int index) {
  switch (index % 3) {
    case 0:
      return 'assets/banner/1.JPG';
    case 1:
      return 'assets/banner/2.webp';
    case 2:
    default:
      return 'assets/banner/3.jpg';
  }
}

class _DefaultSlideContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDesktop;
  final bool showPoweredBy;

  const _DefaultSlideContent({
    required this.title,
    required this.subtitle,
    required this.isDesktop,
    this.showPoweredBy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title.contains('First time in India')
            ? _AnimatedGradientText(
                title,
                isDesktop: isDesktop,
                maxLines: isDesktop ? 2 : 6,
              )
            : Text(
                title,
                textAlign: TextAlign.center,
                maxLines: isDesktop ? 2 : 6, // Increased mobile lines even more
                overflow: TextOverflow
                    .visible, // Changed to visible to prevent chopping
                style: _heroTitleStyle(context, isDesktop, false).copyWith(
                  fontSize: isDesktop
                      ? null
                      : Theme.of(context).textTheme.headlineLarge!.fontSize! *
                          0.5, // Much smaller mobile font size
                  height: 0.9, // Even tighter line height
                  fontWeight:
                      FontWeight.w600, // Slightly bolder for readability
                ),
              ),
        SizedBox(height: isDesktop ? 8 : 4), // Smaller spacing for mobile
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: isDesktop ? 2 : 4, // Increased mobile lines
          overflow: TextOverflow.visible, // Changed to visible
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: isDesktop
                    ? null
                    : Theme.of(context).textTheme.titleMedium!.fontSize! *
                        0.7, // Much smaller mobile font size
                height: 1.0, // Tighter line height
                fontWeight: FontWeight.w500, // Slightly bolder
              ),
        ),
        if (showPoweredBy) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Powered by Madhu Powertech PVT LTD',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop
                            ? null
                            : (Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.fontSize ??
                                    14) *
                                0.9,
                      ) ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
        // No segmented bar or category chips per the new clean design
        // Company highlight removed for a clean, minimal hero
      ],
    );
  }
}

// Prism City background
// Removed _LightPrismBackground and _LightPrismPainter classes - no more grid or lines

TextStyle _heroTitleStyle(
    BuildContext context, bool isDesktop, bool useGradient) {
  final base = Theme.of(context).textTheme.headlineLarge ??
      const TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  // Always return base; gradient is applied by _AnimatedGradientText when needed
  return base;
}

class _AnimatedGradientText extends StatefulWidget {
  final String text;
  final bool isDesktop;
  final int maxLines;
  const _AnimatedGradientText(this.text,
      {required this.isDesktop, this.maxLines = 2});

  @override
  State<_AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<_AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<Color> _colors = [
    Color(0xFFD32F2F), // dark red
    Color(0xFFF57C00), // dark orange
    Color(0xFFF9A825), // golden yellow (darker)
    Color(0xFF388E3C), // dark green
    Color(0xFF1976D2), // dark blue
    Color(0xFF7B1FA2), // dark violet
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: widget.isDesktop
                  ? null
                  : Theme.of(context).textTheme.headlineLarge!.fontSize! * 0.75,
              height: 0.95,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ) ??
        const TextStyle(
            fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Slide gradient horizontally over time
        final t = _controller.value; // 0..1
        final beginX = -1.0 + 2.0 * t; // moves from -1 to 1
        final endX = beginX + 1.5; // wider sweep
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: _colors,
              begin: Alignment(beginX, 0),
              end: Alignment(endX, 0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: baseStyle,
          ),
        );
      },
    );
  }
}

// Removed segmented bar and category tiles per clean design
