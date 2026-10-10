import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/screens/auth/phone_auth_screen.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/components/custom_icon_button.dart';

class LoginInButtons extends StatefulWidget {
  const LoginInButtons({Key? key}) : super(key: key);

  @override
  State<LoginInButtons> createState() => _LoginInButtonsState();
}

class _LoginInButtonsState extends State<LoginInButtons> {
  final Auth _authService = Auth();
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // دکمه ورود با شماره موبایل
          CustomIconButton(
            text: 'btn_phone_login'.tr(),
            imageIcon: 'assets/phone.png',
            bgColor: primaryColor,
            textColor: whiteColor,
            imageOrIconColor: whiteColor,
            imageOrIconSize: 20,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhoneAuthScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // دکمه ورود با حساب گوگل
          _isGoogleLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                )
              : CustomIconButton(
                  text: 'btn_google_login'.tr(),
                  imageIcon: 'assets/google.png',
                  bgColor: whiteColor,
                  textColor: blackColor,
                  border: Border.all(color: greyLightColor, width: 1.5),
                  imageOrIconSize: 20,
                  onTap: () async {
                    setState(() {
                      _isGoogleLoading = true;
                    });
                    try {
                      User? user =
                          await Auth.signInWithGoogle(context: context);
                      if (user != null && mounted) {
                        _authService.getAdminCredentialPhoneNumber(
                            context, user);
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isGoogleLoading = false;
                        });
                      }
                    }
                  },
                ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
