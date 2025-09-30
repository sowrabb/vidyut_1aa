## Store Submission Checklist (Play Store + App Store + Web/PWA)

- Note: Check the boxes as you complete items. Current status uses ✅ ready / ❌ missing/needs action.

### Play Store (Android)
- [x] ✅ Unique `applicationId` set (e.g., `com.yourcompany.vidyut`) — update in `android/app/build.gradle.kts`
- [ ] ❌ Release signing configured (`signingConfigs.release` and use in `buildTypes.release`)
- [ ] ✅ Versioning wired to Flutter (`versionCode`/`versionName`) — increment for each release
- [ ] ✅ Target/Min SDK meet Play minimums — verify Flutter defaults are current
- [ ] ❌ Branded adaptive app icons present (replace default Flutter icons)
- [x] ✅ Remove unused permissions or justify usage in-app
  - [x] ✅ `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` — used? keep only if required
  - [x] ✅ `CAMERA` — used? keep only if required
  - [x] ✅ `READ_MEDIA_IMAGES` (Android 13+) — ok if picking images
  - [x] ✅ `READ_EXTERNAL_STORAGE` — removed
  - [ ] ❓ `POST_NOTIFICATIONS` — add only if using notifications on Android 13+
- [ ] ❌ Privacy Policy URL prepared and added in Play Console
- [ ] ❌ Data Safety form completed (declare Firebase/analytics/crashlytics if used)
- [ ] ✅ HTTPS only networking; if any HTTP endpoints are used add cleartext policy + justification
- [x] ✅ Optional: Add `<uses-feature android:name="android.hardware.camera" android:required="false"/>` to filter devices
- [ ] ❌ Store listing assets ready (screenshots, feature graphic), descriptions, contact email, support URL
- [ ] ❓ Ads/IAP declarations correct (mark if showing ads or using IAP)
- [ ] ❌ Content rating questionnaire completed
- [ ] ✅ OSS notices included (Flutter NOTICES)
- [ ] ✅ Test release build on API 24 → latest; fix crashes/ANRs

### App Store (iOS)
- [ ] ❌ Unique Bundle Identifier set in Xcode/App Store Connect (reverse-DNS)
- [ ] ❌ Signing/profiles configured for Release (Team, automatic signing ok)
- [ ] ✅ Version (`FLUTTER_BUILD_NAME`) and Build (`FLUTTER_BUILD_NUMBER`) set — increment per submission
- [ ] ❌ Branded AppIcon asset catalog configured (replace defaults)
- [ ] ✅ Launch screen storyboard set and branded (`LaunchScreen`)
- [ ] ✅ Permission strings present in `Info.plist`
  - [ ] ✅ `NSCameraUsageDescription`
  - [ ] ✅ `NSPhotoLibraryUsageDescription`
  - [ ] ❓ `NSPhotoLibraryAddUsageDescription` (add if saving to Photos)
  - [ ] ✅ `NSLocationWhenInUseUsageDescription`
  - [x] ✅ `NSLocationAlwaysAndWhenInUseUsageDescription` — removed (not requesting background location)
  - [ ] ❓ `NSUserTrackingUsageDescription` — add if using tracking/ads (ATT)
- [ ] ✅ ATS (App Transport Security) — all endpoints HTTPS; add exceptions only if necessary
- [x] ✅ Orientations: iPhone restricted to Portrait
- [ ] ✅ Background modes not enabled unless truly required
- [ ] ❌ Privacy Policy URL in App Store Connect
- [ ] ❌ App Privacy questionnaire completed (data collection/sharing)
- [ ] ❌ Age rating questionnaire completed
- [ ] ❓ Sign in with Apple included if any third‑party login is offered
- [ ] ❌ Store listing assets ready (screenshots for all devices, description, keywords, support URL, marketing URL, promo text)
- [ ] ✅ Build and test Release on physical devices (arm64), no debug logs/crashes

### Web / PWA
- [ ] ✅ `web/manifest.json` — name/short_name/theme/background set
- [x] ✅ `web/manifest.json` — description updated to branded copy
- [ ] ✅ Icons present (192/512 + maskable variants)
- [ ] ✅ Favicon, 404, index exist
- [ ] ❌ Public Privacy Policy page/URL (link in app/site if applicable)

### Deliverables to Prepare (both stores)
- [ ] ❌ Privacy Policy (hosted URL)
- [ ] ❌ Final app name, subtitle/short/long descriptions, keywords
- [ ] ❌ Screenshots (all required sizes), feature graphic (Play), app preview optional (iOS)
- [ ] ❌ Support email, support URL, marketing URL
- [ ] ❌ Reviewer notes and demo account (if login-gated)

### Build/Release Artifacts
- [ ] ❌ Android: Signed `app-release.aab` built with `--release`, shrink/minify as appropriate
- [ ] ❌ iOS: Archive in Xcode (Release), upload via Organizer/Transporter

### Quick References (files to edit)
- `android/app/build.gradle.kts`: applicationId, signingConfigs.release, buildTypes.release
- `android/app/src/main/AndroidManifest.xml`: permissions, icons, cleartext/network config
- `ios/Runner/Info.plist`: permission strings, orientations, ATS (if needed)
- Xcode `Runner` target: Bundle Identifier, Signing & Capabilities, App Icons
- `web/manifest.json`: description, icons, colors

Legend: ✅ ready, ❌ missing/needs action, ⚠️ review/likely adjust, ❓ conditional (only if applicable)
