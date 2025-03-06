import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // 도서 정보 변수
  final String booktitle = '채식주의자';
  final String author = '한강';
  final String publisher = '창비';
  final String publishDate = '2007년 10월 30일';
  final String genre = '장편소설, 심리소설';
  final String page = '247';
  final String bookIntro = '폭력과 아름다움의 처절한 공존\n여전히 새롭게 읽히는 한강 소설의 힘';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도서 리뷰'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 정보 섹션
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 책 표지 (임시)
                Container(
                  width: 120,
                  height: 180,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.only(right: 16.0),
                ),
                // 책 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bookInfoRow('제목', booktitle),
                      _bookInfoRow('저자', author),
                      _bookInfoRow('출판사', publisher),
                      _bookInfoRow('장르', genre),
                      _bookInfoRow('페이지', page),
                    ],
                  ),
                ),
              ],
            ), // 책 정보 섹션
            const SizedBox(height: 24.0),

            // 책 제목 및 소개 섹션
            Text(
              booktitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              bookIntro,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 24.0),

            // 리뷰 입력 섹션
            const Text(
              '리뷰',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text('내용을 입력해주세요'),
            ), // 리뷰 입력 섹션
            const SizedBox(height: 24.0),

            // 한 줄 평 입력 섹션
            const Text(
              '한 줄 평가',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text('한 줄로 평가하기'),
            ), // 한 줄 평 입력 섹션
            const SizedBox(height: 24.0),

            // 별점 섹션
            const Text(
              '별점',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const Text(
              '★★★★☆',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ), // 별점 섹션
          ],
        ),
      ),
    );
  }

  // 책 정보 행을 생성하는 헬퍼 메서드
  Widget _bookInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
