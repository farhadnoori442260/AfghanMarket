import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kalino_app/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  DocumentSnapshot? productData;
  DocumentSnapshot? sellerDetails;
  ProductModel? parsedProduct;

  /// تنظیم جزییات محصول از طریق DocumentSnapshot
  void setProductDetails(DocumentSnapshot? details) {
    productData = details;
    if (details != null && details.exists) {
      parsedProduct = ProductModel.fromFirestore(details);
    } else {
      parsedProduct = null;
    }
    notifyListeners();
  }

  /// تنظیم جزییات محصول مستقیم از طریق ProductModel
  void setProductModel(ProductModel product) {
    parsedProduct = product;
    notifyListeners();
  }

  /// تنظیم جزییات فروشنده
  void setSellerDetails(DocumentSnapshot? details) {
    sellerDetails = details;
    notifyListeners();
  }

  /// دریافت قیمت فرمت‌شده با واحد پول برنامه (افغانی / AFN)
  String get formattedPrice {
    if (parsedProduct == null) return '';
    return '${parsedProduct!.price.toStringAsFixed(0)} ${'currency_afn'.tr()}';
  }

  /// دریافت نام یا کلید دسته‌بندی به‌صورت ترجمه‌شده
  String get localizedCategory {
    if (parsedProduct == null || parsedProduct!.category.isEmpty) return '';
    return parsedProduct!.category.tr();
  }

  /// پاک‌سازی داده‌های پرووایدر هنگام خروج از صفحه یا باز کردن آگهی جدید
  void clearProductDetails() {
    productData = null;
    sellerDetails = null;
    parsedProduct = null;
    notifyListeners();
  }
}
