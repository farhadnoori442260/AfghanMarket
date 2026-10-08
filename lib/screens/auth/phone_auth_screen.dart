import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/components/bottom_nav_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/services/auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  static const String screenId = 'phone_auth_screen';
  final bool isFromLogin;

  const PhoneAuthScreen({
    Key? key,
    this.isFromLogin = true,
  }) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final Auth _authService = Auth();
  late final TextEditingController _countryCodeController;
  late final TextEditingController _phoneNumberController;
  late final FocusNode _countryCodeNode;
  late final FocusNode _phoneNumberNode;

  String _counterText = '0';
  bool _validate = false;
  final int _phoneLength = 9; // طول شماره موبایل افغانستان (بدون صفر ابتدایی)

  @override
  void initState() {
    super.initState();
    _countryCodeController = TextEditingController(text: '+93');
    _phoneNumberController = TextEditingController();
    _countryCodeNode = FocusNode();
    _phoneNumberNode = FocusNode();
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneNumberController.dispose();
    _countryCodeNode.dispose();
    _phoneNumberNode.dispose();
    super.dispose();
  }

  void _signInValidate() {
    String phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    final String fullNumber = '${_countryCodeController.text}$phoneNumber';

    if (kDebugMode) {
      print('Full Phone Number: $fullNumber');
    }

    _authService.verifyPhoneNumber(context, fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        title: Text(
          widget.isFromLogin ? 'title_login'.tr() : 'title_signup'.tr(),
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                backgroundColor: primaryColor,
                radius: 40,
                child: const CircleAvatar(
                  backgroundColor: secondaryColor,
                  radius: 37,
                  child: Icon(
                    CupertinoIcons.person_fill,
                    color: whiteColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'title_enter_phone'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'desc_enter_phone'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      focusNode: _countryCodeNode,
                      textAlign: TextAlign.center,
                      controller: _countryCodeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'label_code'.tr(),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      focusNode: _phoneNumberNode,
                      maxLength: _phoneLength,
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _counterText = value.length.toString();
                          _validate = value.length == _phoneLength;
                        });
                      },
                      decoration: InputDecoration(
                        counterText: '$_counterText/$_phoneLength',
                        counterStyle: const TextStyle(fontSize: 11),
                        labelText: 'label_phone_number'.tr(),
                        hintText: 'hint_phone_number'.tr(),
                        hintStyle: const TextStyle(
                          color: greyColor,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        validator: _validate,
        buttonText: 'btn_next'.tr(),
        onPressed: _signInValidate,
      ),
    );
  }
}
