import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/provider/product_provider.dart';
import 'package:kalino_app/screens/chat/chat_stream.dart';
import 'package:kalino_app/services/user.dart';

class UserChatScreen extends StatefulWidget {
  static const String screenId = 'user_chat_screen';
  final String? chatroomId;

  const UserChatScreen({Key? key, this.chatroomId}) : super(key: key);

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final UserService _firebaseUser = UserService();

  bool _canSend = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _msgController.text.trim();
    if (text.isNotEmpty && _firebaseUser.user != null) {
      final Map<String, dynamic> message = {
        'message': text,
        'sent_by': _firebaseUser.user!.uid,
        'time': DateTime.now().microsecondsSinceEpoch,
      };

      _firebaseUser.createChat(
        chatroomId: widget.chatroomId,
        message: message,
      );

      _msgController.clear();
      setState(() {
        _canSend = false;
      });
    }
  }

  Widget _buildBottomInputField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                // پیوست فایل یا تصویر
              },
              icon: const Icon(Icons.attach_file, color: greyColor),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: blackColor, fontSize: 14),
                  onChanged: (value) {
                    setState(() {
                      _canSend = value.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'hint_enter_message'.tr(),
                    hintStyle: const TextStyle(color: greyColor, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _canSend ? 1.0 : 0.4,
              child: IconButton(
                onPressed: _canSend ? _sendMessage : null,
                icon: const Icon(
                  Icons.send_rounded,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: blackColor),
        title: Text(
          'title_chat_details'.tr(),
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // تماس تلفنی
            },
            icon: const Icon(Icons.call_outlined, color: blackColor),
          ),
          customPopUpMenu(
            context: context,
            chatroomId: widget.chatroomId,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatStream(
              chatroomId: widget.chatroomId,
            ),
          ),
          _buildBottomInputField(),
        ],
      ),
    );
  }
}
