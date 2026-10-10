import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/provider/product_provider.dart';
import 'package:kalino_app/screens/product/product_details_screen.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    required this.data,
    required this.formattedPrice,
    required this.numberFormat,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final String formattedPrice;
  final NumberFormat numberFormat;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final Auth _authService = Auth();
  final UserService _firebaseUser = UserService();

  String _address = '';
  DocumentSnapshot? _sellerDetails;
  bool _isLiked = false;
  List _fav = [];

  @override
  void initState() {
    super.initState();
    _getSellerData();
    _getFavourites();
  }

  void _getSellerData() {
    final Map<String, dynamic>? productMap =
        widget.data.data() as Map<String, dynamic>?;

    if (productMap != null && productMap.containsKey('seller_uid')) {
      _firebaseUser.getSellerData(productMap['seller_uid']).then((value) {
        if (mounted && value.exists) {
          final Map<String, dynamic>? sellerData =
              value.data() as Map<String, dynamic>?;
          setState(() {
            _address = sellerData?['address'] ?? '';
            _sellerDetails = value;
          });
        }
      });
    }
  }

  void _getFavourites() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _authService.products.doc(widget.data.id).get().then((value) {
      if (mounted && value.exists) {
        final Map<String, dynamic>? data =
            value.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('favourites')) {
          setState(() {
            _fav = data['favourites'] ?? [];
            _isLiked = _fav.contains(currentUser.uid);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final Map<String, dynamic> productData =
        widget.data.data() as Map<String, dynamic>;

    final List images = productData['images'] ?? [];
    final String imageUrl = images.isNotEmpty ? images[0] : '';
    final String title = productData['title'] ?? '';
    final String category = productData['category'] ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        productProvider.setSellerDetails(_sellerDetails);
        productProvider.setProductDetails(widget.data);
        Navigator.pushNamed(context, ProductDetail.screenId);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: greyColor,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported_outlined,
                              color: greyColor,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.formattedPrice} ${'currency_afn'.tr()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (category == 'Cars' || category == 'خودروها' || category == 'موترونه')
                    Text(
                      '${productData['year'] ?? ''} - ${widget.numberFormat.format(int.tryParse(productData['km_driven']?.toString() ?? '0') ?? 0)} ${'label_km'.tr()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: greyColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const SizedBox(height: 14),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: greyColor,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          _address.isNotEmpty ? _address : 'label_unknown_location'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: greyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                       content: Text('msg_login_required'.tr()),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                       ),
                      );
                      return;
                    }

                    setState(() {
                      _isLiked = !_isLiked;
                    });
                    _firebaseUser.updateFavourite(
                      context: context,
                      isLiked: _isLiked,
                      productId: widget.data.id,
                    );
                  },
                  color: _isLiked ? secondaryColor : disabledColor,
                  icon: Icon(
                    _isLiked
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
