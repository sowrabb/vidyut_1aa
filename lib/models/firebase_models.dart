import 'package:cloud_firestore/cloud_firestore.dart';

// User Model
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoURL;
  final String role; // 'buyer', 'seller', 'admin'
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? sellerProfile;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoURL,
    required this.role,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.sellerProfile,
    this.preferences,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      role: data['role'] ?? 'buyer',
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      sellerProfile: data['sellerProfile'],
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'sellerProfile': sellerProfile,
      'preferences': preferences,
    };
  }
}

// Product Model
class ProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String brand;
  final String category;
  final String subtitle;
  final String description;
  final List<String> images;
  final double price;
  final int moq; // Minimum Order Quantity
  final double gstRate;
  final List<String> materials;
  final Map<String, dynamic> customValues;
  final String status; // 'active', 'draft', 'archived'
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int viewCount;
  final int contactCount;
  final GeoPoint? location;
  final String? city;
  final String? state;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.brand,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.images,
    required this.price,
    required this.moq,
    required this.gstRate,
    required this.materials,
    required this.customValues,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.viewCount = 0,
    this.contactCount = 0,
    this.location,
    this.city,
    this.state,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      title: data['title'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      moq: data['moq'] ?? 1,
      gstRate: (data['gstRate'] ?? 18).toDouble(),
      materials: List<String>.from(data['materials'] ?? []),
      customValues: Map<String, dynamic>.from(data['customValues'] ?? {}),
      status: data['status'] ?? 'draft',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      rating: (data['rating'] ?? 0).toDouble(),
      viewCount: data['viewCount'] ?? 0,
      contactCount: data['contactCount'] ?? 0,
      location: data['location'] as GeoPoint?,
      city: data['city'],
      state: data['state'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'title': title,
      'brand': brand,
      'category': category,
      'subtitle': subtitle,
      'description': description,
      'images': images,
      'price': price,
      'moq': moq,
      'gstRate': gstRate,
      'materials': materials,
      'customValues': customValues,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating,
      'viewCount': viewCount,
      'contactCount': contactCount,
      'location': location,
      'city': city,
      'state': state,
    };
  }
}

// Conversation Model
class ConversationModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String title;
  final String? subtitle;
  final bool isSupport;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.title,
    this.subtitle,
    this.isSupport = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      productId: data['productId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      isSupport: data['isSupport'] ?? false,
      isPinned: data['isPinned'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'title': title,
      'subtitle': subtitle,
      'isSupport': isSupport,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'unreadCount': unreadCount,
    };
  }
}

// Message Model
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // 'buyer', 'seller', 'support'
  final String senderName;
  final String text;
  final List<Map<String, dynamic>> attachments;
  final String? replyToMessageId;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    required this.text,
    required this.attachments,
    this.replyToMessageId,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      attachments: List<Map<String, dynamic>>.from(data['attachments'] ?? []),
      replyToMessageId: data['replyToMessageId'],
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderType': senderType,
      'senderName': senderName,
      'text': text,
      'attachments': attachments,
      'replyToMessageId': replyToMessageId,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }
}

// Lead Model
class LeadModel {
  final String id;
  final String buyerId;
  final String title;
  final String industry;
  final List<String> materials;
  final String city;
  final String state;
  final int qty;
  final double turnoverCr;
  final DateTime needBy;
  final String status; // 'new', 'quoted', 'won', 'lost'
  final String about;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> interestedSellers;

  LeadModel({
    required this.id,
    required this.buyerId,
    required this.title,
    required this.industry,
    required this.materials,
    required this.city,
    required this.state,
    required this.qty,
    required this.turnoverCr,
    required this.needBy,
    required this.status,
    required this.about,
    required this.createdAt,
    required this.updatedAt,
    required this.interestedSellers,
  });

  factory LeadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeadModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      title: data['title'] ?? '',
      industry: data['industry'] ?? '',
      materials: List<String>.from(data['materials'] ?? []),
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      qty: data['qty'] ?? 0,
      turnoverCr: (data['turnoverCr'] ?? 0).toDouble(),
      needBy: (data['needBy'] as Timestamp).toDate(),
      status: data['status'] ?? 'new',
      about: data['about'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      interestedSellers: List<String>.from(data['interestedSellers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'buyerId': buyerId,
      'title': title,
      'industry': industry,
      'materials': materials,
      'city': city,
      'state': state,
      'qty': qty,
      'turnoverCr': turnoverCr,
      'needBy': Timestamp.fromDate(needBy),
      'status': status,
      'about': about,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'interestedSellers': interestedSellers,
    };
  }
}
