import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/provider/product_provider.dart';
import 'package:kalino_app/screens/chat/user_chat_screen.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class ProductDetail extends StatefulWidget {
  static const String screenId = 'product_details_screen';

  const ProductDetail({Key? key}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  GoogleMapController? _mapController;
  final Auth _authService = Auth();
  final UserService _firebaseUser = UserService();

  bool _loading = false;
  int _index = 0;
  bool _isLiked = false;
  List _fav = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productProvider = Provider.of<ProductProvider>(context);
    if (productProvider.productData != null) {
      _getFavourites(productProvider: productProvider);
    }
  }

  void _getFavourites({required ProductProvider productProvider}) {
    if (_firebaseUser.user == null) return;

    _authService.products
        .doc(productProvider.productData!.id)
        .get()
        .then((value) {
      if (mounted && value.exists) {
        final Map<String, dynamic>? data =
            value.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('favourites')) {
          setState(() {
            _fav = data['favourites'] ?? [];
            _isLiked = _fav.contains(_firebaseUser.user!.uid);
          });
        }
      }
    });
  }

  Future<void> _openMapLauncher(GeoPoint location) async {
    try {
      final availableMaps = await launcher.MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          coords: launcher.Coords(location.latitude, location.longitude),
          title: 'seller_location_title'.tr(),
        );
      }
    } catch (e) {
      if (mounted) {
        customSnackBar(context: context, content: 'msg_map_launch_error'.tr());
      }
    }
  }

  Future<void> _callLauncher(Uri number) async {
    if (!await launchUrl(number)) {
      if (mounted) {
        customSnackBar(context: context, content: 'msg_call_error'.tr());
      }
    }
  }

  void _createChatRoom(ProductProvider productProvider) {
    if (_firebaseUser.user == null) {
      customSnackBar(context: context, content: 'msg_login_required'.tr());
      return;
    }

    final productData = productProvider.productData!.data() as Map<String, dynamic>;
    final sellerDetails = productProvider.sellerDetails?.data() as Map<String, dynamic>?;

    if (sellerDetails == null) return;

    final Map<String, dynamic> product = {
      'product_id': productProvider.productData!.id,
      'product_img': (productData['images'] as List?)?.first ?? '',
      'price': productData['price'],
      'title': productData['title'],
      'seller': productData['seller_uid'],
    };

    final String sellerUid = sellerDetails['uid'] ?? productData['seller_uid'];
    final String currentUid = _firebaseUser.user!.uid;

    final List<String> users = [sellerUid, currentUid];
    final String chatroomId = '${sellerUid}.${currentUid}${productProvider.productData!.id}';

    final Map<String, dynamic> chatData = {
      'users': users,
      'chatroomId': chatroomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };

    _firebaseUser.createChatRoom(data: chatData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => UserChatScreen(
          chatroomId: chatroomId,
        ),
      ),
    );
  }

  Widget _buildBody({
    required DocumentSnapshot<Object?> data,
    required String formattedDate,
    required ProductProvider productProvider,
    required String formattedPrice,
    required GeoPoint? location,
    required NumberFormat numberFormat,
  }) {
    final Map<String, dynamic> productMap = data.data() as Map<String, dynamic>;
    final List images = productMap['images'] ?? [];
    final Map<String, dynamic>? sellerMap =
        productProvider.sellerDetails?.data() as Map<String, dynamic>?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بخش گالری تصاویر
          Container(
            width: double.infinity,
            height: 380,
            color: Colors.black12,
            child: images.isEmpty
                ? const Center(child: Icon(Icons.image_not_supported, size: 60))
                : Stack(
                    children: [
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: images[_index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: primaryColor),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: 65,
                            color: whiteColor.withOpacity(0.9),
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _index = index;
                                      });
                                    },
                                    child: Container(
                                      width: 70,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _index == index ? primaryColor : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: images[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان و سال ساخت
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        (productMap['title'] ?? '').toString().toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (productMap['year'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${productMap['year']}',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // قیمت آگهی
                Text(
                  '$formattedPrice ${'currency_afn'.tr()}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // جزییات مخصوص خودرو
                if (productMap['category'] == 'Cars' ||
                    productMap['category'] == 'خودروها' ||
                    productMap['category'] == 'موترونه')
                  Container(
                    decoration: BoxDecoration(
                      color: disabledColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSpecItem(
                              icon: Icons.local_gas_station_outlined,
                              label: productMap['fuel_type'] ?? '-',
                            ),
                            _buildSpecItem(
                              icon: Icons.speed_outlined,
                              label: productMap['km_driven'] != null
                                  ? '${numberFormat.format(int.tryParse(productMap['km_driven'].toString()) ?? 0)} ${'label_km'.tr()}'
                                  : '-',
                            ),
                            _buildSpecItem(
                              icon: Icons.settings_outlined,
                              label: productMap['transmission_type'] ?? '-',
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSpecItem(
                              icon: Icons.person_outline,
                              label: productMap['owners'] != null
                                  ? '${productMap['owners']} ${'label_owner'.tr()}'
                                  : '-',
                            ),
                            _buildSpecItem(
                              icon: Icons.location_on_outlined,
                              label: sellerMap?['address'] ?? 'label_unknown_location'.tr(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                Text(
                  'label_description'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  productMap['description'] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),

                // ویژگی‌های تکمیلی (برند، اتاق، فضا)
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (productMap['brand'] != null)
                        _buildDetailRow('label_brand'.tr(), productMap['brand']),
                      if (productMap['type'] != null)
                        _buildDetailRow('label_type'.tr(), productMap['type']),
                      if (productMap['bedroom'] != null)
                        _buildDetailRow('label_bedrooms'.tr(), productMap['bedroom'].toString()),
                      if (productMap['bathroom'] != null)
                        _buildDetailRow('label_bathrooms'.tr(), productMap['bathroom'].toString()),
                      if (productMap['furnishing'] != null)
                        _buildDetailRow('label_furnishing'.tr(), productMap['furnishing']),
                      _buildDetailRow('label_posted_at'.tr(), formattedDate),
                    ],
                  ),
                ),

                const Divider(height: 32),

                // اطلاعات فروشنده
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 30,
                      child: Icon(
                        CupertinoIcons.person_fill,
                        color: whiteColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (sellerMap?['name'] ?? 'label_seller'.tr()).toString().toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sellerMap?['address'] ?? 'label_unknown_location'.tr(),
                            style: const TextStyle(color: greyColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // نقشه موقعیت مکانی
                if (location != null) ...[
                  Text(
                    'label_ad_location'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              zoom: 14,
                              target: LatLng(location.latitude, location.longitude),
                            ),
                            mapType: MapType.normal,
                            zoomControlsEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                          ),
                          const Center(
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 38,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(20),
                              child: IconButton(
                                icon: const Icon(Icons.directions_outlined, color: primaryColor),
                                onPressed: () => _openMapLauncher(location),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'label_ad_id'.tr()}: ${productMap['posted_at'] ?? '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: greyColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        customSnackBar(
                          context: context,
                          content: 'msg_report_submitted'.tr(),
                        );
                      },
                      icon: const Icon(Icons.flag_outlined, size: 16, color: Colors.red),
                      label: Text(
                        'btn_report_ad'.tr(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpecItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: greyColor, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBottomSheet({required ProductProvider productProvider}) {
    final Map<String, dynamic>? productMap =
        productProvider.productData?.data() as Map<String, dynamic>?;
    final Map<String, dynamic>? sellerMap =
        productProvider.sellerDetails?.data() as Map<String, dynamic>?;

    final isOwner = _firebaseUser.user != null &&
        productMap?['seller_uid'] == _firebaseUser.user!.uid;

    if (isOwner) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _createChatRoom(productProvider),
              icon: const Icon(Icons.chat_bubble_outline, color: whiteColor, size: 18),
              label: Text('btn_chat'.tr(), style: const TextStyle(color: whiteColor, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final mobile = sellerMap?['mobile'];
                if (mobile != null) {
                  final phoneUri = Uri.parse('tel:$mobile');
                  await _callLauncher(phoneUri);
                } else {
                  customSnackBar(context: context, content: 'msg_no_phone'.tr());
                }
              },
              icon: const Icon(Icons.call_outlined, color: whiteColor, size: 18),
              label: Text('btn_call'.tr(), style: const TextStyle(color: whiteColor, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final numberFormat = NumberFormat('##,##,##0');

    final data = productProvider.productData;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text('title_product_details'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final Map<String, dynamic> productMap = data.data() as Map<String, dynamic>;
    final int price = int.tryParse(productMap['price']?.toString() ?? '0') ?? 0;
    final String formattedPrice = numberFormat.format(price);

    final int postedAt = productMap['posted_at'] ?? DateTime.now().microsecondsSinceEpoch;
    final DateTime date = DateTime.fromMicrosecondsSinceEpoch(postedAt);
    final String formattedDate = DateFormat.yMMMd().format(date);

    final Map<String, dynamic>? sellerMap =
        productProvider.sellerDetails?.data() as Map<String, dynamic>?;
    final GeoPoint? location = sellerMap?['location'] as GeoPoint?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: blackColor),
        title: Text(
          'title_product_details'.tr(),
          style: const TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: blackColor),
            onPressed: () {
              // اشتراک‌گذاری لینک یا مشخصات آگهی
            },
          ),
          IconButton(
            onPressed: () {
              if (_firebaseUser.user == null) {
                customSnackBar(context: context, content: 'msg_login_required'.tr());
                return;
              }
              setState(() {
                _isLiked = !_isLiked;
              });
              _firebaseUser.updateFavourite(
                context: context,
                isLiked: _isLiked,
                productId: data.id,
              );
            },
            color: _isLiked ? secondaryColor : disabledColor,
            icon: Icon(
              _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            ),
          )
        ],
      ),
      body: _buildBody(
        data: data,
        formattedDate: formattedDate,
        productProvider: productProvider,
        formattedPrice: formattedPrice,
        location: location,
        numberFormat: numberFormat,
      ),
      bottomSheet: _buildBottomSheet(productProvider: productProvider),
    );
  }
}
