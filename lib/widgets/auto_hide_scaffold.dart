import 'package:flutter/material.dart';
import '../app/breakpoints.dart';

class AutoHideScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool enableAutoHide;
  final Color? backgroundColor;

  const AutoHideScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.enableAutoHide = true,
    this.backgroundColor,
  });

  @override
  State<AutoHideScaffold> createState() => _AutoHideScaffoldState();
}

class _AutoHideScaffoldState extends State<AutoHideScaffold>
    with TickerProviderStateMixin {
  late AnimationController _appBarController;
  late AnimationController _bottomNavController;
  late Animation<double> _appBarAnimation;
  late Animation<double> _bottomNavAnimation;

  bool _isAppBarVisible = true;
  bool _isBottomNavVisible = true;
  double _lastScrollOffset = 0;
  final double _scrollThreshold =
      60.0; // Minimum scroll distance to trigger hide/show (standard ~50–60px)

  @override
  void initState() {
    super.initState();

    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bottomNavController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appBarAnimation = Tween<double>(
      begin: 0.0,
      end: -1.0,
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeInOut,
    ));

    _bottomNavAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bottomNavController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _bottomNavController.dispose();
    super.dispose();
  }

  void _handleScroll(double offset) {
    if (!widget.enableAutoHide) return;

    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < AppBreakpoints.desktop;

    if (!isMobile) return; // Only apply auto-hide on mobile

    // Do not hide when near the very top until threshold is crossed
    if (offset <= _scrollThreshold) {
      if (!_isAppBarVisible) _showAppBar();
      if (!_isBottomNavVisible) _showBottomNav();
      _lastScrollOffset = offset;
      return;
    }

    final scrollDelta = offset - _lastScrollOffset;

    // Only trigger if scroll delta is significant
    if (scrollDelta.abs() < _scrollThreshold) return;

    if (scrollDelta > 0 && _isAppBarVisible) {
      // Scrolling down - hide app bar and bottom nav
      _hideAppBar();
      _hideBottomNav();
    } else if (scrollDelta < 0 && !_isAppBarVisible) {
      // Scrolling up - show app bar and bottom nav
      _showAppBar();
      _showBottomNav();
    }

    _lastScrollOffset = offset;
  }

  void _hideAppBar() {
    if (!_isAppBarVisible) return;
    setState(() => _isAppBarVisible = false);
    _appBarController.forward();
  }

  void _showAppBar() {
    if (_isAppBarVisible) return;
    setState(() => _isAppBarVisible = true);
    _appBarController.reverse();
  }

  void _hideBottomNav() {
    if (!_isBottomNavVisible) return;
    setState(() => _isBottomNavVisible = false);
    _bottomNavController.forward();
  }

  void _showBottomNav() {
    if (_isBottomNavVisible) return;
    setState(() => _isBottomNavVisible = true);
    _bottomNavController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < AppBreakpoints.desktop;

    return Scaffold(
      backgroundColor:
          widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            _handleScroll(notification.metrics.pixels);
          }
          return false;
        },
        child: Stack(
          children: [
            // Main content that takes full space
            Positioned.fill(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar:
                    widget.appBar != null && !isMobile ? widget.appBar : null,
                body: widget.body,
                bottomNavigationBar:
                    widget.bottomNavigationBar != null && !isMobile
                        ? widget.bottomNavigationBar
                        : null,
              ),
            ),
            // Mobile App Bar overlay
            if (widget.appBar != null && isMobile)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _appBarAnimation,
                  builder: (context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isAppBarVisible
                          ? widget.appBar!.preferredSize.height
                          : 0,
                      child: ClipRect(
                        child: Transform.translate(
                          offset: Offset(
                              0,
                              _appBarAnimation.value *
                                  widget.appBar!.preferredSize.height),
                          child: widget.appBar!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Mobile Bottom Navigation overlay
            if (widget.bottomNavigationBar != null && isMobile)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _bottomNavAnimation,
                  builder: (context, child) {
                    // Get proper bottom navigation bar height including safe area
                    final bottomPadding = MediaQuery.of(context).padding.bottom;
                    final navBarHeight = 80.0 + bottomPadding; // Standard nav bar + safe area
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isBottomNavVisible ? navBarHeight : 0,
                      child: ClipRect(
                        child: Transform.translate(
                          offset: Offset(0, _bottomNavAnimation.value * navBarHeight),
                          child: SafeArea(
                            top: false,
                            child: widget.bottomNavigationBar!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
