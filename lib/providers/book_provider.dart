// ignore_for_file: avoid_print

import 'package:books_room/services/api_service.dart';
import 'package:books_room/key.dart';
import 'package:flutter/material.dart';
import 'package:books_room/models/book_request.dart';
import 'package:books_room/models/book_response.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  BookResponse? _booksBestsellerData;
  BookResponse? _bookDetailData;
  BookResponse? _bookSearchData;
  int totalCount = 0;
  bool _isLoading = true;
  bool hasMoreData = true;
  int currentPage = 1;
  final int pageSize = 20;

  BookResponse? get bookDetailData => _bookDetailData;
  BookResponse? get booksBestsellerData => _booksBestsellerData;
  BookResponse? get bookSearchData => _bookSearchData;
  bool get isLoading => _isLoading;
  bool get hasMore => hasMoreData;

  void resetSearchData() {
    _bookSearchData = null;
    notifyListeners();
  }

  void resetBookDetailData() {
    _bookDetailData = null;
    notifyListeners(); // 상태 변경을 알리기 위해 호출
  }

  void resetPagination() {
    currentPage = 1;
    _booksBestsellerData = null;
    hasMoreData = true;
  }

  Future<void> fetchBookBestseller(int page) async {
    // 로딩중 && 데이터 더 없음
    if (_isLoading || !hasMoreData) return;
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

      if (response.items == null || response.items!.isEmpty) {
        hasMoreData = false;
      } else {
        _booksBestsellerData = response;
        _isLoading = false;
        currentPage = page;
        totalCount = response.totalResults;
      }
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

  Future<BookResponse?> fetchSearchResult(
    String query,
    String? queryType,
    String? sort,
    int page,
  ) async {
    if (_isLoading || !hasMoreData) return null;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.fetchSearchResult(
        BookRequestModel(
          ttbKey: API_KEY,
          output: 'JS',
          version: '20131101',
          query: query,
          queryType: queryType,
          sort: sort,
          maxResults: 20,
          start: page,
          searchTarget: 'Book',
        ),
      );
      if (response.items != null && response.items!.isNotEmpty) {
        _bookSearchData = response;
      } else {
        _bookSearchData!.items!.addAll(response.items!);
      }
      totalCount = response.totalResults;
      currentPage++;
      if (_bookSearchData!.items!.length >= _bookSearchData!.totalResults) {
        hasMoreData = false; // 더 이상 데이터가 없으면 hasMoreData를 false로 설정
      }

      _isLoading = false;
      notifyListeners(); // 상태 업데이트
    } catch (e) {
      print('Error fetching search result: $e');
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
