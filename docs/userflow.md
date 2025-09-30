## Vidyut User Flows (Screens and Navigation)

### Top-level Navigation (Tabs / Rail)
- **Home**: `HomePage`
- **Search**: `SearchPage`
- **Messages**: `MessagingPage` (desktop only in global nav, still accessible elsewhere)
- **Categories**: `CategoriesPage` (desktop only in global nav, accessible from Home/links)
- **Sell**: `SellHubPage` → `SellHubShell` (internal tabs listed below)
- **State Info**: `StateInfoPage` → `CleanStateInfoPage`
- **Profile**: `ProfilePage` (tabs inside)

Notes:
- Mobile bottom navigation shows: Home, Search, Sell, State Info, Profile.
- Desktop navigation rail shows: Home, Search, Messages, Categories, Sell, State Info, Profile.

### Home Flow (HomePage)
- Home landing content and CTAs
  - Location picker in app bar
  - Search field (phone-only inline, also app bar search)
  - Category grid and Explore/All Categories CTA
  - Products grid (Frequently Bought)
- Admin access buttons (desktop):
  - Admin (if logged in) → `AdminShell`
  - Admin Login (if logged out) → `AdminLoginPage`

Child screens reachable from Home:
- Search (query submit) → `SearchPage(initialQuery)`
- Categories (View All / Explore Products) → `CategoriesPage`

### Search Flow (SearchPage)
- Modes: Products | Profiles using material
- Filters: categories, materials, price, sort, location summary
- Results:
  - Product card → `ProductDetailPage`
  - Profile card → `SellerPage`
  - Sponsored/Ad cards (in-line)

Child screens reachable from Search:
- Product detail → `ProductDetailPage`
- Seller profile → `SellerPage`

### Categories Flow (CategoriesPage)
- Search, filters (industries, materials), sort
- Grid of categories → Category detail

Child screens reachable from Categories:
- Category detail → `CategoryDetailPage`

### Messages Flow (MessagingPage)
- Conversation list + conversation view (responsive: list/detail or two-pane)
- New Message sheet (start conversation with support or a seller)

States/screens:
- Conversation list (no active conversation)
- Conversation view (when active conversation selected)
- New Message bottom sheet (compose → ensures/opens conversation)

### Sell Hub Flow (SellHubPage → SellHubShell)
Internal navigation items (tabs/pages):
- Dashboard → `DashboardPage`
- Analytics → `AnalyticsPage`
- Products → `ProductsListPage`
- B2B Leads → `LeadsPage`
- Profile → `ProfileSettingsPage`
- Subscription → `SubscriptionPage`
- Ads → `AdsPage`
- Signup → `SellerSignupPage`

Other sell-related screens (navigated from within pages):
- Product form → `ProductFormPage`
- Product detail → `ProductDetailPage`
- Ads create → `AdsCreatePage`

### State Info Flow (StateInfoPage → CleanStateInfoPage)
- Clean, dropdown-based selection UX inside `CleanStateInfoPage`
- Additional state info widgets exist (e.g., power/state flow editors) but the primary entry is `CleanStateInfoPage`

### Profile Flow (ProfilePage)
Tabs inside Profile:
- Overview
- Saved
- RFQs
- Settings

Inline actions from Profile:
- Messages FAB/shortcut → `MessagingPage`

### Admin Access (from Home)
- Admin Login → `AdminLoginPage`
- Admin Panel → `AdminShell` (contains many admin pages: users/products/categories/kyc/rbac/analytics/etc.)

---

## Ordered Screen Lists (by feature)

### App Shell (Top-level order)
1. Home (`HomePage`)
2. Search (`SearchPage`)
3. Messages (`MessagingPage`) [desktop rail]
4. Categories (`CategoriesPage`) [desktop rail]
5. Sell (`SellHubPage` → `SellHubShell`)
6. State Info (`StateInfoPage` → `CleanStateInfoPage`)
7. Profile (`ProfilePage`)

### Sell Hub (Internal order)
1. Dashboard (`DashboardPage`)
2. Analytics (`AnalyticsPage`)
3. Products (`ProductsListPage`)
4. B2B Leads (`LeadsPage`)
5. Profile (`ProfileSettingsPage`)
6. Subscription (`SubscriptionPage`)
7. Ads (`AdsPage`)
8. Signup (`SellerSignupPage`)

### Profile (Tabs order)
1. Overview
2. Saved
3. RFQs
4. Settings

---

## Arrow Diagrams (End-to-End User Flows)

### Global Navigation (desktop)
Home → Search → Messages → Categories → Sell → State Info → Profile

### Global Navigation (mobile)
Home → Search → Sell → State Info → Profile

### Home-driven
Home → Search(initialQuery)
Home → Categories
Home → Admin Login → Admin Shell
Home (desktop, logged-in) → Admin Shell

### Search-driven
Search → Product Detail
Search → Seller Page

### Categories-driven
Categories → Category Detail

### Messaging-driven
Messaging (List) → Messaging (Conversation View)
Messaging → New Message Sheet → Messaging (Conversation View)

### Sell Hub-driven
Sell → Dashboard → Analytics → Products → Leads → Profile Settings → Subscription → Ads → Signup
Sell → Products → Product Form
Sell → Products → Product Detail
Sell → Ads → Ads Create

### State Info-driven
State Info → Clean State Info Page (in-page dropdown flows)

### Profile-driven
Profile → Overview → Saved → RFQs → Settings
Profile → Messages (via FAB/shortcut)

---

## Screen Index (Reference)
- HomePage
- SearchPage
- MessagingPage
- CategoriesPage
- CategoryDetailPage
- ProductDetailPage
- SellerPage
- SellHubPage / SellHubShell
- DashboardPage
- AnalyticsPage
- ProductsListPage
- ProductFormPage
- AdsPage
- AdsCreatePage
- LeadsPage
- ProfileSettingsPage
- SubscriptionPage
- SellerSignupPage
- StateInfoPage / CleanStateInfoPage
- ProfilePage (Overview, Saved, RFQs, Settings)
- AdminLoginPage
- AdminShell


