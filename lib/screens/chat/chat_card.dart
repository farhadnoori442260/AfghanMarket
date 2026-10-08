import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/screens/chat/user_chat_screen.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class ChatCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const ChatCard({Key? key, required this.data}) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final UserService _firebaseUser = UserService();
  final Auth _authService = Auth();

  DocumentSnapshot? _document;
  String _lastChatDate = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProductDetails();
    _getChatTime();
  }

  void _getProductDetails() {
    final String? productId = widget.data['product']?['product_id'];
    if (productId != null && productId.isNotEmpty) {
      _firebaseUser.getProductDetails(productId).then((value) {
        if (mounted) {
          setState(() {
            _document = value;
            _isLoading = false;
          });
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getChatTime() {
    final int? lastChatTime = widget.data['lastChatTime'];
    if (lastChatTime == null) return;

    final DateTime chatDateTime = DateTime.fromMicrosecondsSinceEpoch(lastChatTime);
    final String date = DateFormat.yMMMd().format(chatDateTime);
    final String today = DateFormat.yMMMd().format(DateTime.now());

    if (date == today) {
      setState(() {
        _lastChatDate = 'label_today'.tr();
      });
    } else {
      setState(() {
        _lastChatDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: whiteColor,
        height: 70,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
          ),
        ),
      );
    }

    final productMap = _document?.data() as Map<String, dynamic>?;
    final List images = productMap?['images'] ?? [];
    final String imageUrl = images.isNotEmpty ? images[0] : '';
    final String title = productMap?['title'] ?? widget.data['product']?['title'] ?? '';
    final bool isUnread = widget.data['read'] == false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: whiteColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: () {
          if (isUnread) {
            _authService.messages.doc(widget.data['chatroomId']).update({
              'read': true,
            });
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => UserChatScreen(
                chatroomId: widget.data['chatroomId'],
              ),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 55,
            height: 55,
            color: Colors.grey.shade100,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: greyColor),
                  )
                : const Icon(Icons.image, color: greyColor),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                  color: blackColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _lastChatDate,
              style: TextStyle(
                fontSize: 11,
                color: isUnread ? primaryColor : greyColor,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            widget.data['lastChat'] ?? 'msg_no_messages_yet'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isUnread ? blackColor : greyColor,
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        trailing: customPopUpMenu(
          context: context,
          chatroomId: widget.data['chatroomId'],
        ),
      ),
    );
  }
}
