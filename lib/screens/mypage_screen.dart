// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:books_room/services/auth_service.dart';
import 'package:books_room/screens/login_screen.dart';
import 'package:books_room/components/color.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase 서비스 인스턴스 생성
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
          ],
        ),
      ),
    );
  }
}
