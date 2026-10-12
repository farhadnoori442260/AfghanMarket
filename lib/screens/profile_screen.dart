import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/auth/login_screen.dart';
import 'package:kalino_app/screens/post/my_post_screen.dart';
import 'package:kalino_app/screens/welcome_screen.dart';
import 'package:kalino_app/services/user.dart';

class ProfileScreen extends StatefulWidget {
  static const String screenId = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _firebaseUser = UserService();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signOut() async {
    try {
      loadingDialogBox(context, 'msg_signing_out'.tr());

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      Navigator.of(context).pushNamedAndRemoveUntil(
        WelcomeScreen.screenId,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      customSnackBar(
        context: context,
        content: 'err_something_went_wrong'.tr(),
      );
    }
  }

  void _showLanguageBottomSheet() {
    String selectedLanguageCode = context.locale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (
            BuildContext modalContext,
            StateSetter setModalState,
          ) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  24 + MediaQuery.of(modalContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.language,
                          color: primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'menu_language_settings'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'دری (Persian)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      value: 'fa',
                      groupValue: selectedLanguageCode,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedLanguageCode = value;
                        });
                      },
                    ),

                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'پښتو (Pashto)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      value: 'ps',
                      groupValue: selectedLanguageCode,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedLanguageCode = value;
                        });
                      },
                    ),

                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'English',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      value: 'en',
                      groupValue: selectedLanguageCode,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedLanguageCode = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          await context.setLocale(
                            Locale(selectedLanguageCode),
                          );

                          if (modalContext.mounted) {
                            Navigator.of(modalContext).pop();
                          }
                        },
                        child: Text(
                          'btn_confirm'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'کالینو (Kalino)',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(
        Icons.storefront,
        size: 48,
        color: primaryColor,
      ),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'کالینو؛ بازار بزرگ نیازمندی‌ها و خدمات انلاین افغانستان.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _showSafetyGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'راهنمای خرید امن و جلوگیری از کلاهبرداری',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('• هیچ‌گاه پیش از دریافت کالا، بیعانه یا وجهی پرداخت نکنید.'),
              const SizedBox(height: 8),
              const Text('• معامله را ترجیحاً به صورت حضوری و در مکان‌های عمومی انجام دهید.'),
              const SizedBox(height: 8),
              const Text('• در صورت مشاهده آگهی‌های مشکوک، آن را گزارش دهید.'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('متوجه شدم', style: TextStyle(color: whiteColor)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        automaticallyImplyLeading: false,
        title: Text(
          'title_my_account'.tr(),
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            children: [
              // بخش هویت کاربر (دست‌نخورده)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: primaryColor.withOpacity(0.2),
                      backgroundImage: _currentUser?.photoURL != null
                          ? NetworkImage(_currentUser!.photoURL!)
                          : null,
                      child: _currentUser?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 36,
                              color: primaryColor,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.displayName ??
                                'label_guest_user'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.email ??
                                _currentUser?.phoneNumber ??
                                'label_no_contact_info'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // دکمه ورود در صورت مهمان بودن کاربر
              if (_currentUser == null)
                _buildCardGroup(
                  children: [
                    _buildProfileOption(
                      icon: Icons.login_rounded,
                      iconColor: Colors.green,
                      title: 'ورود به حساب کاربری',
                      onTap: () {
                        Navigator.pushNamed(context, LoginScreen.screenId);
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // گروه اول: مدیریت آگهی‌ها و علاقه مندی‌ها
              _buildCardGroup(
                children: [
                  _buildProfileOption(
                    icon: Icons.list_alt_rounded,
                    title: 'menu_my_ads'.tr(),
                    onTap: () {
                      Navigator.pushNamed(context, MyPostScreen.screenId);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.favorite_border_rounded,
                    title: 'menu_my_favorites'.tr(),
                    onTap: () {
                      customSnackBar(
                        context: context,
                        content: 'لیست نشان‌ها خالی است',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.history_rounded,
                    title: 'بازدیدهای اخیر',
                    onTap: () {
                      customSnackBar(
                        context: context,
                        content: 'تاریخچه بازدیدی ثبت نشده است',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // گروه دوم: تنظیمات و پشتیبانی
              _buildCardGroup(
                children: [
                  _buildProfileOption(
                    icon: Icons.language_rounded,
                    title: 'menu_language_settings'.tr(),
                    onTap: _showLanguageBottomSheet,
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.help_outline_rounded,
                    title: 'menu_help_support'.tr(),
                    onTap: () async {
                      final Uri url = Uri.parse('mailto:support@kalino.app');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // گروه سوم: امنیت و اطلاعات اپلیکیشن
              _buildCardGroup(
                children: [
                  _buildProfileOption(
                    icon: Icons.shield_outlined,
                    title: 'مقابله با کلاهبرداری و خرید امن',
                    onTap: _showSafetyGuide,
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    icon: Icons.info_outline_rounded,
                    title: 'درباره کالینو',
                    onTap: _showAboutDialog,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // خروج از حساب
              if (_currentUser != null) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'btn_sign_out'.tr(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onTap: _showSignOutConfirmationDialog,
                ),
                const SizedBox(height: 10),
              ],

              // نسخه برنامه
              const Center(
                child: Text(
                  'نسخه ۱.۰.۰ (کالینو)',
                  style: TextStyle(
                    color: greyColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      leading: Icon(icon, color: iconColor ?? blackColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: blackColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: greyColor,
      ),
      onTap: onTap,
    );
  }

  void _showSignOutConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('dialog_sign_out_title'.tr()),
          content: Text('dialog_sign_out_msg'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('btn_cancel'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: whiteColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _signOut();
              },
              child: Text('btn_sign_out'.tr()),
            ),
          ],
        );
      },
    );
  }
}
