import 'package:books_room/book_detail_screen.dart';
import 'package:books_room/color.dart';
import 'package:flutter/material.dart';

import 'book_response.dart';

class BookListCell extends StatelessWidget {
  final BookItem bookItem;
  const BookListCell({super.key, required this.bookItem});

  @override
  Widget build(BuildContext context) {
    String isbn13 = bookItem.isbn13 ?? '';
    String title = bookItem.title ?? '';
    String author = bookItem.author ?? '';
    String pubdate = bookItem.pubDate ?? '';
    String publisher = bookItem.publisher ?? '';
    String cover = bookItem.cover ?? '';
    String categoryName = bookItem.categoryName ?? '';

    String extractYear(String pubDate) {
      // pubDate를 DateTime 객체로 변환
      DateTime date = DateTime.parse(pubDate);

      // 연도만 반환
      return date.year.toString();
    }

    String formatCategoryName(String categoryName) {
      // > 기준 분리
      List<String> categoryParts = categoryName.split('>');

      // 두 번째 depth만
      if (categoryParts.length > 1) {
        return categoryParts[1]; // depth2 추출
      } else {
        return categoryName; // depth2 없으면 depth1
      }
    }

    List<String> formatTitle(String title) {
      // - 기준 분리
      List<String> titleParts = title.split(' - ');
      return titleParts;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(bookISBN: isbn13),
                ),
              );
            },
            child: Row(
              children: [
                Image.network(
                  cover,
                  width: 80,
                  height: 100,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(width: 10), // 이미지와 텍스트 사이 간격
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '[${formatCategoryName(categoryName)}] ', // 연하게 만들 텍스트
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600, // 연하게 만드는 부분
                                color: GRAY500, // 연한 색 (그레이)
                              ),
                            ),
                            TextSpan(
                              text: formatTitle(title)[0], // 제목
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700, // 굵게 만드는 부분
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (formatTitle(title).length > 1)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatTitle(title)[1],
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 4), // 제목과 서브텍스트 간 간격
                      Row(
                        children: [
                          Text(author, style: TextStyle(fontSize: 12)),
                          Spacer(),
                        ],
                      ),

                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(publisher, style: TextStyle(fontSize: 12)),
                          Text(
                            ' | ${extractYear(pubdate)}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(), // 아이템 구분선
        ],
      ),
    );
  }
}
