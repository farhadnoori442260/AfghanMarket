import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/provider/product_provider.dart';
import 'package:kalino_app/screens/product/product_card.dart';
import 'package:kalino_app/services/auth.dart';

class ProductListing extends StatefulWidget {
  final bool? isProductByCategory;

  const ProductListing({Key? key, this.isProductByCategory}) : super(key: key);

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  final Auth _authService = Auth();

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    final numberFormat = NumberFormat('##,##,##0');

    Query query = _authService.products.orderBy('posted_at', descending: true);

    if (widget.isProductByCategory == true) {
      if (categoryProvider.selectedCategory == 'Cars') {
        query = _authService.products
            .where('category', isEqualTo: categoryProvider.selectedCategory)
            .orderBy('posted_at', descending: true);
      } else {
        query = _authService.products
            .where('category', isEqualTo: categoryProvider.selectedCategory)
            .where('subcategory',
                isEqualTo: categoryProvider.selectedSubCategory)
            .orderBy('posted_at', descending: true);
      }
    }

    return FutureBuilder<QuerySnapshot>(
      future: query.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'msg_error_loading_products'.tr(),
                style: const TextStyle(color: errorColor, fontSize: 14),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.square_stack_3d_up_slash,
                  size: 64,
                  color: disabledColor.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'msg_no_products_found'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: greyMediumColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isProductByCategory == null) ...[
                Text(
                  'title_recommendations'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: snapshot.data!.size,
                itemBuilder: (BuildContext context, int index) {
                  var data = snapshot.data!.docs[index];
                  var priceRaw = data['price'];
                  int price = 0;

                  if (priceRaw is int) {
                    price = priceRaw;
                  } else if (priceRaw is String) {
                    price = int.tryParse(priceRaw) ?? 0;
                  }

                  String formattedPrice = numberFormat.format(price);

                  return ProductCard(
                    data: data,
                    formattedPrice: formattedPrice,
                    numberFormat: numberFormat,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
