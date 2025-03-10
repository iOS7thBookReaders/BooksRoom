// ignore_for_file: avoid_print

import 'package:books_room/services/api_service.dart';
import 'package:books_room/key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:books_room/models/book_request.dart';
import 'package:books_room/models/book_response.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  BookResponse? _booksBestsellerData;
  BookResponse? _bookDetailData;
  BookResponse? _bookSearchData;
  int currentPage = 0;
  int totalCount = 0;
  bool _isLoading = true;
  bool hasMore = true;
  BookResponse? get bookDetailData => _bookDetailData;
  BookResponse? get booksBestsellerData => _booksBestsellerData;
  BookResponse? get bookSearchData => _bookSearchData;

  bool get isLoading => _isLoading;

  void resetSearchData() {
    _bookSearchData = null;
    notifyListeners();
  }

  void resetBookDetailData() {
    _bookDetailData = null;
    notifyListeners(); // 상태 변경을 알리기 위해 호출
  }

  Future<void> fetchBookBestseller(int page) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.fetchBookBestseller(
        BookRequestModel(
          ttbKey: API_KEY,
          queryType: 'Bestseller',
          maxResults: 20,
          start: page,
          searchTarget: 'Book',
          output: 'JS',
          version: '20131101',
        ),
      );
      // 응답에 아이템 없고 비어있으면 더 불러올 데이터가 없다는 거고
      if (response.items == null || response.items!.isEmpty) {
        hasMore = false;
      } else {
        // 응답에 아이템이 있으면 데이터가 더 있다는거
        hasMore = true;
        if (_booksBestsellerData == null) {
          // 처음 fetch하는거면 당연히 베스트셀러 데이터가 비어있겠지
          // 응답값을 넣어
          _booksBestsellerData = response;
        } else {
          // 처음 fetch가 아니면 이미 items에 데이터가 있겠지 response.items 배열에 추가
          _booksBestsellerData?.items!.addAll(response.items!);
        }
        // 추가되어서 데이터가 20 40 60 ... 이렇게 늘어나겠지
        print(_booksBestsellerData?.items!.length);
        _isLoading = false;
        currentPage++;
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
          start: 1,
          searchTarget: 'Book',
        ),
      );
      // 응답에 아이템 없고 비어있으면 더 불러올 데이터가 없다는 거고
      if (response.items == null || response.items!.isEmpty) {
        hasMore = false;
      } else {
        // 응답에 아이템이 있으면 데이터가 더 있다는거
        hasMore = true;
        if (_bookSearchData == null) {
          // 처음 fetch하는거면 당연히 베스트셀러 데이터가 비어있겠지
          // 응답값을 넣어
          _bookSearchData = response;
        } else {
          // 처음 fetch가 아니면 이미 items에 데이터가 있겠지 response.items 배열에 추가
          _bookSearchData?.items!.addAll(response.items!);
        }
        // 추가되어서 데이터가 20 40 60 ... 이렇게 늘어나겠지
        print(_bookSearchData?.items!.length);
        _isLoading = false;
        currentPage++;
      }
      notifyListeners();
      return _bookSearchData;
    } catch (e) {
      print("Error fetching search results: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
