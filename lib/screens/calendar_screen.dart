import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/book_list_cell.dart';
import '../models/book_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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

                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  // 선택된 날짜의 상태를 갱신합니다.
                  setState(() {
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
                },
                selectedDayPredicate: (DateTime day) {
                  // selectedDay 와 동일한 날짜의 모양을 바꿔줍니다.
                  return isSameDay(selectedDay, day);
                },
                // eventLoader: _fetchBookEvents,
              ),

              ListView.builder(
                shrinkWrap: true,
                itemCount: 30,
                itemBuilder: (context, index) {
                  return const Text('data');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List<BookModel> _fetchBookEvents() {
  //   return [BookModel()];
  // }
}
