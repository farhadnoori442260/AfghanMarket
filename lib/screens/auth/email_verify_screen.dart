import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kalino_app/components/custom_icon_button.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/location_screen.dart';
import 'package:kalino_app/services/auth.dart';

class EmailVerifyScreen extends StatefulWidget {
  static const String screenId = 'email_otp_screen';

  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final Auth _authService = Auth();

  Future<void> _openEmailApp() async {
    final Uri emailUri = Uri(scheme: 'mailto');
    
    try {
      final bool launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      
      if (!mounted) return;

      if (launched) {
        Navigator.pushReplacementNamed(context, LocationScreen.screenId);
      } else {
        customSnackBar(
          context: context,
          content: 'msg_no_mail_apps'.tr(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      customSnackBar(
        context: context,
        content: 'msg_no_mail_apps'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'title_verify_email'.tr(),
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'desc_verify_email'.tr(),
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Lottie.asset(
                  'assets/lottie/verify_lottie.json',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.mark_email_read_outlined,
                    size: 150,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: _openEmailApp,
                child: CustomIconButton(
                  text: 'btn_open_email_app'.tr(),
                  bgColor: secondaryColor,
                  icon: Icons.mark_email_read_rounded,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      LocationScreen.screenId,
                    );
                  },
                  child: Text(
                    'btn_skip_for_now'.tr(),
                    style: const TextStyle(
                      color: linkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
