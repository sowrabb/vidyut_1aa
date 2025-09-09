import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/breakpoints.dart';
import '../../../app/tokens.dart';
import '../../admin/store/admin_store.dart';
import '../../admin/models/hero_section.dart';

class HeroSlideshow extends StatefulWidget {
  const HeroSlideshow({super.key});

  @override
  State<HeroSlideshow> createState() => _HeroSlideshowState();
}

class _HeroSlideshowState extends State<HeroSlideshow> {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  // Default slides as fallback
  static const _defaultSlides = [
    _DefaultSlideData(
      'First time in India, largest Electricity platform',
      'B2B • D2C • C2C',
    ),
    _DefaultSlideData(
      'Find the right components fast',
      'Search by brand, spec, materials',
    ),
    _DefaultSlideData(
      'Post RFQs & get quotes',
      'Verified sellers, transparent pricing',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_getSlideDuration(), (_) {
      if (mounted) {
        final adminStore = context.read<AdminStore>();
        final slides = adminStore.activeHeroSections;
        final totalSlides = slides.isNotEmpty ? slides.length : _defaultSlides.length;
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
    final adminStore = context.read<AdminStore>();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStore>(
      builder: (context, adminStore, child) {
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

        return Container(
          height: height,
          child: Stack(
            children: [
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
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: _HeroImage(
                                        imagePath: hero.imagePath,
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
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Flexible(
                                    child: AspectRatio(
                                      aspectRatio: 2 / 1,
                                      child: _HeroImage(
                                        imagePath: hero.imagePath,
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
                              : AppColors.primary.withOpacity(0.3),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          final newIndex = _index > 0 ? _index - 1 : slides.length - 1;
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          final newIndex = _index < slides.length - 1 ? _index + 1 : 0;
                          _controller.animateToPage(
                            newIndex,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        icon: const Icon(Icons.chevron_right, color: Colors.black87),
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

    return Container(
      height: height,
      child: Stack(
        children: [
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
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: _buildPlaceholderImage(true),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Give more space to text content
                              SizedBox(
                                height: height * 0.7, // 70% of height for text
                                child: _DefaultSlideContent(
                                  title: slide.title,
                                  subtitle: slide.subtitle,
                                  isDesktop: false,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Less space for image
                              SizedBox(
                                height: height * 0.3, // 30% of height for image
                                child: _buildPlaceholderImage(false),
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
                          : AppColors.primary.withOpacity(0.3),
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      final newIndex = _index > 0 ? _index - 1 : _defaultSlides.length - 1;
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      final newIndex = _index < _defaultSlides.length - 1 ? _index + 1 : 0;
                      _controller.animateToPage(
                        newIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    icon: const Icon(Icons.chevron_right, color: Colors.black87),
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
}

class _SlideContent extends StatelessWidget {
  final HeroSection hero;
  final bool isDesktop;

  const _SlideContent({
    required this.hero,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            hero.title,
            textAlign: TextAlign.center,
            maxLines: isDesktop ? 2 : 3, // Reduced for better mobile fit
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
        // Show CTA button only if it's not the first slide
        if (hero.ctaText != null && hero.ctaText!.isNotEmpty && !hero.title.contains('First time in India')) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              // Handle CTA click - you can add navigation logic here
              if (hero.ctaUrl != null && hero.ctaUrl!.isNotEmpty) {
                // Navigate to the URL or handle the action
                print('CTA clicked: ${hero.ctaText} -> ${hero.ctaUrl}');
              }
            },
            child: Text(hero.ctaText!),
          ),
        ],
        // Show company highlight only for the first slide (First time in India)
        if (hero.title.contains('First time in India')) ...[
          SizedBox(height: isDesktop ? 20 : 6), // Much smaller spacing for mobile
          // Eye-catching company highlight with enhanced UI
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 8, // Much smaller padding for mobile
              vertical: isDesktop ? 12 : 6, // Much smaller padding for mobile
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 25 : 20), // Smaller radius for mobile
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: isDesktop ? 12 : 8, // Reduced shadow for mobile
                  offset: const Offset(0, 6),
                  spreadRadius: isDesktop ? 2 : 1, // Reduced spread for mobile
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: isDesktop ? 8 : 4, // Reduced shadow for mobile
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Produced by Madhu Powertech Pvt. Ltd.',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isDesktop ? 16 : 9, // Even smaller mobile font size
                letterSpacing: 0.2, // Reduced letter spacing for mobile
                height: 1.0, // Tighter line height
              ),
            ),
          ),
        ],
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
      child: imagePath != null
          ? _buildImage()
          : _buildPlaceholder(),
    );
  }

  Widget _buildImage() {
    if (imagePath!.startsWith('web_storage://')) {
      // For web storage, load from SharedPreferences
      return FutureBuilder<String?>(
        future: _loadWebImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(snapshot.data!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
            );
          } else {
            return _buildPlaceholder();
          }
        },
      );
    } else {
      // For file system
      if (File(imagePath!).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(imagePath!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        );
      } else {
        return _buildPlaceholder();
      }
    }
  }

  Future<String?> _loadWebImage() async {
    try {
      final fileName = imagePath!.replaceFirst('web_storage://', '');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('hero_image_$fileName');
    } catch (e) {
      return null;
    }
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
  const _DefaultSlideData(this.title, this.subtitle);
}

class _DefaultSlideContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDesktop;

  const _DefaultSlideContent({
    required this.title,
    required this.subtitle,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: isDesktop ? 2 : 6, // Increased mobile lines even more
          overflow: TextOverflow.visible, // Changed to visible to prevent chopping
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: isDesktop
                    ? null
                    : Theme.of(context).textTheme.headlineLarge!.fontSize! *
                        0.5, // Much smaller mobile font size
                height: 0.9, // Even tighter line height
                fontWeight: FontWeight.w600, // Slightly bolder for readability
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
        // Show company highlight only for the first slide (First time in India)
        if (title.contains('First time in India')) ...[
          SizedBox(height: isDesktop ? 20 : 6), // Much smaller spacing for mobile
          // Eye-catching company highlight with enhanced UI
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 8, // Much smaller padding for mobile
              vertical: isDesktop ? 12 : 6, // Much smaller padding for mobile
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 25 : 20), // Smaller radius for mobile
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: isDesktop ? 12 : 8, // Reduced shadow for mobile
                  offset: const Offset(0, 6),
                  spreadRadius: isDesktop ? 2 : 1, // Reduced spread for mobile
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: isDesktop ? 8 : 4, // Reduced shadow for mobile
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Produced by Madhu Powertech Pvt. Ltd.',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isDesktop ? 16 : 9, // Even smaller mobile font size
                letterSpacing: 0.2, // Reduced letter spacing for mobile
                height: 1.0, // Tighter line height
              ),
            ),
          ),
        ],
      ],
    );
  }
}