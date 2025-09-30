// Data models for State Electricity Board Information System
// Based on the React prototype documentation

import 'media_models.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String time;
  final List<String> tags;
  final String? imageUrl; // Legacy field - will be migrated to media
  final List<String> imageUrls; // Legacy field - will be migrated to media
  final List<String> pdfUrls; // Legacy field - will be migrated to media
  final List<MediaItem> media; // New unified media system

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.time,
    this.tags = const [],
    this.imageUrl,
    this.imageUrls = const [],
    this.pdfUrls = const [],
    this.media = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'author': author,
        'time': time,
        'tags': tags,
        'imageUrl': imageUrl,
        'imageUrls': imageUrls,
        'pdfUrls': pdfUrls,
        'media': media.map((m) => m.toJson()).toList(),
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        author: json['author'] as String,
        time: json['time'] as String,
        tags: List<String>.from(json['tags'] as List? ?? []),
        imageUrl: json['imageUrl'] as String?,
        imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
        pdfUrls: List<String>.from(json['pdfUrls'] as List? ?? []),
        media: (json['media'] as List? ?? [])
            .map((m) => MediaItem.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  /// Get all media items, including legacy URLs converted to media items
  List<MediaItem> getAllMedia() {
    final List<MediaItem> allMedia = List.from(media);

    // If no new media items exist, convert legacy URLs to media items
    if (allMedia.isEmpty) {
      allMedia.addAll(MediaAdapter.fromLegacyPost(
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        pdfUrls: pdfUrls,
        postId: id,
      ));
    }

    return allMedia;
  }

  /// Get cover image from media items
  MediaItem? getCoverImage() {
    final allMedia = getAllMedia();
    final coverImage = allMedia
        .where((m) => m.type == MediaType.image && m.isCover)
        .firstOrNull;
    if (coverImage != null) return coverImage;

    // Fallback to first image if no cover is set
    return allMedia.where((m) => m.type == MediaType.image).firstOrNull;
  }

  /// Get all images from media items
  List<MediaItem> getImages() {
    return getAllMedia().where((m) => m.type == MediaType.image).toList();
  }

  /// Get all PDFs from media items
  List<MediaItem> getPdfs() {
    return getAllMedia().where((m) => m.type == MediaType.pdf).toList();
  }
}

class PowerGenerator {
  final String id;
  final String name;
  final String type; // "Thermal", "Hydro", "Nuclear"
  final String capacity; // "65,810 MW"
  final String location;
  final String logo;
  final String established;
  final String founder;
  final String ceo;
  final String ceoPhoto;
  final String headquarters;
  final String phone;
  final String email;
  final String website;
  final String description;
  final int totalPlants;
  final String employees;
  final String revenue;
  final List<Post> posts;
  final List<ProductDesign> productDesigns;

  const PowerGenerator({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.location,
    required this.logo,
    required this.established,
    required this.founder,
    required this.ceo,
    required this.ceoPhoto,
    required this.headquarters,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.totalPlants,
    required this.employees,
    required this.revenue,
    required this.posts,
    this.productDesigns = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'capacity': capacity,
        'location': location,
        'logo': logo,
        'established': established,
        'founder': founder,
        'ceo': ceo,
        'ceoPhoto': ceoPhoto,
        'headquarters': headquarters,
        'phone': phone,
        'email': email,
        'website': website,
        'description': description,
        'totalPlants': totalPlants,
        'employees': employees,
        'revenue': revenue,
        'posts': posts.map((p) => p.toJson()).toList(),
        'productDesigns': productDesigns.map((p) => p.toJson()).toList(),
      };

  factory PowerGenerator.fromJson(Map<String, dynamic> json) => PowerGenerator(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        capacity: json['capacity'] as String? ?? '',
        location: json['location'] as String? ?? '',
        logo: json['logo'] as String? ?? '',
        established: json['established'] as String? ?? '',
        founder: json['founder'] as String? ?? '',
        ceo: json['ceo'] as String? ?? '',
        ceoPhoto: json['ceoPhoto'] as String? ?? '',
        headquarters: json['headquarters'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        website: json['website'] as String? ?? '',
        description: json['description'] as String? ?? '',
        totalPlants: json['totalPlants'] as int? ?? 0,
        employees: json['employees'] as String? ?? '',
        revenue: json['revenue'] as String? ?? '',
        posts: (json['posts'] as List<dynamic>?)
                ?.map((p) => Post.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        productDesigns: (json['productDesigns'] as List<dynamic>?)
                ?.map((p) => ProductDesign.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class TransmissionLine {
  final String id;
  final String name;
  final String voltage; // "765 kV"
  final String coverage; // "National"
  final String headquarters;
  final String logo;
  final String established;
  final String founder;
  final String ceo;
  final String ceoPhoto;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String description;
  final int totalSubstations;
  final String employees;
  final String revenue;
  final List<Post> posts;
  final List<ProductDesign> productDesigns;

  const TransmissionLine({
    required this.id,
    required this.name,
    required this.voltage,
    required this.coverage,
    required this.headquarters,
    required this.logo,
    required this.established,
    required this.founder,
    required this.ceo,
    required this.ceoPhoto,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.totalSubstations,
    required this.employees,
    required this.revenue,
    required this.posts,
    this.productDesigns = const [],
  });
}

class DistributionCompany {
  final String id;
  final String name;
  final String logo;
  final String established;
  final String director;
  final String directorPhoto;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String coverage;
  final String customers;
  final String capacity;
  final String description;
  final List<Post> posts;
  final List<ProductDesign> productDesigns;

  const DistributionCompany({
    required this.id,
    required this.name,
    required this.logo,
    required this.established,
    required this.director,
    required this.directorPhoto,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.coverage,
    required this.customers,
    required this.capacity,
    required this.description,
    required this.posts,
    this.productDesigns = const [],
  });
}

class Mandal {
  final String id;
  final String name;
  final String population;
  final String powerDemand;
  final String? administrator;
  final String? divisionController;
  final String? controllerPhoto;
  final String? officeAddress;
  final String? phone;
  final String? email;
  final String? website;
  final String? helpline;
  final List<String>? discoms;
  final List<Post>? posts;

  const Mandal({
    required this.id,
    required this.name,
    required this.population,
    required this.powerDemand,
    this.administrator,
    this.divisionController,
    this.controllerPhoto,
    this.officeAddress,
    this.phone,
    this.email,
    this.website,
    this.helpline,
    this.discoms,
    this.posts,
  });
}

class EnergyMix {
  final int thermal;
  final int hydro;
  final int nuclear;
  final int renewable;

  const EnergyMix({
    required this.thermal,
    required this.hydro,
    required this.nuclear,
    required this.renewable,
  });
}

class IndianState {
  final String id;
  final String name;
  final String capital;
  final String powerCapacity;
  final int discoms;
  final String logo;
  final String address;
  final String website;
  final String email;
  final String helpline;
  final String chiefMinister;
  final String chiefMinisterPhoto;
  final String energyMinister;
  final String energyMinisterPhoto;
  final EnergyMix energyMix;
  final List<String> discomsList;
  final List<Post> posts;
  final List<Mandal> mandals;
  final List<ProductDesign> productDesigns;

  const IndianState({
    required this.id,
    required this.name,
    required this.capital,
    required this.powerCapacity,
    required this.discoms,
    required this.logo,
    required this.address,
    required this.website,
    required this.email,
    required this.helpline,
    required this.chiefMinister,
    required this.chiefMinisterPhoto,
    required this.energyMinister,
    required this.energyMinisterPhoto,
    required this.energyMix,
    required this.discomsList,
    required this.posts,
    required this.mandals,
    this.productDesigns = const [],
  });
}

// Product Design Models
class ProductDesign {
  final String id;
  final String title;
  final String description;
  final String
      category; // "Conductor", "Transmission Line", "Distribution Equipment", etc.
  final String stateId; // Which state this design applies to
  final String sectorId; // Which sector (generator, transmission, distribution)
  final String sectorType; // "generator", "transmission", "distribution"
  final String author;
  final String uploadDate;
  final List<String> tags;
  final List<ProductDesignFile>
      files; // Legacy field - will be migrated to media
  final String? thumbnailUrl; // Legacy field - will be migrated to media
  final List<MediaItem> media; // New unified media system
  final bool isActive;
  final String? guidelines; // State-specific guidelines
  final String? specifications; // Technical specifications

  const ProductDesign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.stateId,
    required this.sectorId,
    required this.sectorType,
    required this.author,
    required this.uploadDate,
    this.tags = const [],
    this.files = const [],
    this.thumbnailUrl,
    this.media = const [],
    this.isActive = true,
    this.guidelines,
    this.specifications,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'stateId': stateId,
        'sectorId': sectorId,
        'sectorType': sectorType,
        'author': author,
        'uploadDate': uploadDate,
        'tags': tags,
        'files': files.map((f) => f.toJson()).toList(),
        'thumbnailUrl': thumbnailUrl,
        'media': media.map((m) => m.toJson()).toList(),
        'isActive': isActive,
        'guidelines': guidelines,
        'specifications': specifications,
      };

  factory ProductDesign.fromJson(Map<String, dynamic> json) => ProductDesign(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        stateId: json['stateId'] as String,
        sectorId: json['sectorId'] as String,
        sectorType: json['sectorType'] as String,
        author: json['author'] as String,
        uploadDate: json['uploadDate'] as String,
        tags: List<String>.from(json['tags'] as List? ?? []),
        files: (json['files'] as List? ?? [])
            .map((f) => ProductDesignFile.fromJson(f as Map<String, dynamic>))
            .toList(),
        thumbnailUrl: json['thumbnailUrl'] as String?,
        media: (json['media'] as List? ?? [])
            .map((m) => MediaItem.fromJson(m as Map<String, dynamic>))
            .toList(),
        isActive: json['isActive'] as bool? ?? true,
        guidelines: json['guidelines'] as String?,
        specifications: json['specifications'] as String?,
      );

  /// Get all media items, including legacy files converted to media items
  List<MediaItem> getAllMedia() {
    final List<MediaItem> allMedia = List.from(media);

    // If no new media items exist, convert legacy files to media items
    if (allMedia.isEmpty) {
      allMedia.addAll(MediaAdapter.fromLegacyProductDesign(
        files: files,
        designId: id,
      ));
    }

    return allMedia;
  }

  /// Get cover image from media items
  MediaItem? getCoverImage() {
    final allMedia = getAllMedia();
    final coverImage = allMedia
        .where((m) => m.type == MediaType.image && m.isCover)
        .firstOrNull;
    if (coverImage != null) return coverImage;

    // Fallback to first image if no cover is set
    return allMedia.where((m) => m.type == MediaType.image).firstOrNull;
  }

  /// Get all images from media items
  List<MediaItem> getImages() {
    return getAllMedia().where((m) => m.type == MediaType.image).toList();
  }

  /// Get all PDFs from media items
  List<MediaItem> getPdfs() {
    return getAllMedia().where((m) => m.type == MediaType.pdf).toList();
  }
}

class ProductDesignFile {
  final String id;
  final String fileName;
  final String fileType; // "image", "pdf"
  final String fileUrl;
  final int fileSize; // in bytes
  final String uploadDate;
  final bool isThumbnail;

  const ProductDesignFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadDate,
    this.isThumbnail = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'uploadDate': uploadDate,
        'isThumbnail': isThumbnail,
      };

  factory ProductDesignFile.fromJson(Map<String, dynamic> json) =>
      ProductDesignFile(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        fileType: json['fileType'] as String,
        fileUrl: json['fileUrl'] as String,
        fileSize: json['fileSize'] as int,
        uploadDate: json['uploadDate'] as String,
        isThumbnail: json['isThumbnail'] as bool? ?? false,
      );
}

class ProductDesignFilter {
  final String id;
  final String name;
  final String category;
  final List<String> tags;
  final bool isActive;

  const ProductDesignFilter({
    required this.id,
    required this.name,
    required this.category,
    this.tags = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'tags': tags,
        'isActive': isActive,
      };

  factory ProductDesignFilter.fromJson(Map<String, dynamic> json) =>
      ProductDesignFilter(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        tags: List<String>.from(json['tags'] as List? ?? []),
        isActive: json['isActive'] as bool? ?? true,
      );
}

// Navigation and State Management
enum MainPath { selection, powerFlow, stateFlow }

enum PowerFlowStep {
  generator,
  transmission,
  distribution,
  profile,
  generatorProfile,
  transmissionProfile
}

enum StateFlowStep { states, stateDetail, mandalDetail }
