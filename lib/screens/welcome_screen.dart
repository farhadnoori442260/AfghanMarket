import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/auth/login_screen.dart';
import 'package:kalino_app/screens/auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String screenId = 'welcome_screen';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: _welcomeBodyWidget(context),
      ),
    );
  }

  Widget _welcomeBodyWidget(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // بخش عنوان و شعار برنامه
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app_name'.tr(),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'app_tagline'.tr(),
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // انیمیشن Lottie وسط صفحه
          Expanded(
            child: Center(
              child: Lottie.asset(
                'assets/lottie/welcome_lottie.json',
                width: size.width * 0.8,
                height: size.height * 0.4,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.storefront_outlined,
                    size: 120,
                    color: primaryColor,
                  );
                },
              ),
            ),
          ),

          // دکمه‌های ورود و ثبت‌نام
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        roundedButton(
          context: context,
          bgColor: whiteColor,
          borderColor: primaryColor,
          textColor: primaryColor,
          text: 'btn_login'.tr(),
          onPressed: () {
            Navigator.pushNamed(context, LoginScreen.screenId);
          },
        ),
        const SizedBox(height: 12),
        roundedButton(
          context: context,
          bgColor: secondaryColor,
          textColor: whiteColor,
          text: 'btn_register'.tr(),
          onPressed: () {
            Navigator.pushNamed(context, RegisterScreen.screenId);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
