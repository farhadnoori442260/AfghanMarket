import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/components/large_heading_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/forms/login_form.dart';

class LoginScreen extends StatefulWidget {
  static const String screenId = 'login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LargeHeadingWidget(
                heading: 'title_welcome'.tr(),
                subHeading: 'subtitle_sign_in'.tr(),
              ),
              const SizedBox(height: 20),
              const LogInForm(),
            ],
          ),
        ),
      ),
    );
  }
}
