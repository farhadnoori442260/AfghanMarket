import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/forms/common_form.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/screens/category/product_by_category_screen.dart';
import 'package:kalino_app/services/auth.dart';

class SubCategoryScreen extends StatefulWidget {
  final DocumentSnapshot? doc;
  final bool? isForForm;
  static const String screenId = 'subcategory_screen';

  const SubCategoryScreen({Key? key, this.doc, this.isForForm})
      : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final Auth _authService = Auth();

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final String categoryName = widget.doc != null && widget.doc!.exists
        ? (widget.doc!['category_name'] ?? '')
        : 'title_subcategories'.tr();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 1,
        iconTheme: const IconThemeData(color: blackColor),
        backgroundColor: whiteColor,
        title: Text(
          categoryName,
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: _buildBody(categoryProvider),
    );
  }

  Widget _buildBody(CategoryProvider categoryProvider) {
    if (widget.doc == null) {
      return Center(
        child: Text('msg_no_subcategories'.tr()),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _authService.categories.doc(widget.doc!.id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('msg_error_loading'.tr()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: secondaryColor,
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('msg_no_subcategories'.tr()),
          );
        }

        final Map<String, dynamic>? dataMap =
            snapshot.data!.data() as Map<String, dynamic>?;

        final List<dynamic> subcategories =
            (dataMap != null && dataMap['subcategory'] != null)
                ? List<dynamic>.from(dataMap['subcategory'])
                : [];

        if (subcategories.isEmpty) {
          return Center(
            child: Text('msg_no_subcategories'.tr()),
          );
        }

        return ListView.separated(
          itemCount: subcategories.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final String subCategoryName = subcategories[index].toString();

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: () {
                categoryProvider.setSubCategory(subCategoryName);

                if (widget.isForForm == true) {
                  Navigator.pushNamed(context, CommonForm.screenId);
                } else {
                  Navigator.pushNamed(
                    context,
                    ProductByCategory.screenId,
                  );
                }
              },
              title: Text(
                subCategoryName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: greyColor,
              ),
            );
          },
        );
      },
    );
  }
}
