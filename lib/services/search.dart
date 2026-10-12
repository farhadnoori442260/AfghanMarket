import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';

import 'package:kalino_app/components/product_listing_widget.dart';
import 'package:kalino_app/components/search_card.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/models/product_model.dart';
import 'package:kalino_app/provider/product_provider.dart';
import 'package:kalino_app/screens/product/product_details_screen.dart';

class Search {
  void searchQueryPage({
    required BuildContext context,
    required List<Products> products,
    required String address,
    DocumentSnapshot? sellerDetails,
    required ProductProvider provider,
  }) {
    showSearch(
      context: context,
      delegate: SearchPage<Products>(
        barTheme: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: whiteColor,
            elevation: 0.5,
            surfaceTintColor: whiteColor,
            iconTheme: IconThemeData(color: blackColor),
            actionsIconTheme: IconThemeData(color: blackColor),
            titleSpacing: 0,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(
              color: greyColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              color: blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        searchLabel: 'search_hint'.tr(),
        suggestion: const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: ProductListing(),
          ),
        ),
        failure: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_product_found'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: greyColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        items: products,
        filter: (product) => [
          product.title,
          product.description,
          product.category,
          product.subcategory,
        ],
        builder: (product) {
          return InkWell(
            onTap: () {
              provider.setProductDetails(product.document);
              if (sellerDetails != null) {
                provider.setSellerDetails(sellerDetails);
              }
              Navigator.pushNamed(context, ProductDetail.screenId);
            },
            child: SearchCard(
              product: product,
              address: address,
            ),
          );
        },
      ),
    );
  }
}
