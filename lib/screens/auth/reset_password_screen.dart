import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/components/large_heading_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/forms/reset_form.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String screenId = 'reset_password_screen';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LargeHeadingWidget(
                heading: 'title_forgot_password'.tr(),
                subHeading: 'desc_forgot_password'.tr(),
                headingTextSize: 28,
                subheadingTextSize: 15,
              ),
              const SizedBox(height: 20),
              const ResetForm(),
            ],
          ),
        ),
      ),
    );
  }
}
