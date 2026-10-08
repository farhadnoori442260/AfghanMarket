import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/services/auth.dart';

class UserService {
  final Auth authService = Auth();

  User? get user => FirebaseAuth.instance.currentUser;

  /// به‌روزرسانی اطلاعات کاربر در Firestore
  Future<void> updateFirebaseUser(
      BuildContext context, Map<String, dynamic> data) async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      await authService.users.doc(currentUser.uid).update(data);
      if (context.mounted) {
        customSnackBar(
          context: context,
          content: 'msg_location_updated'.tr(),
        );
      }
    } catch (error) {
      if (context.mounted) {
        customSnackBar(
          context: context,
          content: 'msg_location_update_failed'.tr(),
        );
      }
    }
  }

  /// دریافت اطلاعات کاربر فعلی
  Future<DocumentSnapshot?> getUserData() async {
    final currentUser = user;
    if (currentUser == null) return null;

    DocumentSnapshot doc = await authService.users.doc(currentUser.uid).get();
    return doc;
  }

  /// دریافت اطلاعات فروشنده
  Future<DocumentSnapshot> getSellerData(String id) async {
    DocumentSnapshot doc = await authService.users.doc(id).get();
    return doc;
  }

  /// دریافت اطلاعات جزئیات محصول
  Future<DocumentSnapshot> getProductDetails(String id) async {
    DocumentSnapshot doc = await authService.products.doc(id).get();
    return doc;
  }

  /// ایجاد چت‌روم جدید
  Future<void> createChatRoom({required Map<String, dynamic> data}) async {
    try {
      await authService.messages
          .doc(data['chatroomId'])
          .set(data, SetOptions(merge: true));
    } catch (error) {
      if (kDebugMode) {
        print('Error creating chat room: $error');
      }
    }
  }

  /// ارسال پیام جدید در چت
  Future<void> createChat({
    String? chatroomId,
    required Map<String, dynamic> message,
  }) async {
    if (chatroomId == null) return;

    try {
      await authService.messages
          .doc(chatroomId)
          .collection('chats')
          .add(message);

      await authService.messages.doc(chatroomId).update({
        'lastChat': message['message'],
        'lastChatTime': message['time'],
        'read': false,
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error sending message: $error');
      }
    }
  }

  /// دریافت جریان پیام‌های یک گفتگو
  Stream<QuerySnapshot>? getChatDetails({String? chatroomId}) {
    if (chatroomId == null) return null;

    return authService.messages
        .doc(chatroomId)
        .collection('chats')
        .orderBy('time', descending: false)
        .snapshots();
  }

  /// حذف گفتگو
  Future<void> deleteChat({String? chatroomId}) async {
    if (chatroomId == null) return;
    return authService.messages.doc(chatroomId).delete();
  }

  /// مدیریت لیست علاقه‌مندی‌های کاربر
  Future<void> updateFavourite({
    required BuildContext context,
    required bool isLiked,
    required String productId,
  }) async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      if (isLiked) {
        await authService.products.doc(productId).update({
          'favourites': FieldValue.arrayUnion([currentUser.uid])
        });
        if (context.mounted) {
          customSnackBar(
            context: context,
            content: 'msg_added_favourite'.tr(),
          );
        }
      } else {
        await authService.products.doc(productId).update({
          'favourites': FieldValue.arrayRemove([currentUser.uid])
        });
        if (context.mounted) {
          customSnackBar(
            context: context,
            content: 'msg_removed_favourite'.tr(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating favourites: $e');
      }
    }
  }
}
