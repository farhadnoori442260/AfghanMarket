import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/screens/category/category_list_screen.dart';
import 'package:kalino_app/screens/chat/chat_screen.dart';
import 'package:kalino_app/screens/home_screen.dart';
import 'package:kalino_app/screens/post/my_post_screen.dart';
import 'package:kalino_app/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String screenId = 'main_nav_screen';

  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final PageController _pageController;
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      const HomeScreen(),
      const ChatScreen(),
      const CategoryListScreen(isForForm: true),
      const MyPostScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: DotNavigationBar(
        backgroundColor: blackColor,
        margin: EdgeInsets.zero,
        paddingR: EdgeInsets.zero,
        selectedItemColor: secondaryColor,
        currentIndex: _index,
        dotIndicatorColor: Colors.transparent,
        unselectedItemColor: disabledColor,
        enablePaddingAnimation: true,
        enableFloatingNavBar: false,
        onTap: (index) {
          setState(() {
            _index = index;
          });
          _pageController.jumpToPage(index);
        },
        items: [
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _index == 0 ? whiteColor : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.home,
                color: _index == 0 ? secondaryColor : disabledColor,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _index == 1 ? whiteColor : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.chat,
                color: _index == 1 ? secondaryColor : disabledColor,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _index == 2 ? whiteColor : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.add,
                color: _index == 2 ? secondaryColor : disabledColor,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _index == 3 ? whiteColor : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                _index == 3 ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: _index == 3 ? secondaryColor : disabledColor,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _index == 4 ? whiteColor : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.person,
                color: _index == 4 ? secondaryColor : disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView.builder(
        itemCount: _pages.length,
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _index = page;
          });
        },
        itemBuilder: (context, position) {
          return _pages[position];
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
