import 'package:cloud_firestore/cloud_firestore.dart';

class Products {
  final DocumentSnapshot document;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final dynamic price;
  final dynamic postDate;

  const Products({
    required this.document,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.price,
    this.postDate,
  });
}

class ProductModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final double price;
  final List<String> images;
  final String? sellerId;
  final Map<String, dynamic>? contactDetails;
  final Map<String, dynamic>? location;
  final DateTime? postDate;
  final bool isApproved;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.price,
    this.images = const [],
    this.sellerId,
    this.contactDetails,
    this.location,
    this.postDate,
    this.isApproved = true,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProductModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      subcategory: data['subcategory']?.toString(),
      price: _parsePrice(data['price']),
      images: List<String>.from(data['images'] ?? const []),
      sellerId: (data['seller_id'] ?? data['seller_uid'] ?? data['uid'])
          ?.toString(),
      contactDetails: data['contact_details'] is Map
          ? Map<String, dynamic>.from(data['contact_details'])
          : null,
      location: data['location'] is Map
          ? Map<String, dynamic>.from(data['location'])
          : null,
      postDate: (data['posted_at'] as Timestamp?)?.toDate() ??
          (data['postDate'] is int
              ? DateTime.fromMillisecondsSinceEpoch(data['postDate'] as int)
              : null),
      isApproved: data['is_approved'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'images': images,
      'seller_id': sellerId,
      'contact_details': contactDetails,
      'location': location,
      'posted_at':
          postDate == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(postDate!),
      'is_approved': isApproved,
    };
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
