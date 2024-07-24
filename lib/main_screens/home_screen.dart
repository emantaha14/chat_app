import 'package:chat_app/main_screens/chats_list_screen.dart';
import 'package:chat_app/main_screens/people_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'groups_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController(initialPage: 0);

  int _selectedTab = 0;
  final List<Widget> pages = const [
    ChatsListScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter chat app'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
            ),
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        children: pages

      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: 'people',
          ),
        ],
        currentIndex: _selectedTab,
        onTap: (index) {
          pageController.animateToPage(
              index, duration: const Duration(milliseconds: 200),
              curve: Curves.bounceIn);
          setState(() {
            _selectedTab = index;
          });
          print(index);
        },
      ),
    );
  }
}
