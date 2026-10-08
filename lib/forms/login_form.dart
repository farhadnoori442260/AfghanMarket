import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/components/login_buttons.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/auth/register_screen.dart';
import 'package:kalino_app/screens/auth/reset_password_screen.dart';
import 'package:kalino_app/services/auth.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({Key? key}) : super(key: key);

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final Auth _authService = Auth();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
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
                // فیلد ایمیل
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
                const SizedBox(height: 16),

                // فیلد رمز عبور
                TextFormField(
                  focusNode: _passwordNode,
                  controller: _passwordController,
                  validator: (value) {
                    return validatePassword(value, _passwordController.text);
                  },
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: greyColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _obscurePassword ? greyColor : primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    labelText: 'label_password'.tr(),
                    hintText: 'hint_enter_password'.tr(),
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

                // لینک فراموشی رمز عبور
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(top: 10, right: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ResetPasswordScreen.screenId,
                      );
                    },
                    child: Text(
                      'btn_forgot_password'.tr(),
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // دکمه ورود
                _isLoading
                    ? const CircularProgressIndicator(color: primaryColor)
                    : roundedButton(
                        context: context,
                        bgColor: primaryColor,
                        text: 'btn_sign_in'.tr(),
                        textColor: whiteColor,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            await _authService.getAdminCredentialEmailAndPassword(
                              context: context,
                              email: _emailController.text,
                              password: _passwordController.text,
                              isLoginUser: true,
                            );

                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // لینک ایجاد حساب جدید
        RichText(
          text: TextSpan(
            text: 'text_dont_have_account'.tr(),
            style: const TextStyle(
              fontSize: 14,
              color: greyColor,
            ),
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, RegisterScreen.screenId);
                  },
                text: 'btn_create_new_account'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),

        // جداکننده
        Text(
          'text_or'.tr(),
          style: const TextStyle(
            fontSize: 16,
            color: greyColor,
          ),
        ),
        const SizedBox(height: 15),

        // دکمه‌های ورود با گوگل / شماره تلفن
        const LoginInButtons(),
      ],
    );
  }
}
