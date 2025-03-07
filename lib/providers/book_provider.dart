// ignore_for_file: avoid_print

import 'package:books_room/services/api_service.dart';
import 'package:books_room/key.dart';
import 'package:flutter/material.dart';
import '../models/book_request.dart';
import '../models/book_response.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  BookResponse? _booksBestsellerData;
  BookResponse? _bookDetailData;

  bool _isLoading = true;
  BookResponse? get bookDetailData => _bookDetailData;
  BookResponse? get booksBestsellerData => _booksBestsellerData;

  bool get isLoading => _isLoading;

  Future<void> fetchBookBestseller() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.fetchBookBestseller(
        BookRequestModel(
          ttbKey: API_KEY,
          queryType: 'Bestseller',
          maxResults: 20,
          start: 1,
          searchTarget: 'Book',
          output: 'JS',
          version: '20131101',
        ),
      );

      _booksBestsellerData = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching bestseller: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookDetail(String stringISBN) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.fetchBookDetail(
        BookRequestModel(
          ttbKey: API_KEY,
          output: 'JS',
          version: '20131101',
          itemIdType: 'ISBN13',
          itemId: stringISBN,
          cover: 'MidBig',
        ),
      );

      _bookDetailData = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching book details: $e");
      _isLoading = false;
      notifyListeners();
    }
  }
}
