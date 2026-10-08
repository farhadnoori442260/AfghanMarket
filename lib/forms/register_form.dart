import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/components/signup_buttons.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/services/auth.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final Auth _authService = Auth();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final FocusNode _firstNameNode;
  late final FocusNode _lastNameNode;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;
  late final FocusNode _confirmPasswordNode;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _firstNameNode = FocusNode();
    _lastNameNode = FocusNode();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
    _confirmPasswordNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // فیلدهای نام و نام خانوادگی
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: _firstNameNode,
                          controller: _firstNameController,
                          validator: (value) {
                            return checkNullEmptyValidation(
                              value,
                              'label_first_name'.tr(),
                            );
                          },
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, color: greyColor),
                            labelText: 'label_first_name'.tr(),
                            hintText: 'hint_first_name'.tr(),
                            hintStyle: const TextStyle(
                              color: greyColor,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          focusNode: _lastNameNode,
                          controller: _lastNameController,
                          validator: (value) {
                            return checkNullEmptyValidation(
                              value,
                              'label_last_name'.tr(),
                            );
                          },
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, color: greyColor),
                            labelText: 'label_last_name'.tr(),
                            hintText: 'hint_last_name'.tr(),
                            hintStyle: const TextStyle(
                              color: greyColor,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

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
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // فیلد رمز عبور
                  TextFormField(
                    focusNode: _passwordNode,
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    validator: (value) {
                      return validatePassword(value, _passwordController.text);
                    },
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
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // فیلد تکرار رمز عبور
                  TextFormField(
                    focusNode: _confirmPasswordNode,
                    obscureText: _obscureConfirmPassword,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      return validateSamePassword(
                        value,
                        _passwordController.text,
                      );
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_reset_outlined, color: greyColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _obscureConfirmPassword ? greyColor : primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      labelText: 'label_confirm_password'.tr(),
                      hintText: 'hint_confirm_password'.tr(),
                      hintStyle: const TextStyle(
                        color: greyColor,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // دکمه ثبت‌نام
                  _isLoading
                      ? const CircularProgressIndicator(color: primaryColor)
                      : roundedButton(
                          context: context,
                          bgColor: primaryColor,
                          text: 'btn_sign_up'.tr(),
                          textColor: whiteColor,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });

                              await _authService.getAdminCredentialEmailAndPassword(
                                context: context,
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                isLoginUser: false,
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
          const SizedBox(height: 16),

          // متن قوانین و حریم خصوصی
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'text_terms_privacy_agreement'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: greyColor,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // جداکننده
          Text(
            'text_or'.tr(),
            style: const TextStyle(
              fontSize: 16,
              color: greyColor,
            ),
          ),
          const SizedBox(height: 16),

          // دکمه‌های ثبت‌نام با گوگل / شماره تلفن
          const SignUpButtons(),
        ],
      ),
    );
  }
}
