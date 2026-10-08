import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/screens/main_navigation_screen.dart';
import 'package:kalino_app/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String screenId = 'splash_screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSplashNavigation();
  }

  void _startSplashNavigation() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, WelcomeScreen.screenId);
      } else {
        Navigator.pushReplacementNamed(
          context,
          MainNavigationScreen.screenId,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size.height * 0.15,
              child: SizedBox(
                width: size.width * 0.7,
                height: size.height * 0.35,
                child: Lottie.asset(
                  'assets/lottie/splash_lottie.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.shopping_bag_outlined,
                      size: 100,
                      color: primaryColor,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'app_name'.tr(),
                    style: const TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'app_tagline'.tr(),
                    style: const TextStyle(
                      color: blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
