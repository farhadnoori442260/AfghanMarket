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
            elevation: 0,
            surfaceTintColor: primaryColor,
            iconTheme: IconThemeData(color: blackColor),
            actionsIconTheme: IconThemeData(color: blackColor),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: greyColor,
              fontSize: 14,
            ),
            border: InputBorder.none,
          ),
        ),
        searchLabel: 'search_hint'.tr(),
        suggestion: const SingleChildScrollView(
          child: ProductListing(),
        ),
        failure: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'no_product_found'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: greyColor,
                fontSize: 16,
              ),
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
