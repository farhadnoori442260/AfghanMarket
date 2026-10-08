import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/screens/product/product_card.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class MyPostScreen extends StatefulWidget {
  static const String screenId = 'my_post_screen';

  const MyPostScreen({Key? key}) : super(key: key);

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  final Auth _authService = Auth();
  final UserService _firebaseUser = UserService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 1,
          iconTheme: const IconThemeData(color: blackColor),
          title: Text(
            'title_my_posts'.tr(),
            style: const TextStyle(
              color: blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            indicatorColor: secondaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: greyColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: 'tab_my_posts'.tr(),
              ),
              Tab(
                text: 'tab_favourites'.tr(),
              ),
            ],
          ),
        ),
        body: _firebaseUser.user == null
            ? Center(
                child: Text(
                  'msg_login_required'.tr(),
                  style: const TextStyle(color: blackColor, fontSize: 16),
                ),
              )
            : BodyWidget(
                authService: _authService,
                firebaseUser: _firebaseUser,
              ),
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  final Auth authService;
  final UserService firebaseUser;

  const BodyWidget({
    Key? key,
    required this.authService,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('##,##,##0');
    final String currentUid = firebaseUser.user!.uid;

    return TabBarView(
      children: [
        // تب اول: آگهی‌های من
        StreamBuilder<QuerySnapshot>(
          stream: authService.products
              .where('seller_uid', isEqualTo: currentUid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('msg_error_loading'.tr()));
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.post_add_outlined, size: 64, color: greyColor),
                    const SizedBox(height: 12),
                    Text(
                      'msg_no_my_posts'.tr(),
                      style: const TextStyle(color: greyColor, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return _buildProductGrid(snapshot.data!.docs, numberFormat);
          },
        ),

        // تب دوم: نشان‌شده‌ها (علاقه‌مندی‌ها)
        StreamBuilder<QuerySnapshot>(
          stream: authService.products
              .where('favourites', arrayContains: currentUid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('msg_error_loading'.tr()));
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border_outlined, size: 64, color: greyColor),
                    const SizedBox(height: 12),
                    Text(
                      'msg_no_favourites'.tr(),
                      style: const TextStyle(color: greyColor, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return _buildProductGrid(snapshot.data!.docs, numberFormat);
          },
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<QueryDocumentSnapshot> docs, NumberFormat numberFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: docs.length,
        itemBuilder: (BuildContext context, int index) {
          var data = docs[index];
          var productMap = data.data() as Map<String, dynamic>;
          
          int price = int.tryParse(productMap['price']?.toString() ?? '0') ?? 0;
          String formattedPrice = numberFormat.format(price);

          return ProductCard(
            data: data,
            formattedPrice: formattedPrice,
            numberFormat: numberFormat,
          );
        },
      ),
    );
  }
}
