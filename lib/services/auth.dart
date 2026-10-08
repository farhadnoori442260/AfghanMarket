import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/auth/email_verify_screen.dart';
import 'package:kalino_app/screens/auth/phone_otp_screen.dart';
import 'package:kalino_app/screens/location_screen.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();

  User? get currentUser => _firebaseAuth.currentUser;

  CollectionReference get users =>
      FirebaseFirestore.instance.collection('users');
  CollectionReference get categories =>
      FirebaseFirestore.instance.collection('categories');
  CollectionReference get products =>
      FirebaseFirestore.instance.collection('products');
  CollectionReference get messages =>
      FirebaseFirestore.instance.collection('messages');

  /// بررسی وجود کاربر در دیتابیس و هدایت به صفحه موقعیت
  Future<void> getAdminCredentialPhoneNumber(
      BuildContext context, User? user) async {
    if (user == null) return;

    final DocumentSnapshot userDoc = await users.doc(user.uid).get();

    if (userDoc.exists) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, LocationScreen.screenId);
      }
    } else {
      if (context.mounted) {
        await registerWithPhoneNumber(user, context);
      }
    }
  }

  /// ثبت اطلاعات کاربر تلفنی در Firestore
  Future<void> registerWithPhoneNumber(User user, BuildContext context) async {
    final uid = user.uid;
    final mobileNo = user.phoneNumber ?? '';
    final email = user.email ?? '';

    try {
      await users.doc(uid).set({
        'uid': uid,
        'mobile': mobileNo,
        'email': email,
        'name': user.displayName ?? '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, LocationScreen.screenId);
      }
    } catch (error) {
      if (kDebugMode) {
        print("Failed to add user: $error");
      }
    }
  }

  /// ارسال کد تایید پیامکی (OTP)
  Future<void> verifyPhoneNumber(BuildContext context, String number) async {
    loadingDialogBox(context, 'msg_please_wait'.tr());

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      try {
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      } catch (e) {
        if (kDebugMode) print(e);
      }
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      if (context.mounted) Navigator.pop(context);

      String errorMsg = 'msg_invalid_phone'.tr();
      if (e.code != 'invalid-phone-number') {
        errorMsg = e.message ?? e.code;
      }

      if (context.mounted) {
        wrongDetailsAlertBox(errorMsg, context);
      }
    };

    final PhoneCodeSent phoneCodeSent =
        (String verificationId, int? forceResendingToken) async {
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) => PhoneOTPScreen(
              phoneNumber: number,
              verificationIdFinal: verificationId,
            ),
          ),
        );
      }
    };

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        timeout: const Duration(seconds: 60),
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) print('Auto retrieval timeout: $verificationId');
        },
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (kDebugMode) print(e.toString());
    }
  }

  /// تایید کد SMS و ورود
  Future<void> signInwithPhoneNumber(
      String verificationId, String smsCode, BuildContext context) async {
    try {
      loadingDialogBox(context, 'msg_please_wait'.tr());
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (context.mounted) Navigator.pop(context);

      if (userCredential.user != null) {
        if (context.mounted) {
          await getAdminCredentialPhoneNumber(context, userCredential.user);
        }
      } else {
        if (context.mounted) {
          wrongDetailsAlertBox('msg_login_failed'.tr(), context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        wrongDetailsAlertBox('msg_otp_mismatch'.tr(), context);
      }
    }
  }

  /// ورود با Google
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (e) {
        if (kDebugMode) print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;

          if (user != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (!userDoc.exists) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({
                'uid': user.uid,
                'name': user.displayName ?? '',
                'email': user.email ?? '',
                'mobile': user.phoneNumber ?? '',
                'address': '',
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        } on FirebaseAuthException catch (e) {
          if (context.mounted) {
            if (e.code == 'account-exists-with-different-credential') {
              customSnackBar(
                context: context,
                content: 'msg_account_exists_different_cred'.tr(),
              );
            } else if (e.code == 'invalid-credential') {
              customSnackBar(
                context: context,
                content: 'msg_invalid_credentials'.tr(),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            customSnackBar(
              context: context,
              content: 'msg_google_sign_in_error'.tr(),
            );
          }
        }
      }
    }

    return user;
  }

  /// مدیریت ورود و ثبت‌نام با ایمیل
  Future<void> getAdminCredentialEmailAndPassword({
    required BuildContext context,
    required String email,
    String? firstName,
    String? lastName,
    required String password,
    required bool isLoginUser,
  }) async {
    try {
      if (isLoginUser) {
        await signInWithEmail(context, email, password);
      } else {
        final QuerySnapshot query =
            await users.where('email', isEqualTo: email).get();

        if (query.docs.isNotEmpty) {
          if (context.mounted) {
            customSnackBar(
              context: context,
              content: 'msg_email_already_registered'.tr(),
            );
          }
        } else {
          if (context.mounted) {
            await registerWithEmail(
              context,
              email,
              password,
              firstName ?? '',
              lastName ?? '',
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        customSnackBar(context: context, content: e.toString());
      }
    }
  }

  /// ورود با ایمیل و رمز
  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      loadingDialogBox(context, 'msg_validating_details'.tr());
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) Navigator.pop(context);

      if (credential.user != null) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, LocationScreen.screenId);
        }
      } else {
        if (context.mounted) {
          customSnackBar(
            context: context,
            content: 'msg_check_credentials'.tr(),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);

      String message = 'msg_auth_failed'.tr();
      if (e.code == 'user-not-found') {
        message = 'msg_user_not_found'.tr();
      } else if (e.code == 'wrong-password') {
        message = 'msg_wrong_password'.tr();
      }

      if (context.mounted) {
        customSnackBar(context: context, content: message);
      }
    }
  }

  /// ثبت‌نام با ایمیل و رمز
  Future<void> registerWithEmail(
    BuildContext context,
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      loadingDialogBox(context, 'msg_validating_details'.tr());

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) return;

      await users.doc(user.uid).set({
        'uid': user.uid,
        'name': "$firstName $lastName".trim(),
        'email': email,
        'mobile': '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.sendEmailVerification();

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, EmailVerifyScreen.screenId);
        customSnackBar(
          context: context,
          content: 'msg_register_success'.tr(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);

      String message = 'msg_auth_failed'.tr();
      if (e.code == 'weak-password') {
        message = 'msg_weak_password'.tr();
      } else if (e.code == 'email-already-in-use') {
        message = 'msg_email_already_in_use'.tr();
      }

      if (context.mounted) {
        customSnackBar(context: context, content: message);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        customSnackBar(
          context: context,
          content: '${'msg_error_occurred'.tr()}: ${e.toString()}',
        );
      }
    }
  }
}
