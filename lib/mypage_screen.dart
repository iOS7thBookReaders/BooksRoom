import 'package:books_room/screens/review_screen.dart';
import 'package:flutter/material.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MypageScreen'),
            SizedBox(height: 20),
            // 임시로 리뷰 화면으로 이동하는 코드 구현 (도서정보화면 구현 후 삭제 예정)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReviewScreen()),
                );
              },
              child: const Text('책 리뷰 쓰러가기'),
            ),
          ],
        ),
      ),
    );
  }
}
