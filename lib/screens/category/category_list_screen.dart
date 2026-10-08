import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/forms/sell_car_form.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/screens/category/product_by_category_screen.dart';
import 'package:kalino_app/screens/category/subcategory_screen.dart';
import 'package:kalino_app/services/auth.dart';

class CategoryListScreen extends StatelessWidget {
  static const String screenId = 'category_list_screen';
  final bool? isForForm;

  const CategoryListScreen({Key? key, this.isForForm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: blackColor),
        title: Text(
          isForForm == true ? 'title_select_category'.tr() : 'title_categories'.tr(),
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(context, categoryProvider),
    );
  }

  Widget _buildBody(BuildContext context, CategoryProvider categoryProvider) {
    final Auth authService = Auth();

    return FutureBuilder<QuerySnapshot>(
      future: authService.categories.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('msg_no_categories'.tr()),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final String categoryName = data['category_name'] ?? '';
            final String imgUrl = data['img'] ?? '';
            final dynamic subcategory = data['subcategory'];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () {
                categoryProvider.setCategory(categoryName);
                categoryProvider.setCategorySnapshot(doc);

                if (isForForm == true) {
                  if (subcategory == null) {
                    Navigator.of(context).pushNamed(SellCarForm.screenId);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => SubCategoryScreen(
                          doc: doc,
                          isForForm: true,
                        ),
                      ),
                    );
                  }
                } else {
                  if (subcategory == null) {
                    Navigator.of(context).pushNamed(ProductByCategory.screenId);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => SubCategoryScreen(
                          doc: doc,
                        ),
                      ),
                    );
                  }
                }
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 45,
                  height: 45,
                  color: Colors.grey.shade100,
                  child: imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.category_outlined,
                            color: greyColor,
                          ),
                        )
                      : const Icon(Icons.category_outlined, color: greyColor),
                ),
              ),
              title: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                ),
              ),
              trailing: subcategory != null
                  ? const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: greyColor,
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
