import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/welcome_screen.dart';
import 'package:kalino_app/services/user.dart';

class ProfileScreen extends StatefulWidget {
  static const String screenId = 'profile_screen';

  const ProfileScreen({Key? key}) : super(key: key);

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

      if (mounted) {
        Navigator.pop(context); // بستن loadingDialogBox
        Navigator.of(context).pushNamedAndRemoveUntil(
          WelcomeScreen.screenId,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        customSnackBar(context: context, content: 'err_something_went_wrong'.tr());
      }
    }
  }

  // دیالوگ/منوی انتخاب زبان با آیکون کره زمین و دکمه تایید
  void _showLanguageBottomSheet() {
    String selectedLanguageCode = context.locale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // آیکون کره زمین و عنوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: primaryColor, size: 28),
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

                  // زبان دری
                  RadioListTile<String>(
                    title: const Text('دری (Persian)', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: 'fa',
                    groupValue: selectedLanguageCode,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setModalState(() {
                        selectedLanguageCode = value!;
                      });
                    },
                  ),

                  // زبان پشتو
                  RadioListTile<String>(
                    title: const Text('پښتو (Pashto)', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: 'ps',
                    groupValue: selectedLanguageCode,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setModalState(() {
                        selectedLanguageCode = value!;
                      });
                    },
                  ),

                  // زبان انگلیسی
                  RadioListTile<String>(
                    title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: 'en',
                    groupValue: selectedLanguageCode,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setModalState(() {
                        selectedLanguageCode = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // دکمه تایید تغییر زبان
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        context.setLocale(Locale(selectedLanguageCode));
                        Navigator.pop(context);
                      },
                      child: Text(
                        'btn_confirm'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // کارت اطلاعات کاربر
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
                          ? const Icon(Icons.person, size: 36, color: primaryColor)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.displayName ?? 'label_guest_user'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.email ??
                                _currentUser?.phoneNumber ??
                                'label_no_contact_info'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: greyColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // گزینه‌های منوی حساب کاربر
              _buildProfileOption(
                icon: Icons.favorite_border,
                title: 'menu_my_favorites'.tr(),
                onTap: () {
                  // هدایت به صفحه پسندیده‌ها
                },
              ),
              _buildProfileOption(
                icon: Icons.list_alt,
                title: 'menu_my_ads'.tr(),
                onTap: () {
                  // هدایت به صفحه آگهی‌های من
                },
              ),
              _buildProfileOption(
                icon: Icons.language,
                title: 'menu_language_settings'.tr(),
                onTap: () {
                  _showLanguageBottomSheet();
                },
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'menu_help_support'.tr(),
                onTap: () {
                  // صفحه پشتیبانی
                },
              ),

              const Divider(height: 32),

              // دکمه خروج
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: Text(
                  'btn_sign_out'.tr(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  _showSignOutConfirmationDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: blackColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: blackColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: greyColor),
      onTap: onTap,
    );
  }

  void _showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('dialog_sign_out_title'.tr()),
        content: Text('dialog_sign_out_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: Text('btn_sign_out'.tr()),
          ),
        ],
      ),
    );
  }
}
