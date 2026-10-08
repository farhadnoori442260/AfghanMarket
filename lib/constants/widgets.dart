import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/models/popup_menu_model.dart';
import 'package:kalino_app/services/user.dart';

/// دیالوگ بارگذاری (Loading Dialog)
void loadingDialogBox(BuildContext context, String loadingMessage) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    content: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: primaryColor,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              loadingMessage,
              style: const TextStyle(
                color: blackColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/// نمایش پیام شناور (Custom SnackBar)
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar({
  required BuildContext context,
  required String content,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: blackColor,
      content: Text(
        content,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 14,
        ),
      ),
    ),
  );
}

/// دکمه اصلی برنامه (Rounded Button)
Widget roundedButton({
  BuildContext? context,
  required Color? bgColor,
  required VoidCallback? onPressed,
  Color? textColor,
  double? width,
  double? heightPadding,
  required String? text,
  Color? borderColor,
}) {
  return SizedBox(
    width: width ?? double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: bgColor ?? primaryColor,
        foregroundColor: textColor ?? whiteColor,
        padding: EdgeInsets.symmetric(vertical: heightPadding ?? 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text ?? '',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor ?? whiteColor,
        ),
      ),
    ),
  );
}

/// دیالوگ پیام خطا یا هشدار (Alert Box)
void wrongDetailsAlertBox(String text, BuildContext context) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    content: Text(
      text,
      style: const TextStyle(
        color: blackColor,
        fontSize: 14,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'btn_ok'.tr(),
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/// نمایش صفحه کشویی از پایین (Bottom Sheet)
void openBottomSheet({
  required BuildContext context,
  required Widget child,
  String? appBarTitle,
  double? height,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar baraye visual feedback
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: greyLightColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            if (appBarTitle != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appBarTitle,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: blackColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: dividerColor),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: height ?? MediaQuery.of(context).size.height * 0.6,
              ),
              child: child,
            ),
          ],
        ),
      );
    },
  );
}

/// منوی پاپ آپ گفتگوها (Custom PopUp Menu)
Widget customPopUpMenu({
  required BuildContext context,
  required String? chatroomId,
}) {
  CustomPopupMenuController controller = CustomPopupMenuController();
  UserService firebaseUser = UserService();

  List<PopUpMenuModel> menuItems = [
    PopUpMenuModel('menu_delete_chat'.tr(), Icons.delete_outline),
    PopUpMenuModel('menu_mark_sold'.tr(), Icons.check_circle_outline),
  ];

  return CustomPopupMenu(
    menuBuilder: () => ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: whiteColor,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: menuItems.asMap().entries.map((entry) {
              int index = entry.key;
              PopUpMenuModel item = entry.value;

              return InkWell(
                onTap: () {
                  if (index == 0) {
                    firebaseUser.deleteChat(chatroomId: chatroomId);
                    customSnackBar(
                      context: context,
                      content: 'msg_chat_deleted'.tr(),
                    );
                  } else {
                    // Mark as Sold Action
                  }
                  controller.hideMenu();
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        item.icon,
                        size: 20,
                        color: index == 0 ? errorColor : blackColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: index == 0 ? errorColor : blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ),
    pressType: PressType.singleClick,
    verticalMargin: -10,
    controller: controller,
    child: const Padding(
      padding: EdgeInsets.all(12),
      child: Icon(Icons.more_vert, color: blackColor),
    ),
  );
}
