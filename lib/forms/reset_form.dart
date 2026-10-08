import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/auth/login_screen.dart';
import 'package:kalino_app/services/auth.dart';

class ResetForm extends StatefulWidget {
  const ResetForm({
    Key? key,
  }) : super(key: key);

  @override
  State<ResetForm> createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  final Auth _authService = Auth();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final FocusNode _emailNode;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // فیلد دریافت ایمیل
                TextFormField(
                  focusNode: _emailNode,
                  controller: _emailController,
                  validator: (value) {
                    return validateEmail(
                      value,
                      EmailValidator.validate(_emailController.text),
                    );
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: greyColor),
                    labelText: 'label_email'.tr(),
                    hintText: 'hint_enter_email'.tr(),
                    hintStyle: const TextStyle(
                      color: greyColor,
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.all(18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // دکمه ارسال لینک بازیابی
                _isLoading
                    ? const CircularProgressIndicator(color: primaryColor)
                    : roundedButton(
                        context: context,
                        bgColor: primaryColor,
                        text: 'btn_send_reset_link'.tr(),
                        textColor: whiteColor,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: _emailController.text.trim(),
                              );

                              if (mounted) {
                                customSnackBar(
                                  context: context,
                                  content: 'msg_reset_link_sent'.tr(),
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  LoginScreen.screenId,
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              if (mounted) {
                                customSnackBar(
                                  context: context,
                                  content: e.message ?? 'msg_reset_failed'.tr(),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
