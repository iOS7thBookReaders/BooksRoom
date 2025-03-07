// ignore_for_file: avoid_print

import 'package:books_room/api_service.dart';
import 'package:books_room/key.dart';
import 'package:flutter/material.dart';
import 'book_request.dart';
import 'book_response.dart'; // 위에서 정의한 모델 클래스

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  BookResponse? _bookData;
  bool _isLoading = true;
  String year = '';
  String month = '';
  String week = '';

  BookResponse? get bookData => _bookData;
  bool get isLoading => _isLoading;

  void get dateFormatted {
    final now = DateTime.now();
    year = now.year.toString();
    month = now.month.toString();

    // 오늘 몇째주차인지 계산
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysDifference = now.difference(firstDayOfYear).inDays;
    final weekNumber = ((daysDifference / 7).floor()) + 1;

    week = weekNumber.toString();
    return;
  }

  Future<void> fetchBookBestseller() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.fetchBookBestseller(
        BookRequestModel(
          // API 요청에 필요한 파라미터를 설정
          ttbKey: API_KEY,
          queryType: 'Bestseller',
          maxResults: 20,
          start: 1,
          searchTarget: 'Book',
          output: 'JS',
          version: '20131101',
          year: year,
          month: month,
          week: week,
        ),
      );

      _bookData = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
