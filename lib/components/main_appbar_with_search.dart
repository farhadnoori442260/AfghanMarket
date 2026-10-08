import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/models/product_model.dart';
import 'package:kalino_app/provider/product_provider.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/search.dart';
import 'package:kalino_app/services/user.dart';

class MainAppBarWithSearch extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const MainAppBarWithSearch({
    required this.controller,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<MainAppBarWithSearch> createState() => _MainAppBarWithSearchState();
}

class _MainAppBarWithSearchState extends State<MainAppBarWithSearch> {
  final List<Products> _products = [];
  final Auth _authService = Auth();
  final Search _searchService = Search();
  final UserService _firebaseUser = UserService();

  String _address = '';
  DocumentSnapshot? _sellerDetails;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    _authService.products.get().then((QuerySnapshot snapshot) {
      if (!mounted) return;
      _products.clear();
      for (var doc in snapshot.docs) {
        _products.add(
          Products(
            document: doc,
            title: doc['title'],
            description: doc['description'],
            category: doc['category'],
            subcategory: doc['subcategory'],
            price: doc['price'],
            postDate: doc['posted_at'],
          ),
        );
        _getSellerAddress(doc['seller_uid']);
      }
    });
  }

  void _getSellerAddress(String sellerId) {
    _firebaseUser.getSellerData(sellerId).then((value) {
      if (mounted && value != null) {
        setState(() {
          _address = value['address'] ?? '';
          _sellerDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.03),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // لوگوی برند کالینو
                Text(
                  'app_name'.tr(),
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                // نشانگر موقعیت مکان / شهر
                if (_address.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: greyColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _address,
                        style: const TextStyle(
                          color: greyColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // نوار جستجوی شکیل و مدرن
            InkWell(
              onTap: () {
                _searchService.searchQueryPage(
                  context: context,
                  products: _products,
                  address: _address,
                  sellerDetails: _sellerDetails,
                  provider: productProvider,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: scaffoldBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greyLightColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: greyMediumColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'hint_search_placeholder'.tr(),
                        style: const TextStyle(
                          color: greyMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
