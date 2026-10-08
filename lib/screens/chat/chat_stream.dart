import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:intl/intl.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class ChatStream extends StatefulWidget {
  final String? chatroomId;

  const ChatStream({Key? key, this.chatroomId}) : super(key: key);

  @override
  State<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  Stream<QuerySnapshot>? _changeMessageStream;
  DocumentSnapshot? _chatDocument;
  final Auth _authService = Auth();
  final UserService _firebaseUser = UserService();

  @override
  void initState() {
    super.initState();
    _initChatData();
  }

  void _initChatData() {
    if (widget.chatroomId == null) return;

    _firebaseUser.getChatDetails(chatroomId: widget.chatroomId).then((value) {
      if (mounted) {
        setState(() {
          _changeMessageStream = value;
        });
      }
    });

    _authService.messages.doc(widget.chatroomId).get().then((value) {
      if (mounted && value.exists) {
        setState(() {
          _chatDocument = value;
        });
      }
    });
  }

  String _formatMessageTime(int? timestamp) {
    if (timestamp == null) return '';
    final messageDate = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    final String formattedDate = DateFormat.yMMMd().format(messageDate);
    final String todayDate = DateFormat.yMMMd().format(DateTime.now());

    if (formattedDate == todayDate) {
      return DateFormat('HH:mm').format(messageDate);
    } else {
      return DateFormat('yyyy/MM/dd - HH:mm').format(messageDate);
    }
  }

  Widget _buildProductBanner(Map<String, dynamic> product) {
    final String imgUrl = product['product_img'] ?? '';
    final String title = product['title'] ?? '';
    final dynamic priceValue = product['price'];
    final String priceStr = priceValue != null
        ? intToStringFormatter(int.tryParse(priceValue.toString()) ?? 0)
        : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 45,
              height: 45,
              color: Colors.grey.shade100,
              child: imgUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 20, color: greyColor),
                    )
                  : const Icon(Icons.image, color: greyColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: blackColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$priceStr ${'currency_afn'.tr()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: StreamBuilder<QuerySnapshot>(
        stream: _changeMessageStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('msg_error_loading'.tr()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: secondaryColor),
            );
          }

          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final chatData = _chatDocument?.data() as Map<String, dynamic>?;
          final product = chatData?['product'] as Map<String, dynamic>?;

          return Column(
            children: [
              if (product != null) _buildProductBanner(product),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final docData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final String sentBy = docData['sent_by'] ?? '';
                    final String myId = _firebaseUser.user?.uid ?? '';
                    final bool isMe = sentBy == myId;
                    final String timeText = _formatMessageTime(docData['time']);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          ChatBubble(
                            clipper: ChatBubbleClipper5(
                              type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble,
                            ),
                            alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                            backGroundColor: isMe ? primaryColor : whiteColor,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.72,
                              ),
                              child: Text(
                                docData['message'] ?? '',
                                style: TextStyle(
                                  color: isMe ? whiteColor : blackColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: EdgeInsets.only(
                              left: isMe ? 0 : 12,
                              right: isMe ? 12 : 0,
                            ),
                            child: Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
