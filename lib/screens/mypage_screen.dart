// ignore_for_file: avoid_print

import 'package:books_room/screens/my_review_screen.dart';
import 'package:books_room/services/book_firebase_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:books_room/services/auth_service.dart';
import 'package:books_room/screens/login_screen.dart';
import 'package:books_room/components/color.dart';

import '../components/format.dart';
import '../models/book_model.dart';
import '../services/review_firebase_service.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final ReviewFirebaseService _reviewFirebaseService = ReviewFirebaseService();

  // 읽고 있는 책 목록을 저장할 변수
  List<BookModel> _readingBooks = [];
  List<BookModel> _wishingBooks = [];
  List<BookModel> _reviewBooks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReadingBooks();
      _loadWishingBooks();
      _loadReviewBooks();
    });
  }

  // 읽고 있는 책 로드 메서드
  void _loadReadingBooks() {
    _reviewFirebaseService.getReadingBooks().listen((books) {
      setState(() {
        _readingBooks = books;
      });
    });
  }

  // 리뷰 책 로드 메서드
  void _loadReviewBooks() {
    _reviewFirebaseService.getReviewBooks().listen((books) {
      setState(() {
        _reviewBooks = books;
      });
    });
  }

  // 찜한 책 로드 메서드
  void _loadWishingBooks() {
    _reviewFirebaseService.getWishingBooks().listen((books) {
      setState(() {
        _wishingBooks = books;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firebase 서비스 인스턴스 생성
    //// 로그아웃을 위한 인스턴스
    final authService = AuthService();
    final userEmailString = authService.currentUser?.email ?? '';
    final userCreateDateString =
        authService.currentUser?.metadata.creationTime.toString() ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    CupertinoIcons.person_circle_fill,
                    size: 80,
                    color: GRAY300_DISABLE,
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: POINT_COLOR,
                        ),
                        child: Text(
                          '사용자 정보',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Text(userEmailString, style: TextStyle(fontSize: 18)),
                      Text(
                        Format().formaDate(userCreateDateString),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: GRAY200_LINE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: infoRow('독후감 작성', '${_reviewBooks.length} 건'),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: GRAY700,
                    ),
                    onTap: () {
                      print('독후감 작성 목록');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MyReviewScreen(
                                title: '독후감 목록',
                                items: _reviewBooks,
                              ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: infoRow('읽는 중인 책', '${_readingBooks.length} 권'),
                  ),
                  ListTile(title: infoRow('찜한 책', '${_wishingBooks.length} 권')),
                ],
              ),
            ),
            // 로그아웃 버튼
            Spacer(),
            TextButton(
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
              child: const Text('로그아웃', style: TextStyle(color: GRAY500)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GRAY900,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: GRAY900),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
