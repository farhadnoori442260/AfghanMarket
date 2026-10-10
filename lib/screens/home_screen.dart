import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/components/main_appbar_with_search.dart';
import 'package:kalino_app/components/product_listing_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/screens/category/category_widget.dart';
import 'package:kalino_app/screens/location_screen.dart';
import 'package:kalino_app/utils.dart';

class HomeScreen extends StatefulWidget {
  static const String screenId = 'home_screen';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;
  late CarouselSliderController _carouselController;
  late FocusNode _searchNode;

  Future<List<String>> _downloadBannerImageUrlList() async {
    List<String> bannerUrlList = [];
    try {
      final ListResult storageRef =
          await FirebaseStorage.instance.ref().child('banner').listAll();
      List<Reference> bannerRef = storageRef.items;
      await Future.forEach<Reference>(bannerRef, (image) async {
        final String fileUrl = await image.getDownloadURL();
        bannerUrlList.add(fileUrl);
      });
    } catch (e) {
      debugPrint('Error fetching banner images: $e');
    }
    return bannerUrlList;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchNode = FocusNode();
    _carouselController = CarouselSliderController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: MainAppBarWithSearch(
          controller: _searchController,
          focusNode: _searchNode,
        ),
      ),
      body: _homeBodyWidget(),
    );
  }

  Widget _locationAutoFetchBar(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LocationTextWidget(location: 'label_select_location'.tr());
    }

    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return LocationTextWidget(location: 'err_something_went_wrong'.tr());
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return LocationTextWidget(location: 'label_address_not_selected'.tr());
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          Map<String, dynamic>? data =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return LocationTextWidget(location: 'label_select_location'.tr());
          }

          if (data['address'] != null &&
              data['address'].toString().trim().isNotEmpty) {
            return LocationTextWidget(location: data['address'].toString());
          } else if (data['location'] != null) {
            Position position = data['location'];
            return FutureBuilder<String?>(
              future: getFetchedAddress(context, position),
              builder: (context, locationSnapshot) {
                if (locationSnapshot.hasData) {
                  return LocationTextWidget(location: locationSnapshot.data!);
                }
                return LocationTextWidget(location: 'msg_fetching_location'.tr());
              },
            );
          }
          return LocationTextWidget(location: 'label_update_location'.tr());
        }
        return LocationTextWidget(location: 'msg_fetching_location'.tr());
      },
    );
  }

  Widget _homeBodyWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.of(context).pushNamed(LocationScreen.screenId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _locationAutoFetchBar(context),
              ),
            ),
            const SizedBox(height: 12),
            const CategoryWidget(),
            const SizedBox(height: 12),
            FutureBuilder<List<String>>(
              future: _downloadBannerImageUrlList(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: secondaryColor,
                      ),
                    ),
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CarouselSlider.builder(
                        itemCount: snapshot.data!.length,
                        options: CarouselOptions(
                          autoPlay: true,
                          viewportFraction: 1.0,
                          height: 160,
                          autoPlayInterval: const Duration(seconds: 4),
                        ),
                        itemBuilder: (context, index, realIdx) {
                          return CachedNetworkImage(
                            imageUrl: snapshot.data![index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            const ProductListing(),
          ],
        ),
      ),
    );
  }
}

class LocationTextWidget extends StatelessWidget {
  final String location;

  const LocationTextWidget({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_on,
          size: 20,
          color: primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
          color: greyColor,
        ),
      ],
    );
  }
}
