import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// تبدیل DocumentSnapshot از فایربیس به مدل Dart
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      price: _parsePrice(data['price']),
      images: List<String>.from(data['images'] ?? []),
      sellerId: data['seller_id'] ?? data['uid'],
      contactDetails: data['contact_details'] as Map<String, dynamic>?,
      location: data['location'] as Map<String, dynamic>?,
      postDate: (data['posted_at'] as Timestamp?)?.toDate() ??
          (data['postDate'] is int
              ? DateTime.fromMillisecondsSinceEpoch(data['postDate'])
              : null),
      isApproved: data['is_approved'] ?? true,
    );
  }

  /// تبدیل مدل به Map برای ارسال و ذخیره در Firestore
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
      'posted_at': postDate != null ? Timestamp.fromDate(postDate!) : FieldValue.serverTimestamp(),
      'is_approved': isApproved,
    };
  }

  /// متد کمکی برای تبدیل امن قیمت از انواع داده‌ای مختلف به double
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
