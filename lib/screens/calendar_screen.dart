// ignore_for_file: avoid_print

import 'package:books_room/components/color.dart';
import 'package:books_room/screens/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/book_model.dart';
import '../services/review_firebase_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReviewFirebaseService _reviewFirebaseService = ReviewFirebaseService();
  List<BookModel> bookList = [];
  bool _isBooksLoading = true;

  // 리뷰가 있는 날짜를 저장할 맵 추가
  Map<DateTime, List<BookModel>> _eventsMap = {};

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
    _loadAllReviews(); // 모든 리뷰 날짜 로드
  }

  // 선택된 날짜에 맞는 책 로드
  void _loadCalendarData() {
    _reviewFirebaseService.getBooksMatchWithCalendar(selectedDay).listen((
      books,
    ) {
      setState(() {
        bookList = books;
        _isBooksLoading = false;
      });
    });
  }

  // 모든 리뷰 데이터 로드하여 이벤트 맵 생성
  void _loadAllReviews() {
    _reviewFirebaseService.getReviewBooks().listen((books) {
      Map<DateTime, List<BookModel>> eventsMap = {};

      for (var book in books) {
        if (book.readEndDate != null) {
          try {
            final date = DateTime.parse(book.readEndDate!);
            // 날짜가 이미 맵에 있는지 확인
            if (eventsMap[date] != null) {
              eventsMap[date]!.add(book);
            } else {
              eventsMap[date] = [book];
            }
          } catch (e) {
            print('날짜 파싱 오류: ${book.readEndDate} - $e');
          }
        }
      }

      setState(() {
        _eventsMap = eventsMap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '캘린더',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: focusedDay,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    switch (day.weekday) {
                      case 1:
                        return Center(child: Text('월'));
                      case 2:
                        return Center(child: Text('화'));
                      case 3:
                        return Center(child: Text('수'));
                      case 4:
                        return Center(child: Text('목'));
                      case 5:
                        return Center(child: Text('금'));
                      case 6:
                        return Center(
                          child: Text(
                            '토',
                            style: TextStyle(color: Colors.blue),
                          ),
                        );
                      case 7:
                        return Center(
                          child: Text('일', style: TextStyle(color: Colors.red)),
                        );
                    }
                    return null;
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayTextStyle: const TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline, // 밑줄 추가
                  ),
                  selectedDecoration: BoxDecoration(
                    color: POINT_COLOR,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  canMarkersOverflow: false,
                  markersAlignment: Alignment.bottomCenter,
                  markersMaxCount: 1,
                  markersOffset: const PositionedOffset(),
                  // marker 모양
                  markerDecoration: const BoxDecoration(
                    color: MAIN_COLOR,
                    shape: BoxShape.circle,
                  ),
                ),
                // 이벤트 마커 표시를 위한 설정
                eventLoader: (day) {
                  // 각 날짜에 해당하는 이벤트(리뷰 목록) 반환
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return _eventsMap[normalizedDay] ?? [];
                },
                // 날짜 선택시 변경
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  setState(() {
                    bookList = [];
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
                  _loadCalendarData();
                },

                selectedDayPredicate: (DateTime day) {
                  return isSameDay(selectedDay, day);
                },
              ),
              Divider(color: GRAY200_LINE),
              ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(height: 1, color: GRAY200_LINE);
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bookList.length,
                itemBuilder: (context, index) {
                  return _buildReviewCell(bookList[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCell(BookModel item) {
    return GestureDetector(
      onTap: () {
        // 리뷰 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReviewScreen(
                  bookModel: item,
                  firebaseService: _reviewFirebaseService,
                ),
          ),
        ).then((_) {
          // 리뷰 화면에서 돌아왔을 때 데이터 다시 로드
          _loadCalendarData();
        });
      },
      child: Container(
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
      ),
    );
  }
}
