## Cross-Role Shared Elements (to centralize as reusable components/providers)

### Navigation and layout
- Global navigation shell: bottom/rail tabs, route helpers, breadcrumb
- App bars: title, search entry, action icons, overflow menus
- Responsive layout grid and breakpoints
- Drawer/side panel patterns
- Footer links (About, Terms, Privacy)

### Authentication and user
- Auth forms: email/password, phone/OTP, social
- Session gate and redirects (logged-in/guest)
- User profile header: avatar, name, contact
- Profile forms: personal, business, preferences
- Access control: role/permission guard wrappers

### Search and discovery
- Search bar with autocomplete/suggestions
- Filter panel: chips, checkboxes, sliders, date pickers
- Sort controls and active-filter chips
- Result list/grid with infinite scroll/pagination
- Empty states and “did you mean”
- Saved searches/history

### Categories and taxonomy
- Category tree browser and breadcrumbs
- Category tiles/cards with icons
- Tag/chip components (facets, topics, materials)

### Location and region context
- Location picker (saved locations, radius)
- Region/state selector
- Geo-aware banners and context display

### Messaging and leads
- Conversation list and thread view
- Composer: text, attachments, send states
- Quick reply templates
- Lead status chips and timeline
- Link-out between lead and chat

### Product/listing basics
- Product card: image, title, key specs
- Product detail sections: media carousel, specs table, seller card
- Actions: share, copy link, save/favorite
- Related items carousel

### Reviews (open to any signed-up user)
- Aggregate rating display
- Review list with filters and sorting
- Review composer: rating, text, media

### State information (content)
- Post list with filters (topic, region)
- Post detail with ToC/anchors
- Compare view (multi-column)
- Stats/summary cards

### Admin/content ops patterns
- Data tables: sorting, filtering, bulk actions, pagination
- Moderation queue: approve/reject with reasons
- Audit log viewer
- Feature flags toggle list
- Media library (search, upload, usage)
- Schema/design editors (attributes, hero sections)

### Forms and inputs
- Unified form fields: text, number, select, multi-select, chip input
- Validation states and inline errors
- Sectioned forms with sticky summary
- Draft/save/publish button set
- File/image upload with progress

### Feedback and status
- Notifications/toasts/snackbars
- Error/empty/loading skeletons
- Status badges (active, draft, suspended, verified)
- Progress indicators (spinners, bars)

### Actions and utilities
- Share, copy link, open in new tab
- Confirm dialogs and destructive actions
- Date/time picker and formatter
- Export (CSV/PNG text snapshot) where applicable

### Visual components
- Image carousel/lightbox
- KPI/metric cards
- Charts (sparklines, bar/line)
- Tabs and segmented controls
- Collapsible sections/accordions

### Theming and i18n
- Color tokens and typography scale
- Dark/light mode switch
- i18n strings and number/date localization

### Providers/stores to centralize
- Auth/session provider
- User profile provider
- Role/permission (RBAC) provider
- Search store (query, filters, results, history)
- Categories/taxonomy store
- Messaging store (threads, messages, unread)
- Leads store (items, status, notes)
- Products/listings store
- Reviews store
- State info content store
- Media storage/service
- Notifications service
- Feature flags provider
- Analytics/metrics provider
- App settings (theme, language, location)


