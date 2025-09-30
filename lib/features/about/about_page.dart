import 'package:flutter/material.dart';
import '../../app/layout/adaptive.dart';
import '../../app/layout/app_shell_scaffold.dart';
import '../../app/tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      appBar: VidyutAppBar(title: 'About Us'),
      body: _AboutContent(),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroHeader(),
          SizedBox(height: AppSpace.xl),
          ContentClamp(child: _StorySection()),
          SizedBox(height: AppSpace.xl),
          ContentClamp(child: _SpecialtiesSection()),
          SizedBox(height: AppSpace.xl),
          ContentClamp(child: _VisionSection()),
          SizedBox(height: AppSpace.xl),
          ContentClamp(child: _ExperienceSection()),
          SizedBox(height: AppSpace.xl),
          ContentClamp(child: _ValuesSection()),
          SizedBox(height: AppSpace.xl),
          ContentClamp(child: _CreditSection()),
          SizedBox(height: AppSpace.xxl),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isNarrow = screenWidth < 500;
    final double headerAspect = isNarrow ? (16 / 9) : (16 / 6);
    final double titleSize = isNarrow ? 24 : 38;
    final double subTitleSize = isNarrow ? 12 : 18;
    final double pad = isNarrow ? AppSpace.lg : AppSpace.xl;
    final double gap = isNarrow ? 4 : 8;
    final int titleLines = isNarrow ? 1 : 2;
    final int subTitleLines = isNarrow ? 1 : 2;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: headerAspect,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/banner/3.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        Container(
          height: MediaQuery.sizeOf(context).width / headerAspect,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.transparent
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vidyut — by Madhu Powertech Pvt. Ltd.',
                    maxLines: titleLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(color: AppColors.shadow, blurRadius: 8)
                      ],
                    ),
                  ),
                  SizedBox(height: gap),
                  Text(
                    'Three decades powering electrical infrastructure',
                    maxLines: subTitleLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: subTitleSize,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: AppColors.shadow, blurRadius: 6)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Story',
            style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpace.md),
        const ResponsiveRow(
          desktop: 2,
          tablet: 2,
          phone: 1,
          gap: AppSpace.lg,
          useFieldMaxWidth: false,
          children: [
            _Paragraph(
                'Vidyut is crafted by Madhu Powertech Pvt. Ltd. to modernize how the electrical industry discovers, evaluates, and procures products. For over three decades, we have specialized in transformers, switchgear, transmission and distribution lines, substations, control panels, and critical components used across homes, commercial facilities, and power plants.'
                ' That field experience revealed persistent friction — fragmented information, inconsistent specifications, and limited visibility.'),
            _ImageCard.asset(
              assetPath: 'assets/banner/2.webp',
              caption: 'Grid-scale reliability for industry and infrastructure',
            ),
          ],
        ),
      ],
    );
  }
}

class _VisionSection extends StatelessWidget {
  const _VisionSection();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('A Vision 25 Years in the Making',
            style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpace.md),
        const ResponsiveRow(
          desktop: 2,
          tablet: 2,
          phone: 1,
          gap: AppSpace.lg,
          useFieldMaxWidth: false,
          children: [
            _Paragraph(
                'Our founder, Akula Mathusudar, envisioned this application a quarter century ago. After three decades of hands-on industry work, he distilled countless customer conversations and real-world edge cases into a single platform that is simple, comprehensive, and fast.'
                ' Vidyut is the embodiment of that vision — practical, scalable, and built on trust.'),
            _ImageCard.asset(
              assetPath: 'assets/banner/1.JPG',
              caption: 'From vision to grid-ready reality',
            ),
          ],
        ),
      ],
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Three Decades of Experience',
            style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpace.md),
        const ResponsiveRow(
          desktop: 3,
          tablet: 2,
          phone: 1,
          gap: AppSpace.lg,
          children: [
            _ValueCard(
                icon: Icons.engineering,
                title: 'Deep Product Knowledge',
                body:
                    'Specifications that actually matter, vetted by experience, not just brochures.'),
            _ValueCard(
                icon: Icons.handshake,
                title: 'Customer Obsessed',
                body:
                    'We build what technicians, contractors, and procurement teams truly need.'),
            _ValueCard(
                icon: Icons.speed,
                title: 'Efficiency by Design',
                body:
                    'Fast search, clear comparisons, and structured data for confident decisions.'),
            _ValueCard(
                icon: Icons.security,
                title: 'Safety & Compliance',
                body:
                    'Standards-aligned components with rigorous QA and complete documentation.'),
          ],
        ),
      ],
    );
  }
}

class _ValuesSection extends StatelessWidget {
  const _ValuesSection();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What Guides Us',
            style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpace.md),
        const ResponsiveRow(
          desktop: 2,
          tablet: 2,
          phone: 1,
          gap: AppSpace.lg,
          useFieldMaxWidth: false,
          children: [
            _Paragraph(
                'Clarity over clutter. Data over guesswork. Reliability over noise. Vidyut focuses on what matters most to professionals — accurate information, transparent choices, and tools that respect your time.'),
            _ImageCard.asset(
              assetPath: 'assets/banner/3.jpg',
              caption: 'Built for professionals in power and distribution',
            ),
          ],
        ),
      ],
    );
  }
}

class _SpecialtiesSection extends StatelessWidget {
  const _SpecialtiesSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Our Specialties',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpace.md),
            const _BulletList(alignCenter: true, items: [
              'Power and distribution transformers',
              'Switchgear and control panels',
              'Transmission and distribution lines',
              'Substations and protection systems',
              'Electrical balance-of-plant for homes, commercial, and power plants',
            ]),
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final bool alignCenter;
  const _BulletList({required this.items, this.alignCenter = false});

  @override
  Widget build(BuildContext context) {
    if (alignCenter) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('•  $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontSize: 16)),
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 16)),
                  Expanded(
                      child: Text(e,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.6,
                              fontSize: 16))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CreditSection extends StatelessWidget {
  const _CreditSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpace.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Madhu Powertech Pvt. Ltd.',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 6),
          Text(
            'Founded and led by Akula Mathusudar. This app is the culmination of decades of dedication to the electrical ecosystem and the belief that technology should make industry simpler, smarter, and more human.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          SizedBox(height: AppSpace.md),
          Text(
            'Image credits: Unsplash contributors (industry, engineering, and technology collections).',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: AppColors.textSecondary, height: 1.6, fontSize: 16),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String? url;
  final String? assetPath;
  final String caption;
  const _ImageCard({required this.url, required this.caption})
      : assetPath = null;
  const _ImageCard.asset({required this.assetPath, required this.caption})
      : url = null;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Ink.image(
              image: assetPath != null
                  ? AssetImage(assetPath!) as ImageProvider
                  : NetworkImage(url!),
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpace.sm),
            child: Text(caption,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _ValueCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowSoft, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySurface,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(body,
              style:
                  const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
