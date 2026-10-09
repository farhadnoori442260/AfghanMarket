import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import 'package:kalino_app/constants/widgets.dart';

/// دریافت موقعیت و آدرس متنی به صورت یکجا
Future<String?> getLocationAndAddress(BuildContext context) async {
  final Position? position = await getCurrentLocation(context);
  if (position == null) return null;

  if (kDebugMode) {
    print('Fetched Position: ${position.latitude}, ${position.longitude}');
  }

  if (context.mounted) {
    return await getFetchedAddress(context, position);
  }
  return null;
}

/// تبدیل مختصات جغرافیایی به آدرس قابل فهم برای افغانستان
Future<String?> getFetchedAddress(
    BuildContext context, Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      if (kDebugMode) {
        print('Placemark data: $place');
      }

      final String area = place.subLocality ?? '';
      final String city = place.locality ?? place.subAdministrativeArea ?? '';
      final String province = place.administrativeArea ?? '';

      List<String> addressParts = [];
      if (area.isNotEmpty) addressParts.add(area);
      if (city.isNotEmpty) addressParts.add(city);
      if (province.isNotEmpty && province != city) addressParts.add(province);

      if (addressParts.isNotEmpty) {
        return addressParts.join(', ');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Geocoding error: $e');
    }
  }
  return 'msg_unknown_location'.tr();
}

/// دریافت مختصات فعلی دستگاه
Future<Position?> getCurrentLocation(BuildContext context) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    if (context.mounted) {
      customSnackBar(
        context: context,
        content: 'msg_location_services_disabled'.tr(),
      );
    }
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (context.mounted) {
        customSnackBar(
          context: context,
          content: 'msg_enable_location_service'.tr(),
        );
      }
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    await permission_handler.openAppSettings();
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error getting current position: $e');
    }
    return null;
  }
}

/// آپلود تصویر آگهی در Firebase Storage
Future<String> uploadFile(BuildContext context, String filePath) async {
  final String imageName =
      'product_images/${DateTime.now().microsecondsSinceEpoch}.jpg';
  String downloadUrl = '';
  final file = File(filePath);

  if (!file.existsSync()) {
    if (context.mounted) {
      customSnackBar(
        context: context,
        content: 'msg_file_not_found'.tr(),
      );
    }
    return '';
  }

  try {
    final ref = FirebaseStorage.instance.ref().child(imageName);
    await ref.putFile(file);
    downloadUrl = await ref.getDownloadURL();

    if (kDebugMode) {
      print('Uploaded file download URL: $downloadUrl');
    }
  } on FirebaseException catch (e) {
    if (context.mounted) {
      customSnackBar(
        context: context,
        content: e.message ?? e.code,
      );
    }
  } catch (e) {
    if (context.mounted) {
      customSnackBar(
        context: context,
        content: 'msg_upload_failed'.tr(),
      );
    }
  }

  return downloadUrl;
}
