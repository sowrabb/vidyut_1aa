## Product Image Gallery

Props:
- imageUrls: required List<String>
- loop: default false
- heroPrefix: optional String to coordinate Hero transitions

Behavior:
- Swipe between images (PageView)
- Left/Right arrows (hover/desktop visible; mobile tappable)
- Clickable thumbnails with selection ring; Enter/Space activate
- Full-screen viewer on tap with zoom (≥3x), pan, ESC/arrow keys

A11y:
- Semantics labels announce position ("Image X of N")
- Arrow buttons and thumbnails have labels
- Focus returned after closing full-screen

Theming:
- Uses `AppColors.thumbBg` and primary color for selection ring

Testing:
- See `test/widgets/product_image_gallery_test.dart` for basic interactions


