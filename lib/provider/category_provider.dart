import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kalino_app/services/user.dart';

class CategoryProvider with ChangeNotifier {
  final UserService _firebaseUser = UserService();

  DocumentSnapshot? doc;
  DocumentSnapshot<Map<String, dynamic>>? userDetails;

  /// کلید کل دسته‌بندی (مثلاً: 'cat_electronics')
  String? selectedCategoryKey;
  
  /// کلید زیردسته‌بندی (مثلاً: 'sub_mobiles')
  String? selectedSubCategoryKey;

  List<String> imageUploadedUrls = [];
  Map<String, dynamic> formData = {};

  /// دریافت نام دسته‌بندی اصلی به زبان فعلی اپلیکیشن
  String get categoryLocalizedName {
    if (selectedCategoryKey == null) return '';
    return selectedCategoryKey!.tr();
  }

  /// دریافت نام زیردسته‌بندی به زبان فعلی اپلیکیشن
  String get subCategoryLocalizedName {
    if (selectedSubCategoryKey == null) return '';
    return selectedSubCategoryKey!.tr();
  }

  /// تنظیم دسته‌بندی اصلی (کلید ترجمه ذخیره می‌شود)
  void setCategory(String categoryKey) {
    selectedCategoryKey = categoryKey;
    formData['category'] = categoryKey;
    notifyListeners();
  }

  /// تنظیم زیردسته‌بندی (کلید ترجمه ذخیره می‌شود)
  void setSubCategory(String subCategoryKey) {
    selectedSubCategoryKey = subCategoryKey;
    formData['subcategory'] = subCategoryKey;
    notifyListeners();
  }

  /// ذخیره اسنپ‌شات دسته‌بندی
  void setCategorySnapshot(DocumentSnapshot snapshot) {
    doc = snapshot;
    notifyListeners();
  }

  /// افزودن لینک تصویر به لیست
  void setImageList(String url) {
    imageUploadedUrls.add(url);
    formData['images'] = imageUploadedUrls;
    notifyListeners();
  }

  /// حذف تصویر از لیست
  void removeImage(String url) {
    imageUploadedUrls.remove(url);
    formData['images'] = imageUploadedUrls;
    notifyListeners();
  }

  /// مقداردهی یا آپدیت داده‌های فرم
  void setFormData(Map<String, dynamic> data) {
    formData.addAll(data);
    if (selectedCategoryKey != null) formData['category'] = selectedCategoryKey;
    if (selectedSubCategoryKey != null) formData['subcategory'] = selectedSubCategoryKey;
    formData['images'] = imageUploadedUrls;
    notifyListeners();
  }

  /// دریافت اطلاعات کاربر از فایربیس
  Future<void> getUserDetail() async {
    try {
      final value = await _firebaseUser.getUserData();
      if (value != null) {
        userDetails = value as DocumentSnapshot<Map<String, dynamic>>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting user details in CategoryProvider: $e');
    }
  }

  /// پاکسازی کامل فرم (بعد از ثبت موفقیت‌آمیز آگهی)
  void clearData() {
    selectedCategoryKey = null;
    selectedSubCategoryKey = null;
    imageUploadedUrls = [];
    formData = {};
    doc = null;
    notifyListeners();
  }
}
