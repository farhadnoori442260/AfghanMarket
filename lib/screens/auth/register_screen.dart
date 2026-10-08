import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/components/large_heading_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/forms/register_form.dart';

class RegisterScreen extends StatefulWidget {
  static const String screenId = 'register_screen';
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LargeHeadingWidget(
            heading: 'title_create_account'.tr(),
            subHeading: 'desc_create_account'.tr(),
            anotherTaglineText: '\n${'already_have_account'.tr()}',
            anotherTaglineColor: secondaryColor,
            subheadingTextSize: 15,
            taglineNavigation: true,
          ),
          const SizedBox(height: 20),
          const RegisterForm(),
        ],
      ),
    );
  }
}
