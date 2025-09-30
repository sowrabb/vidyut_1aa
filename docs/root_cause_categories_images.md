Seller Banner Upload RCA

Summary: The seller banner picker and preview were non-functional because picker methods were placeholders returning null, preview didn’t support local paths/bytes, and platform permissions were missing.

Root Causes
- Picker methods (ImageService.uploadFromCamera/Gallery/Files) were stubs that returned null.
- Preview widget only supported assets and http URLs; local paths or web-stored bytes could not render.
- Missing platform permissions prevented camera/gallery usage on devices (Android CAMERA/READ_MEDIA_IMAGES; iOS NSCameraUsageDescription/NSPhotoLibraryUsageDescription).

Fixes
- Implemented picker methods using image_picker (mobile) and file_picker (all; bytes for web).
- LightweightImageWidget now loads from bytes for local paths or web storage via LightweightImageService.getImageBytes.
- ImageUploadWidget shows immediate local preview, uploads bytes with progress, and swaps to remote URL on success; handles errors and retry.
- Added Android and iOS permissions.

Notes
- Web camera is disabled with a friendly message; Files works on Web.
- Max file size 10 MB enforced; extensions: jpg/jpeg/png/webp.
Root cause analysis — Seller Dashboard image preview

Summary
- Previews were blank/broken due to two issues:
  1) Previews bound only to final remote URLs with no immediate local rendering, causing empty tiles until upload finished or failed.
  2) Stale cached URLs when re-uploading with same path/name, leading to old images being shown or nothing (token mismatch).

Fix
- Show instant local preview using memory bytes while upload runs in background.
- Upload to Firebase Storage with unique filenames and obtain `getDownloadURL()`.
- Cache-bust UI by appending `?v=<timestamp>` upon swap to remote URL.
- Add per-tile progress and retry; ensure state emits updated immutable URL list to trigger rebuilds.

Files
- `lib/widgets/media_upload_widget.dart`
- `lib/services/image_management_service.dart`

Root cause: Categories images not displaying on public list

Summary
- Public Categories page rendered images using `Image.asset` and expected an asset path in `category.imageUrl`.
- Admin → Categories → Edit used `Image.network` and passed a full HTTPS URL in `imageUrl`.
- When categories had HTTPS URLs (Firebase CDN/Storage), the public list tried to load them as assets → image failed silently and showed nothing.

Affected code
- Public list card: `lib/widgets/responsive_category_card.dart` (previously used `Image.asset(category.imageUrl)`).
- Admin cards and editor preview: `lib/features/admin/pages/categories_management_page.dart` (uses `Image.network`).

Fix
- Standardized rendering through `LightweightImageWidget`, which supports both `assets/...` and `https://...` paths with placeholders and error states.
- File updated: `lib/widgets/responsive_category_card.dart`.

Why it only affected Categories page
- Other admin surfaces already used `Image.network`, so HTTPS URLs rendered fine. Only the public Categories card was constrained to asset-only rendering.

Follow-ups
- Ensure canonical field for categories is `imageUrl` with HTTPS where possible.
- For any legacy `storagePath`/`gs://` values, backfill to `https://` via `getDownloadURL()`.

