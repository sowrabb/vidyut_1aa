## Ads: Product Selection Field

This document summarizes the Product Picker added to the Create/Edit Ad flows.

### Model
- `AdCampaign` now includes optional fields:
  - `productId: String?`
  - `productTitle: String?` (denormalized)
  - `productThumbnail: String?` (denormalized)

These are set when the ad type is product-based. For search/category ads, they remain null.

### UI/UX
- Create New Ad (`lib/features/sell/ads_create_page.dart`):
  - Added a new `AdType.product` option.
  - When selected, shows a Product section with a "Select Product" button.
  - Opens a dialog using `ProductPicker` to search and select a product.
  - After selection, a summary card appears with title, price, and Change/Clear actions.
  - Validation prevents submission if no product is selected for product-type ads.

- Ads List (`lib/features/sell/ads_page.dart`):
  - Displays "Product campaign" type and shows selected product title.
  - Supports Change (with confirmation) and Clear actions inline.

### ProductPicker
- `lib/widgets/product_picker.dart` provides a reusable picker widget:
  - Search input with simple in-memory filtering over seller products.
  - Basic pagination (page size 20) using in-memory data (MVP).
  - Emits selected `Product` via callback.

### Data Sources
- Uses `sellerStoreProvider` products (in-memory demo service). For backend wiring, replace the in-memory list with a repository call supporting server-side search and pagination.

### Analytics
- `lib/services/analytics_service.dart` exposes `logEvent` for generic events.
- Emitted events:
  - `ads_product_picker_opened`
  - `ads_product_selected` (entityType: product, entityId: productId)
  - `ads_product_cleared`

### Backend Contract (proposed)
- Create/Update Campaign request includes `productId` when ad type is product.
- Optional denormalized `productTitle` and `productThumbnail` may be stored for faster list rendering.

### Testing Notes (to add)
- Widget tests should cover:
  - Opening the picker from Create Ad.
  - Selecting a product and seeing the summary card.
  - Validation error when trying to submit without selection in product mode.
  - Edit flow: Change with confirmation and Clear.
- Golden tests for ProductPicker states (empty/loading/populated/selected) require deterministic fonts and DPR.

### Responsiveness & A11y
- Dialog layout targets: mobile, tablet, and web widths; uses grid with safe aspect ratio.
- Buttons and controls have accessible labels via Material defaults.

### Follow-ups
- Replace in-memory pagination/filtering with backend-driven API.
- Add eligibility filters (e.g., status in-stock/active) if needed.
- Add unit/widget/golden tests per acceptance criteria.

