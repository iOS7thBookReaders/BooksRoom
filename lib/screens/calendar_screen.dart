import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CalendarScreen'),
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
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
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
