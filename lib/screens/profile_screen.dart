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

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // برای آینده نگه داشته شده؛ اگر در سرویس‌های دیگر استفاده‌اش می‌کنی.
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
              const SizedBox(height: 24),

              _buildProfileOption(
                icon: Icons.favorite_border,
                title: 'menu_my_favorites'.tr(),
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.list_alt,
                title: 'menu_my_ads'.tr(),
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.language,
                title: 'menu_language_settings'.tr(),
                onTap: _showLanguageBottomSheet,
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'menu_help_support'.tr(),
                onTap: () {},
              ),

              const Divider(height: 32),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ),
                title: Text(
                  'btn_sign_out'.tr(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: _showSignOutConfirmationDialog,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      leading: Icon(icon, color: blackColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: blackColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
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
