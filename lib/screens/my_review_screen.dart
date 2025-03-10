// ignore_for_file: avoid_print

import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/review_firebase_service.dart';

class MyReviewScreen extends StatefulWidget {
  final List<BookModel> items;
  final String title;

  MyReviewScreen({super.key, required this.title, required this.items});

  @override
  State<MyReviewScreen> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends State<MyReviewScreen> {
  late List<BookModel> _items;
  final ReviewFirebaseService _reviewFirebaseService = ReviewFirebaseService();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  // 리뷰 삭제 메서드
  Future<void> _deleteReview(BookModel book) async {
    try {
      // 리뷰 정보 초기화
      final updatedBook = book.copyWith(
        review: '',
        oneLineComment: '',
        starRating: 0,
        isReviewed: false,
        readEndDate: '',
      );

      // Firebase에 업데이트
      await _reviewFirebaseService.updateBook(updatedBook);

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('리뷰가 삭제되었습니다')));
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
                ? Center(child: Text('리뷰가 없습니다'))
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
                              title: Text('리뷰 삭제'),
                              content: Text('이 리뷰를 삭제하시겠습니까?'),
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
                        _deleteReview(deletedItem);
                      },
                      child: _buildReviewCell(_items[index]),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildReviewCell(BookModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              Text(
                item.author,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${item.oneLineComment}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    if (i < item.starRating!)
                      const Icon(Icons.star, color: MAIN_COLOR, size: 20)
                    else
                      const Icon(
                        Icons.star_outline_outlined,
                        color: GRAY300_DISABLE,
                        size: 20,
                      ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
