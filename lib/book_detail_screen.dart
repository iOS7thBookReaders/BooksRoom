import 'package:books_room/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_provider.dart';
import 'format.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookISBN;
  const BookDetailScreen({super.key, required this.bookISBN});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isFavorite = false; // Firebase 상태값 받아오기
  bool isReading = false; // Firebase 상태값 받아오기
  bool isReviewing = false; // Firebase 상태값 받아오기
  bool isDataLoaded = false; // 데이터가 이미 로드되었는지 여부 체크

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      if (!isDataLoaded) {
        bookProvider.fetchBookDetail(widget.bookISBN).then((_) {
          // 데이터 로딩이 완료된 후에 setState()를 호출하여 화면 갱신
          setState(() {
            isDataLoaded = true; // 데이터를 이미 로드했으므로 상태를 true로 설정
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Format format = Format();
    final bookProvider = Provider.of<BookProvider>(context);
    final bookDetailData = bookProvider.bookDetailData;

    // 처음에 'null'을 찍는 대신에 bookDetailData가 null일 때만 출력하도록 조건 추가
    if (bookDetailData == null) {
      print('📍 데이터 로딩 중...');
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 데이터가 비어있는 경우 처리
    if (bookDetailData.items!.isEmpty) {
      return Scaffold(body: Center(child: Text('존재하지 않는 책입니다.')));
    }

    print('📍 데이터 로드 완료: $bookDetailData'); // 데이터 로드 성공 후 한번만 출력

    final title = bookDetailData.items?[0].title ?? '제목 없음';
    final formattedTitle = format.formatTitle(title)[0];
    final subtitle =
        format.formatTitle(title).length > 1
            ? format.formatTitle(title)[1]
            : '';
    final author = bookDetailData.items?[0].author ?? '저자 정보 없음';
    final category = bookDetailData.items?[0].categoryName ?? '카테고리 정보 없음';
    final formattedCategories = format.formatCategoryName(category);
    final itemPage = bookDetailData.items?[0].subInfo?.itemPage ?? 0;
    final publisher = bookDetailData.items?[0].publisher ?? '출판사 정보 없음';
    final cover = bookDetailData.items?[0].cover ?? '';
    final pubDate = bookDetailData.items?[0].pubDate ?? '';
    final formattedPubDate = format.formatYearFromPubDate(pubDate);
    final description = bookDetailData.items?[0].description ?? '설명 없음';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Book Detail'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedTitle,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: subtitle,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: GRAY900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: formattedPubDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              infoRow('저자', author ?? ''),
                              SizedBox(height: 2),
                              infoRow('카테고리', formattedCategories),
                              SizedBox(height: 2),
                              infoRow('쪽수', itemPage.toString()),
                              SizedBox(height: 2),
                              infoRow('출판사', publisher ?? ''),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Image.network(
                            cover,
                            width: 130,
                            height: 150,
                            loadingBuilder: (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // 이미지 로딩 완료
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 5; i++)
                          Icon(
                            Icons.star_outline_outlined,
                            color: GRAY200_LINE,
                            size: 50,
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '작품 정보',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(description, style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline_outlined,
                          size: 30,
                          color: isFavorite ? POINT_COLOR : GRAY900,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                            // firebase 업데이트
                          });
                        },
                      ),
                      Text(
                        '찜',
                        style: TextStyle(
                          fontSize: 13,
                          color: isFavorite ? POINT_COLOR : GRAY900,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  // 읽는중
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.book_fill,
                          size: 30,
                          color: isReading ? POINT_COLOR : GRAY900,
                        ),
                        onPressed: () {
                          setState(() {
                            isReading = !isReading;
                            // firebase 업데이트
                          });
                        },
                      ),
                      Text(
                        '읽는중',
                        style: TextStyle(
                          fontSize: 13,
                          color: isReading ? POINT_COLOR : GRAY900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  // 독후감
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_note_rounded,
                          size: 30,
                          color: isReviewing ? POINT_COLOR : GRAY900,
                        ),
                        onPressed: () {
                          setState(() {
                            isReviewing = !isReviewing;
                            // firebase 업데이트
                          });
                        },
                      ),
                      Text(
                        '독후감',
                        style: TextStyle(
                          fontSize: 13,
                          color: isReviewing ? POINT_COLOR : GRAY900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: GRAY900),
          ),
        ),
        const SizedBox(width: 8),
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
