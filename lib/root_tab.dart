import 'package:books_room/color.dart';
import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';

class RootTab extends StatefulWidget {
  const RootTab({super.key});

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;

  int index = 0;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);

    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: MAIN_COLOR,
        unselectedItemColor: GRAY500,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
          print(index);
          setState(() {
            this.index = index;
          });
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: (Icon(Icons.person_2_outlined)),
            label: '마이페이지',
          ),
        ],
      ),
      body: TabBarView(
        // 화면 swipe로 tab변경 안됨
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: [HomeScreen(), CalendarScreen(), MypageScreen()],
      ),
    );
  }
}
