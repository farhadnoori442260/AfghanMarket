import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/auth/login_screen.dart';
import 'package:kalino_app/screens/auth/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String screenId = 'welcome_screen';

  const WelcomeScreen({Key? key}) : super(Key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // قفل کردن و تنظیم پیش‌فرض روی زبان فارسی
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.locale.languageCode != 'fa') {
        context.setLocale(const Locale('fa'));
      }
    });
  }

  // نمایش مدال مدرن جهت تغییر زبان
  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: whiteColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'انتخاب زبان / Choose Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: greyColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                title: 'فارسی (دری)',
                locale: const Locale('fa'),
              ),
              _buildLanguageOption(
                context,
                title: 'پښتو',
                locale: const Locale('ps'),
              ),
              _buildLanguageOption(
                context,
                title: 'English',
                locale: const Locale('en'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required Locale locale,
  }) {
    final bool isSelected = context.locale.languageCode == locale.languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          context.setLocale(locale);
          Navigator.pop(context);
        },
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? primaryColor : blackColor,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: primaryColor)
            : const Icon(Icons.radio_button_unchecked, color: greyColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: _welcomeBodyWidget(context),
      ),
    );
  }

  Widget _welcomeBodyWidget(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // دکمه مدرن تغییر زبان در گوشه بالای صفحه
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _showLanguageBottomSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.locale.languageCode == 'ps'
                            ? 'پښتو'
                            : context.locale.languageCode == 'en'
                                ? 'English'
                                : 'فارسی',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: greyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // بخش عنوان و شعار برنامه
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app_name'.tr(),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'app_tagline'.tr(),
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // انیمیشن Lottie وسط صفحه
          Expanded(
            child: Center(
              child: Lottie.asset(
                'assets/lottie/welcome_lottie.json',
                width: size.width * 0.8,
                height: size.height * 0.4,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.storefront_outlined,
                    size: 120,
                    color: primaryColor,
                  );
                },
              ),
            ),
          ),

          // دکمه‌های ورود و ثبت‌نام
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        roundedButton(
          context: context,
          bgColor: whiteColor,
          borderColor: primaryColor,
          textColor: primaryColor,
          text: 'btn_login'.tr(),
          onPressed: () {
            Navigator.pushNamed(context, LoginScreen.screenId);
          },
        ),
        const SizedBox(height: 12),
        roundedButton(
          context: context,
          bgColor: secondaryColor,
          textColor: whiteColor,
          text: 'btn_register'.tr(),
          onPressed: () {
            Navigator.pushNamed(context, RegisterScreen.screenId);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
