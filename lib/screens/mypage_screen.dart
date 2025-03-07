// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:books_room/services/auth_service.dart';
import 'package:books_room/screens/login_screen.dart';
import 'package:books_room/color.dart';

// 임시 임포트
import 'package:books_room/screens/review_screen.dart';
import 'package:books_room/services/review_firebase_service.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase 서비스 인스턴스 생성
    final reviewFirebaseService = ReviewFirebaseService(); // 리뷰화면을 위한 임시 코드
    final authService = AuthService(); // 로그아웃을 위한 인스턴스

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MypageScreen'),
            SizedBox(height: 20),

            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                // 먼저 context를 안전하게 저장
                final navigatorContext = context;

                // 로그아웃 실행
                await authService.signOut();

                // 컨텍스트가 아직 유효한지 확인 후 내비게이션
                if (navigatorContext.mounted) {
                  Navigator.pushReplacement(
                    navigatorContext,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: MAIN_COLOR),
              child: const Text('로그아웃'),
            ),
            SizedBox(height: 20),

            // 임시로 리뷰 화면으로 이동하는 코드 구현 (도서정보화면 구현 후 삭제 예정)
            ElevatedButton(
              onPressed: () async {
                // 사용자 ID와 ISBN 더미데이터
                String userId = 'test123@gmail.com';
                String isbn13 = '9791193992258';
                print('리뷰 화면 이동 시작 - 사용자: $userId, ISBN: $isbn13');

                // 책 정보 가져오기
                final bookStream = reviewFirebaseService.getBookByIsbn(isbn13);

                // 스트림에서 첫 번째 이벤트(책 정보)를 가져옴
                final bookModel = await bookStream.first;
                print('가져온 책 정보: ${bookModel?.title ?? "정보 없음"}');

                if (bookModel != null) {
                  // 책 정보가 있으면 리뷰 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ReviewScreen(
                            bookModel: bookModel,
                            firebaseService: reviewFirebaseService,
                          ),
                    ),
                  );
                } else {
                  // 책 정보가 없을 경우 스낵바 표시
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('책 정보를 불러올 수 없습니다.')));
                }
              },
              child: const Text('책 리뷰 쓰러가기'),
            ),
          ],
        ),
      ),
    );
  }
}
