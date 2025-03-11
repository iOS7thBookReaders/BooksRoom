// ignore_for_file: avoid_print

import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/book_model.dart';
import '../services/review_firebase_service.dart';
import '../screens/book_detail_screen.dart';

class MyReadingScreen extends StatefulWidget {
  final List<BookModel> items;
  final String title;

  MyReadingScreen({super.key, required this.title, required this.items});

  @override
  State<MyReadingScreen> createState() => _MyReadingScreenState();
}

class _MyReadingScreenState extends State<MyReadingScreen> {
  late List<BookModel> _items;
  final ReviewFirebaseService _reviewFirebaseService = ReviewFirebaseService();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  // 읽는 중 삭제 메서드
  Future<void> _deleteWishing(BookModel book) async {
    try {
      // 읽는 중 정보 초기화
      final updatedBook = book.copyWith(isReading: false);

      // Firebase에 업데이트
      await _reviewFirebaseService.updateBook(updatedBook);

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('읽고 있는 책에서 삭제되었습니다')));
      }
    } catch (e) {
      print('리뷰 삭제 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')));
      }
      // 오류 발생 시 삭제한 항목 다시 추가 (UI 복원)
      setState(() {
        _items.add(book);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            _items.isEmpty
                ? Center(child: Text('읽고 있는 책이 없습니다'))
                : ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1, color: GRAY200_LINE);
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_items[index].isbn13), // 각 항목의 고유 키
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction:
                          DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프 허용
                      confirmDismiss: (direction) async {
                        // 삭제 확인 다이얼로그
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('읽는 책 삭제'),
                              content: Text('읽는 중 목록에서 삭제하시겠습니까?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text(
                                    '삭제',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        // 항목 삭제 처리
                        final deletedItem = _items[index];
                        setState(() {
                          _items.removeAt(index);
                        });
                        _deleteWishing(deletedItem);
                      },
                      child: _buildWishingCell(_items[index]),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildWishingCell(BookModel item) {
    return GestureDetector(
      onTap: () {
        // 리뷰 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookISBN: item.isbn13),
          ),
        ).then((_) {
          // 리뷰 화면에서 돌아왔을 때 데이터 다시 로드
          setState(() {
            _items = List.from(widget.items);
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 커버 이미지
            Container(
              width: 50,
              height: 70,
              margin: const EdgeInsets.only(right: 12),
              child:
                  item.coverUrl != null && item.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: item.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: MAIN_COLOR.withAlpha(0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    MAIN_COLOR.withAlpha(0),
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: GRAY200_LINE,
                              child: Icon(Icons.book, color: GRAY500),
                            ),
                      )
                      : Container(
                        color: GRAY200_LINE,
                        child: Icon(Icons.book, color: GRAY500),
                      ),
            ),
            // 책 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.publisher,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
