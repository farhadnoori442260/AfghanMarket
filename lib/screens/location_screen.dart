import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:kalino_app/components/large_heading_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/main_navigation_screen.dart';
import 'package:kalino_app/services/user.dart';
import 'package:kalino_app/utils.dart';

class LocationScreen extends StatefulWidget {
  final bool? onlyPop;
  final String? popToScreen;

  static const String screenId = 'location_screen';

  const LocationScreen({
    this.popToScreen,
    this.onlyPop,
    Key? key,
  }) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _body(context),
      bottomNavigationBar: BottomLocationPermissionWidget(
        onlyPop: widget.onlyPop,
        popToScreen: widget.popToScreen ?? '',
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LargeHeadingWidget(
              heading: 'location_choose_title'.tr(),
              subheadingTextSize: 15,
              headingTextSize: 28,
              subHeading: 'location_choose_subheading'.tr(),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/location_lottie.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomLocationPermissionWidget extends StatefulWidget {
  final bool? onlyPop;
  final String popToScreen;

  const BottomLocationPermissionWidget({
    required this.popToScreen,
    this.onlyPop,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomLocationPermissionWidget> createState() =>
      _BottomLocationPermissionWidgetState();
}

class _BottomLocationPermissionWidgetState
    extends State<BottomLocationPermissionWidget> {
  final UserService firebaseUser = UserService();

  void _navigateNext(BuildContext context) {
    if (widget.onlyPop == true) {
      if (widget.popToScreen.isNotEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.popToScreen,
          (route) => false,
        );
      } else {
        Navigator.of(context).pop();
      }
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      MainNavigationScreen.screenId,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: roundedButton(
        context: context,
        text: 'location_choose_title'.tr(),
        bgColor: secondaryColor,
        onPressed: () => openLocationBottomSheet(context),
      ),
    );
  }

  void openLocationBottomSheet(BuildContext context) {
    var countryValue = '';
    var stateValue = '';
    var cityValue = '';
    var address = '';
    var manualAddress = '';

    loadingDialogBox(context, 'msg_fetching_details'.tr());

    getLocationAndAddress(context).then((location) {
      if (!mounted) {
        return;
      }

      if (location == null) {
        Navigator.pop(context);
        return;
      }

      Navigator.pop(context);
      address = location;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (modalContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                color: whiteColor,
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    AppBar(
                      automaticallyImplyLeading: false,
                      iconTheme: const IconThemeData(color: blackColor),
                      elevation: 0,
                      backgroundColor: whiteColor,
                      title: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(modalContext),
                            icon: const Icon(Icons.clear),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'location_select_title'.tr(),
                            style: const TextStyle(
                              color: blackColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(Icons.search),
                                  hintText: 'location_search_hint'.tr(),
                                  hintStyle: const TextStyle(
                                    color: greyColor,
                                    fontSize: 12,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              onTap: () async {
                                loadingDialogBox(
                                  modalContext,
                                  'msg_updating_location'.tr(),
                                );

                                final value =
                                    await getCurrentLocation(modalContext);

                                if (!mounted) {
                                  return;
                                }

                                if (value == null) {
                                  Navigator.pop(modalContext);
                                  return;
                                }

                                await firebaseUser.updateFirebaseUser(
                                  modalContext,
                                  {
                                    'location': GeoPoint(
                                      value.latitude,
                                      value.longitude,
                                    ),
                                    'address': address,
                                  },
                                );

                                if (!mounted) {
                                  return;
                                }

                                Navigator.pop(modalContext);
                                Navigator.pop(modalContext);
                                _navigateNext(context);
                              },
                              horizontalTitleGap: 0,
                              leading: const Icon(
                                Icons.my_location,
                                color: secondaryColor,
                              ),
                              title: Text(
                                'location_use_current'.tr(),
                                style: const TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                address.isEmpty
                                    ? 'location_fetch_current'.tr()
                                    : address,
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Text(
                                'location_choose_city'.tr(),
                                style: const TextStyle(
                                  color: blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: CSCPicker(
                                layout: Layout.vertical,
                                defaultCountry: CscCountry.Afghanistan,
                                flagState: CountryFlag.DISABLE,
                                dropdownDecoration: BoxDecoration(
                                  border: Border.all(color: greyColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                onCountryChanged: (value) {
                                  setModalState(() {
                                    countryValue = value;
                                  });
                                },
                                onStateChanged: (value) {
                                  setModalState(() {
                                    stateValue = value ?? '';
                                  });
                                },
                                onCityChanged: (value) async {
                                  if (value == null) {
                                    return;
                                  }

                                  setModalState(() {
                                    cityValue = value;
                                    manualAddress =
                                        '$cityValue, $stateValue';
                                  });

                                  loadingDialogBox(
                                    modalContext,
                                    'msg_updating_location'.tr(),
                                  );

                                  await firebaseUser.updateFirebaseUser(
                                    modalContext,
                                    {
                                      'address': manualAddress,
                                      'state': stateValue,
                                      'city': cityValue,
                                      'country': countryValue,
                                    },
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  if (kDebugMode) {
                                    print(
                                      '$manualAddress inside manual selection',
                                    );
                                  }

                                  Navigator.pop(modalContext);
                                  Navigator.pop(modalContext);
                                  _navigateNext(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }
}
