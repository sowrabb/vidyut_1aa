/// Demo data for profile posts and updates
class ProfilePostsData {
  static List<ProfilePost> getGeneratorPosts(String generatorId) {
    switch (generatorId) {
      case 'ntpc':
        return [
          ProfilePost(
            id: 'ntpc_1',
            title: 'New 500MW Solar Plant Commissioned',
            content:
                'NTPC has successfully commissioned a new 500MW solar power plant in Rajasthan. This plant will generate clean energy for over 1 million households.',
            imageUrl:
                'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800',
            imageUrls: [
              'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=1200',
              'https://images.unsplash.com/photo-1505731132164-ccaebb49fdb0?w=1200',
            ],
            pdfUrls: [
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            ],
            category: PostCategory.update,
            tags: ['Solar', 'Renewable Energy', 'Rajasthan', 'Clean Energy'],
            author: 'NTPC Official',
            publishDate: DateTime.now().subtract(const Duration(days: 2)),
            likes: 1247,
            comments: 89,
          ),
          ProfilePost(
            id: 'ntpc_2',
            title: 'Advanced Turbine Design for Higher Efficiency',
            content:
                'Our latest turbine design increases efficiency by 15% while reducing maintenance costs. This breakthrough technology will be implemented across all our thermal plants.',
            imageUrl:
                'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
            imageUrls: [
              'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=1200',
            ],
            category: PostCategory.productDesign,
            tags: ['Turbine', 'Efficiency', 'Technology', 'Thermal'],
            author: 'NTPC Engineering',
            publishDate: DateTime.now().subtract(const Duration(days: 5)),
            likes: 892,
            comments: 156,
          ),
          ProfilePost(
            id: 'ntpc_3',
            title: 'Green Hydrogen Pilot Project Launch',
            content:
                'NTPC launches India\'s first green hydrogen pilot project. This initiative will help reduce carbon emissions and promote sustainable energy solutions.',
            imageUrl:
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
            pdfUrls: [
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
              'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf',
            ],
            category: PostCategory.update,
            tags: [
              'Green Hydrogen',
              'Sustainability',
              'Carbon Reduction',
              'Innovation'
            ],
            author: 'NTPC Innovation Team',
            publishDate: DateTime.now().subtract(const Duration(days: 7)),
            likes: 2156,
            comments: 234,
          ),
        ];
      case 'nhpc':
        return [
          ProfilePost(
            id: 'nhpc_1',
            title: 'New Hydroelectric Dam Construction Update',
            content:
                'NHPC\'s new 200MW hydroelectric dam is 75% complete. The project will provide clean energy to the northern region and create employment opportunities.',
            imageUrl:
                'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            category: PostCategory.update,
            tags: ['Hydroelectric', 'Dam', 'Clean Energy', 'Employment'],
            author: 'NHPC Project Team',
            publishDate: DateTime.now().subtract(const Duration(days: 1)),
            likes: 1876,
            comments: 123,
          ),
          ProfilePost(
            id: 'nhpc_2',
            title: 'Smart Grid Technology Implementation',
            content:
                'Advanced smart grid technology being implemented across NHPC facilities. This will improve grid stability and enable better energy management.',
            imageUrl:
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
            category: PostCategory.productDesign,
            tags: [
              'Smart Grid',
              'Technology',
              'Grid Stability',
              'Energy Management'
            ],
            author: 'NHPC Technology',
            publishDate: DateTime.now().subtract(const Duration(days: 3)),
            likes: 945,
            comments: 67,
          ),
        ];
      default:
        return [];
    }
  }

  static List<ProfilePost> getTransmissionPosts(String transmissionId) {
    switch (transmissionId) {
      case 'transmission_1':
        return [
          ProfilePost(
            id: 'trans_1',
            title: 'New 765kV Transmission Line Commissioned',
            content:
                'A new 765kV transmission line connecting Delhi to Mumbai has been successfully commissioned. This will improve power transfer capacity by 40%.',
            imageUrl:
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
            category: PostCategory.update,
            tags: [
              '765kV',
              'Transmission Line',
              'Delhi-Mumbai',
              'Power Transfer'
            ],
            author: 'Power Grid Corporation',
            publishDate: DateTime.now().subtract(const Duration(days: 1)),
            likes: 1234,
            comments: 89,
          ),
          ProfilePost(
            id: 'trans_2',
            title: 'Advanced Insulator Design for Harsh Weather',
            content:
                'New ceramic insulator design that can withstand extreme weather conditions. Reduces maintenance costs and improves reliability.',
            imageUrl:
                'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
            category: PostCategory.productDesign,
            tags: ['Insulator', 'Ceramic', 'Weather Resistance', 'Reliability'],
            author: 'Transmission Engineering',
            publishDate: DateTime.now().subtract(const Duration(days: 4)),
            likes: 756,
            comments: 45,
          ),
        ];
      default:
        return [];
    }
  }

  static List<ProfilePost> getStatePosts(String stateId) {
    switch (stateId) {
      case 'telangana':
        return [
          ProfilePost(
            id: 'tel_1',
            title: 'Telangana Solar Policy 2024 Updates',
            content:
                'New solar policy announced with incentives for rooftop installations. Target of 5000MW solar capacity by 2025.',
            imageUrl:
                'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800',
            category: PostCategory.update,
            tags: ['Solar Policy', 'Rooftop', 'Incentives', '2025 Target'],
            author: 'Telangana Energy Department',
            publishDate: DateTime.now().subtract(const Duration(days: 2)),
            likes: 1890,
            comments: 156,
          ),
          ProfilePost(
            id: 'tel_2',
            title: 'Smart Meter Installation Program',
            content:
                'State-wide smart meter installation program launched. Will help consumers monitor usage and reduce electricity bills.',
            imageUrl:
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
            category: PostCategory.productDesign,
            tags: [
              'Smart Meters',
              'Consumer Benefits',
              'Usage Monitoring',
              'Billing'
            ],
            author: 'TSDISCOM',
            publishDate: DateTime.now().subtract(const Duration(days: 6)),
            likes: 1123,
            comments: 78,
          ),
        ];
      case 'maharashtra':
        return [
          ProfilePost(
            id: 'mah_1',
            title: 'Maharashtra Wind Energy Expansion',
            content:
                'New wind energy projects approved across Maharashtra. Expected to add 2000MW of clean energy capacity.',
            imageUrl:
                'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
            category: PostCategory.update,
            tags: ['Wind Energy', 'Clean Energy', '2000MW', 'Expansion'],
            author: 'Maharashtra Energy Department',
            publishDate: DateTime.now().subtract(const Duration(days: 3)),
            likes: 1456,
            comments: 98,
          ),
        ];
      default:
        return [];
    }
  }

  static List<ProfilePost> getMandalPosts(String mandalId) {
    return [
      ProfilePost(
        id: 'mandal_1',
        title: 'Local Transformer Upgrade Program',
        content:
            'All transformers in the mandal upgraded to handle increased load. Power cuts reduced by 60%.',
        imageUrl:
            'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
        category: PostCategory.update,
        tags: ['Transformer', 'Upgrade', 'Load Management', 'Power Cuts'],
        author: 'Local Electricity Board',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        likes: 234,
        comments: 23,
      ),
    ];
  }

  static List<ProfilePost> getDistributionPosts(String distributionId) {
    return [
      ProfilePost(
        id: 'discom_1',
        title: 'New Distribution Network Design',
        content:
            'Advanced distribution network design with automated switching. Improves reliability and reduces outage time.',
        imageUrl:
            'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
        category: PostCategory.productDesign,
        tags: [
          'Distribution Network',
          'Automated Switching',
          'Reliability',
          'Outage Reduction'
        ],
        author: 'Distribution Engineering',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        likes: 567,
        comments: 34,
      ),
    ];
  }

  static List<String> getFilterTags(PostCategory category) {
    switch (category) {
      case PostCategory.update:
        return [
          'Solar',
          'Wind',
          'Hydro',
          'Thermal',
          'Nuclear',
          'Renewable Energy',
          'Policy',
          'Commissioning',
          'Expansion',
          'Technology',
          'Innovation',
          'Clean Energy',
          'Sustainability',
          'Grid',
          'Transmission',
          'Distribution'
        ];
      case PostCategory.productDesign:
        return [
          'Turbine',
          'Generator',
          'Transformer',
          'Insulator',
          'Smart Grid',
          'Technology',
          'Design',
          'Efficiency',
          'Reliability',
          'Automation',
          'Monitoring',
          'Control Systems',
          'Equipment',
          'Infrastructure'
        ];
    }
  }
}

/// Profile post model
class ProfilePost {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> imageUrls; // optional gallery
  final List<String> pdfUrls; // optional attachments
  final PostCategory category;
  final List<String> tags;
  final String author;
  final DateTime publishDate;
  final int likes;
  final int comments;

  ProfilePost({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    this.imageUrls = const [],
    this.pdfUrls = const [],
    required this.category,
    required this.tags,
    required this.author,
    required this.publishDate,
    required this.likes,
    required this.comments,
  });
}

/// Post category enum
enum PostCategory {
  update,
  productDesign,
}

extension PostCategoryExtension on PostCategory {
  String get displayName {
    switch (this) {
      case PostCategory.update:
        return 'Updates';
      case PostCategory.productDesign:
        return 'Product Designs';
    }
  }
}
