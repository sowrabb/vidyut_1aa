import 'package:flutter/material.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../app/tokens.dart';
import '../../app/app_state.dart';
import '../../app/geo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'store/seller_store.dart';
import '../../widgets/responsive_product_grid.dart';

class SellerPage extends StatefulWidget {
  final String sellerName;
  const SellerPage({super.key, required this.sellerName});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> with TickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    // Count a profile view when this page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SellerStore>().incrementProfileView();
      }
    });
  }

  (double, double) _mockSellerLatLng(String seed) {
    // Deterministic fake lat/lng around Hyderabad for demo purposes
    final baseLat = 17.3850;
    final baseLng = 78.4867;
    final delta = (seed.hashCode % 1000) / 10000.0; // 0..0.0999
    return (baseLat + delta, baseLng + delta);
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    Uri websiteUri;
    if (website.startsWith('http://') || website.startsWith('https://')) {
      websiteUri = Uri.parse(website);
    } else {
      websiteUri = Uri.parse('https://$website');
    }
    
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppShellScaffold(
      selectedIndex: 1,
      appBar: const VidyutAppBar(title: 'Vidyut'),
      body: SafeArea(
        child: ContentClamp(
          child: NestedScrollView(
            headerSliverBuilder: (c, inner) => [
              SliverToBoxAdapter(child: _masthead(context, t)),
              SliverAppBar(
                pinned: true,
                toolbarHeight: 56,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                backgroundColor: AppColors.surface,
                title: _tabsOnly(context),
              ),
              // Search field under tabs (separate row to avoid overlap on mobile)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Products/Services',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _productsTab(context),
                _aboutTab(context),
                _reviewsTab(context),
                _contactTab(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _masthead(BuildContext context, TextTheme t) {
    final isPhone = context.isPhone;
    final double logoSize = 112; // 2x size

    // Common meta rows split per requirement
    final appState = context.read<AppState>();
    final hasSellerLatLng = appState.latitude != null && appState.longitude != null;
    final sellerPos = hasSellerLatLng
        ? (appState.latitude!, appState.longitude!)
        : _mockSellerLatLng(widget.sellerName);
    final distanceText = (appState.latitude != null &&
            appState.longitude != null)
        ? '${distanceKm(lat1: appState.latitude!, lon1: appState.longitude!, lat2: sellerPos.$1, lon2: sellerPos.$2).toStringAsFixed(1)} km away'
        : null;

    final store = context.read<SellerStore>();
    final contactMeta = [
      const _Meta('Hyderabad, Telangana'),
      _Meta('GST: 36BDTPG0207N1ZC'),
      if (store.primaryPhone.isNotEmpty)
        _ClickableMetaIcon(
          Icons.call, 
          store.primaryPhone,
          onTap: () => _launchPhone(store.primaryPhone),
        ),
      if (store.primaryEmail.isNotEmpty)
        _ClickableMetaIcon(
          Icons.email_outlined, 
          store.primaryEmail,
          onTap: () => _launchEmail(store.primaryEmail),
        ),
      if (distanceText != null) _Meta(distanceText),
    ];
    const statsMeta = [
      _Badge('11 yrs'),
      _Meta('★ 4.4 (30)'),
      _Meta('72% response'),
    ];

    Future<void> _openMaps() async {
      final google = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${sellerPos.$1},${sellerPos.$2}');
      if (!await launchUrl(google, mode: LaunchMode.externalApplication)) {
        final osm = Uri.parse(
            'https://www.openstreetmap.org/?mlat=${sellerPos.$1}&mlon=${sellerPos.$2}#map=14/${sellerPos.$1}/${sellerPos.$2}');
        await launchUrl(osm, mode: LaunchMode.externalApplication);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: !isPhone
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left cluster (desktop): logo left, details right
                Expanded(
                  child: Row(children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: AppColors.thumbBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineSoft),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.storefront,
                          color: AppColors.textSecondary, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.sellerName, style: t.headlineSmall),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: contactMeta),
                          const SizedBox(height: 6),
                          Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                // Right: desktop CTAs
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.read<SellerStore>().recordSellerContactCall();
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Supplier'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.location_on_outlined),
                    label: Text(distanceText ?? 'View on Map'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<SellerStore>().recordSellerContactWhatsapp();
                    },
                    icon: const Icon(Ionicons.logo_whatsapp),
                    label: const Text('WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ]),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: AppColors.thumbBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineSoft),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.storefront,
                      color: AppColors.textSecondary, size: 36),
                ),
                const SizedBox(height: 12),
                Text(widget.sellerName, style: t.headlineSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 12, runSpacing: 6, children: contactMeta),
                const SizedBox(height: 6),
                Wrap(spacing: 12, runSpacing: 6, children: statsMeta),
                const SizedBox(height: 10),
                // Mobile CTAs under details
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.read<SellerStore>().recordSellerContactCall();
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Contact Supplier'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.location_on_outlined),
                    label: Text(distanceText ?? 'View on Map'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<SellerStore>().recordSellerContactWhatsapp();
                    },
                    icon: const Icon(Ionicons.logo_whatsapp),
                    label: const Text('WhatsApp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _tabsOnly(BuildContext context) {
    return TabBar(
      controller: _tabs,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      tabs: const [
        Tab(text: 'Products & Services'),
        Tab(text: 'About Us'),
        Tab(text: 'Reviews'),
        Tab(text: 'Contact Us'),
      ],
    );
  }

  // Reviews tab extracted from previous Home content
  Widget _reviewsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ratingsSection(context),
      ],
    );
  }

  Widget _aboutTab(BuildContext context) => ListView(
      padding: const EdgeInsets.all(16), children: [_aboutSection(context)]);
  Widget _productsTab(BuildContext context) => ListView(
      padding: const EdgeInsets.all(16), children: [_productsGallery(context)]);
  Widget _contactTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final store = context.watch<SellerStore>();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Contact Information', style: t.titleLarge),
        const SizedBox(height: 16),
        
        // Primary Contact
        if (store.primaryPhone.isNotEmpty || store.primaryEmail.isNotEmpty) ...[
          Text('Primary Contact', style: t.titleMedium),
          const SizedBox(height: 8),
          if (store.primaryPhone.isNotEmpty)
            _ContactItem(
              icon: Icons.phone,
              label: 'Phone',
              value: store.primaryPhone,
              onTap: () => _launchPhone(store.primaryPhone),
            ),
          if (store.primaryEmail.isNotEmpty)
            _ContactItem(
              icon: Icons.email,
              label: 'Email',
              value: store.primaryEmail,
              onTap: () => _launchEmail(store.primaryEmail),
            ),
          const SizedBox(height: 16),
        ],
        
        // Additional Phones
        if (store.additionalPhones.isNotEmpty) ...[
          Text('Additional Phone Numbers', style: t.titleMedium),
          const SizedBox(height: 8),
          ...store.additionalPhones.map((phone) => 
            _ContactItem(
              icon: Icons.phone,
              label: 'Phone',
              value: phone,
              onTap: () => _launchPhone(phone),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Additional Emails
        if (store.additionalEmails.isNotEmpty) ...[
          Text('Additional Email Addresses', style: t.titleMedium),
          const SizedBox(height: 8),
          ...store.additionalEmails.map((email) => 
            _ContactItem(
              icon: Icons.email,
              label: 'Email',
              value: email,
              onTap: () => _launchEmail(email),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Website
        if (store.website.isNotEmpty) ...[
          Text('Website', style: t.titleMedium),
          const SizedBox(height: 8),
          _ContactItem(
            icon: Icons.language,
            label: 'Website',
            value: store.website,
            onTap: () => _launchWebsite(store.website),
          ),
          const SizedBox(height: 16),
        ],
        
        // Business Hours (placeholder)
        Text('Business Hours', style: t.titleMedium),
        const SizedBox(height: 8),
        const _ContactItem(
          icon: Icons.access_time,
          label: 'Monday - Friday',
          value: '9:00 AM - 6:00 PM',
        ),
        const _ContactItem(
          icon: Icons.access_time,
          label: 'Saturday',
          value: '9:00 AM - 4:00 PM',
        ),
        const _ContactItem(
          icon: Icons.access_time,
          label: 'Sunday',
          value: 'Closed',
        ),
        
        // Add bottom padding to prevent content from being cut off by bottom navigation
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _aboutSection(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fields = context.watch<SellerStore>().profileFields;
    final materials = context.watch<SellerStore>().profileMaterials;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('About Us', style: t.titleLarge),
      const SizedBox(height: 8),
      const Text(
          'We are a manufacturer and supplier of electrical products with a focus on quality and service.'),
      const SizedBox(height: 6),
      TextButton(onPressed: () {}, child: const Text('+ Read More')),
      const SizedBox(height: 8),
      if (materials.isNotEmpty) ...[
        Text('Materials Used', style: t.titleMedium),
        const SizedBox(height: 8),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: materials.map((m) => Chip(label: Text(m))).toList()),
        const SizedBox(height: 16),
      ],
      _statsGrid(context),
      const SizedBox(height: 16),
      // Move HSN block into About per request
      _hsnBlock(context),
      const SizedBox(height: 16),
      if (fields.isNotEmpty) ...[
        Text('Additional Info', style: t.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fields.map((f) => Chip(label: Text(f.label))).toList(),
        ),
      ],
    ]);
  }

  Widget _statsGrid(BuildContext context) {
    final items = const [
      _Stat('Nature of Business', 'Manufacturer', Icons.business_outlined),
      _Stat('Legal Status of Firm', 'Proprietorship', Icons.gavel_outlined),
      _Stat('Annual Turnover', '0–40 L', Icons.trending_up_outlined),
      _Stat('GST Registration Date', '01-07-2017', Icons.badge_outlined),
      _Stat('Total Employees', 'Upto 10 People', Icons.people_outline),
      _Stat('IEC', 'BDTPG0207N', Icons.public_outlined),
      _Stat('GST Number', '36BDTPG0207N1ZC', Icons.qr_code_2_outlined),
    ];
    final cross = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.6,
      ),
      itemBuilder: (_, i) => items[i],
    );
  }

  Widget _productsGallery(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final demoProducts = List.generate(
      8,
      (index) => ProductCardData.demo(index: index),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Products & Services', style: t.titleLarge),
      const SizedBox(height: 12),
      ResponsiveProductGrid(
        products: demoProducts,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      const SizedBox(height: 12),
      Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
              onPressed: () {}, child: const Text('View Complete Range'))),
    ]);
  }

  Widget _hsnBlock(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Deals in HSN Code', style: t.titleLarge),
      const SizedBox(height: 8),
      DataTable(columns: const [
        DataColumn(label: Text('HSN Code')),
        DataColumn(label: Text('HSN Description')),
      ], rows: const [
        DataRow(cells: [
          DataCell(Text('98010030')),
          DataCell(Text('Professional services — long description wraps here.'))
        ]),
        DataRow(cells: [
          DataCell(Text('85044030')),
          DataCell(Text('Static converters, transformers, etc.'))
        ]),
      ]),
    ]);
  }

  Widget _ratingsSection(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isDesktop = context.isDesktop;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Ratings & Reviews', style: t.titleLarge),
      const SizedBox(height: 12),
      isDesktop
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _ratingSummary(context)),
              const SizedBox(width: 12),
              Expanded(child: _satisfaction(context)),
            ])
          : Column(children: [
              _ratingSummary(context),
              const SizedBox(height: 12),
              _satisfaction(context),
            ]),
      const SizedBox(height: 16),
      // Reviews list (two demo items)
      const _SellerReviewCard(
          name: 'Rahul',
          location: 'Hyderabad',
          stars: 5,
          product: 'Copper Cable 1.5 sqmm'),
      const SizedBox(height: 8),
      const _SellerReviewCard(
          name: 'Aarti',
          location: 'Pune',
          stars: 4,
          product: 'Switchgear Panel'),
      const SizedBox(height: 8),
      Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {}, child: const Text('View More Reviews'))),
    ]);
  }

  Widget _ratingSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('4.4/5'),
          const SizedBox(height: 4),
          _starRow(4.4),
          const Text('30 Ratings'),
          const SizedBox(height: 8),
          for (int i = 5; i >= 1; i--)
            Row(children: [
              SizedBox(width: 28, child: Text('$i')),
              const SizedBox(width: 6),
              const Expanded(child: LinearProgressIndicator(value: 0.7)),
              const SizedBox(width: 6),
              const Text('70%')
            ]),
        ]),
      ),
    );
  }

  Widget _satisfaction(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('User Satisfaction'),
              SizedBox(height: 8),
              _Meter(label: 'Response', value: 0.72),
              _Meter(label: 'Quality', value: 0.81),
              _Meter(label: 'Delivery', value: 0.64),
            ]),
      ),
    );
  }

  Widget _starRow(double v) {
    return Row(
        children: List.generate(
            5,
            (i) => Icon(i < v.floor() ? Icons.star : Icons.star_border,
                size: 16)));
  }
}

class _Meta extends StatelessWidget {
  final String text;
  const _Meta(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodySmall);
}


class _ClickableMetaIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _ClickableMetaIcon(this.icon, this.text, {required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Chip(label: Text(text));
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value)
        ]),
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  final String label;
  final double value;
  const _Meter({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 100, child: Text(label)),
      const SizedBox(width: 8),
      Expanded(child: LinearProgressIndicator(value: value)),
      const SizedBox(width: 8),
      Text('${(value * 100).round()}%'),
    ]);
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        subtitle: Text(value),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
        onTap: onTap,
      ),
    );
  }
}

class _SellerReviewCard extends StatelessWidget {
  final String name;
  final String location;
  final int stars;
  final String product;
  const _SellerReviewCard(
      {required this.name,
      required this.location,
      required this.stars,
      required this.product});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Text('A')),
            const SizedBox(width: 8),
            Expanded(child: Text('$name • $location', style: t.titleSmall)),
          ]),
          const SizedBox(height: 6),
          Row(
              children: List.generate(
                  5,
                  (i) => Icon(i < stars ? Icons.star : Icons.star_border,
                      size: 16))),
          const SizedBox(height: 6),
          Text('Product Name: $product', style: t.bodySmall),
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: const [
            Chip(label: Text('Response')),
            Chip(label: Text('Quality')),
            Chip(label: Text('Delivery'))
          ]),
          Align(
              alignment: Alignment.centerLeft,
              child:
                  TextButton(onPressed: () {}, child: const Text('Helpful'))),
        ]),
      ),
    );
  }
}
