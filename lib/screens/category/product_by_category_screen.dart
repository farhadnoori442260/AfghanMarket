import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/components/product_listing_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/provider/category_provider.dart';

class ProductByCategory extends StatelessWidget {
  static const String screenId = 'product_by_category';

  const ProductByCategory({Key? key}) : super(key: key);

  String _buildTitle(CategoryProvider categoryProvider) {
    final category = categoryProvider.selectedCategory;
    final subCategory = categoryProvider.selectedSubCategory;

    if (category == null || category.isEmpty) {
      return 'title_products'.tr();
    }

    if (subCategory == null || subCategory.isEmpty) {
      return category;
    }

    return '$category > $subCategory';
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(
          color: blackColor,
        ),
        title: Text(
          _buildTitle(categoryProvider),
          style: const TextStyle(
            color: blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const ProductListing(
        isProductByCategory: true,
      ),
    );
  }
}
