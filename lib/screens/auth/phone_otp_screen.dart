import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

import 'package:kalino_app/components/bottom_nav_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/services/auth.dart';

class PhoneOTPScreen extends StatefulWidget {
  static const String screenId = 'phone_otp_screen';
  final String phoneNumber;
  final String verificationIdFinal;

  const PhoneOTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationIdFinal,
  }) : super(key: key);

  @override
  State<PhoneOTPScreen> createState() => _PhoneOTPScreenState();
}

class _PhoneOTPScreenState extends State<PhoneOTPScreen> {
  final Auth _authService = Auth();
  bool _isPinEntered = false;
  bool _isLoading = false;
  String _smsCode = "";

  Future<void> _validateOTP() async {
    if (_smsCode.length < 6 || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (kDebugMode) {
      print('SMS Code entered: $_smsCode');
    }

    try {
      await _authService.signInwithPhoneNumber(
        widget.verificationIdFinal,
        _smsCode,
        context,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: blackColor),
        backgroundColor: whiteColor,
        elevation: 1,
        title: Text(
          'title_verify_otp'.tr(),
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
                radius: 35,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: const Icon(
                  CupertinoIcons.person_alt_circle,
                  color: secondaryColor,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'desc_otp_sent_to'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: primaryColor,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width,
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldWidth: 42,
                    fieldStyle: FieldStyle.box,
                    outlineBorderRadius: 10,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (value.length < 6 && _isPinEntered) {
                        setState(() {
                          _isPinEntered = false;
                        });
                      }
                    },
                    onCompleted: (pin) {
                      setState(() {
                        _smsCode = pin;
                        _isPinEntered = true;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'hint_enter_6_digit'.tr(),
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        buttonText: _isLoading ? 'btn_loading'.tr() : 'btn_next'.tr(),
        onPressed: _validateOTP,
        validator: _isPinEntered && !_isLoading,
      ),
    );
  }
}
