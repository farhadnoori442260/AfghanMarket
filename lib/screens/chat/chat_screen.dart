import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/screens/category/category_list_screen.dart';
import 'package:kalino_app/screens/chat/widgets/chat_card.dart';
import 'package:kalino_app/screens/main_navigation_screen.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class ChatScreen extends StatefulWidget {
  static const String screenId = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Auth _authService = Auth();
  final UserService _firebaseUser = UserService();

  PreferredSizeWidget _buildBottomBar() {
    return TabBar(
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      labelColor: primaryColor,
      unselectedLabelColor: greyColor,
      indicatorColor: secondaryColor,
      tabs: [
        Tab(text: 'tab_all'.tr()),
        Tab(text: 'tab_buying'.tr()),
        Tab(text: 'tab_selling'.tr()),
      ],
    );
  }

  Widget _buildChatList({
    required Stream<QuerySnapshot> stream,
    required String emptyMsgKey,
    required String actionBtnKey,
    required VoidCallback onAction,
    String? filterType, // 'buying' or 'selling'
  }) {
    final String currentUid = _firebaseUser.user?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('msg_error_loading'.tr()));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: secondaryColor),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(emptyMsgKey, actionBtnKey, onAction);
        }

        // فیلتر کردن گفت‌وگوها بر اساس نوع خرید/فروش در صورت نیاز
        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final sellerUid = data['product']?['seller'];

          if (filterType == 'buying') {
            return sellerUid != currentUid;
          } else if (filterType == 'selling') {
            return sellerUid == currentUid;
          }
          return true;
        }).toList();

        // مرتب‌سازی چت‌ها بر اساس آخرین زمان چت (نزولی)
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['lastChatTime'] ?? 0;
          final bTime = (b.data() as Map<String, dynamic>)['lastChatTime'] ?? 0;
          return bTime.compareTo(aTime);
        });

        if (docs.isEmpty) {
          return _buildEmptyState(emptyMsgKey, actionBtnKey, onAction);
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return ChatCard(data: data);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String msgKey, String btnKey, VoidCallback onAction) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: greyColor,
            ),
            const SizedBox(height: 16),
            Text(
              msgKey.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: greyColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onAction,
              child: Text(
                btnKey.tr(),
                style: const TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_firebaseUser.user == null) {
      return Center(
        child: Text(
          'msg_login_required'.tr(),
          style: const TextStyle(fontSize: 16, color: blackColor),
        ),
      );
    }

    final String currentUid = _firebaseUser.user!.uid;
    final Stream<QuerySnapshot> baseStream = _authService.messages
        .where('users', arrayContains: currentUid)
        .snapshots();

    return TabBarView(
      children: [
        // تب ۱: همه چت‌ها
        _buildChatList(
          stream: baseStream,
          emptyMsgKey: 'msg_no_chats_all',
          actionBtnKey: 'btn_explore_products',
          onAction: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (c) => const MainNavigationScreen()),
              (route) => false,
            );
          },
        ),

        // تب ۲: چت‌های خرید
        _buildChatList(
          stream: baseStream,
          filterType: 'buying',
          emptyMsgKey: 'msg_no_chats_buying',
          actionBtnKey: 'btn_explore_products',
          onAction: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (c) => const MainNavigationScreen()),
              (route) => false,
            );
          },
        ),

        // تب ۳: چت‌های فروش
        _buildChatList(
          stream: baseStream,
          filterType: 'selling',
          emptyMsgKey: 'msg_no_chats_selling',
          actionBtnKey: 'btn_add_product',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => const CategoryListScreen(isForForm: true),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: whiteColor,
          iconTheme: const IconThemeData(color: blackColor),
          title: Text(
            'title_chats'.tr(),
            style: const TextStyle(
              color: blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: _buildBottomBar(),
        ),
        body: _buildBody(),
      ),
    );
  }
}
