// ignore_for_file: avoid_print

import 'package:books_room/services/api_service.dart';
import 'package:books_room/key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:books_room/models/book_request.dart';
import 'package:books_room/models/book_response.dart';
import 'package:books_room/services/cached_api_service.dart';

import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CachedBestsellerService _cachedBestsellerService =
      CachedBestsellerService();

  BookResponse? _booksBestsellerData;
  BookResponse? _bookDetailData;
  BookResponse? _bookSearchData;

  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth 인스턴스 - 현재 로그인한 사용자 확인용
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 사용자 이메일 가져오기
  String? get currentUserEmail => _auth.currentUser?.email;

  // 사용자 컬렉션 참조
  CollectionReference get usersCollection => _firestore.collection('users');

  // 현재 사용자의 책 컬렉션 참조
  CollectionReference? get currentUserBooks {
    final email = currentUserEmail;
    if (email == null) return null;
    return usersCollection.doc(email).collection('books');
  }

  int totalCount = 0;
  bool _isLoading = true;
  BookResponse? get bookDetailData => _bookDetailData;
  BookResponse? get booksBestsellerData => _booksBestsellerData;
  BookResponse? get bookSearchData => _bookSearchData;

  bool get isLoading => _isLoading;

  void resetSearchData() {
    _bookSearchData = null;
    notifyListeners();
  }

  Future<void> fetchBookBestseller() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 먼저 캐시된 데이터가 오늘 날짜인지 확인
      bool isTodaysCacheAvailable =
          await _cachedBestsellerService.isCachedDataFromToday();

      if (isTodaysCacheAvailable) {
        // 2. 오늘 캐시된 데이터가 있으면 로드
        print("오늘의 캐시된 베스트셀러 데이터를 사용합니다.");
        final cachedData =
            await _cachedBestsellerService.loadCachedBestseller();
        if (cachedData != null) {
          _booksBestsellerData = cachedData;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 3. 캐시된 데이터가 없거나 오늘 날짜가 아니면 API 호출
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

      // 4. 성공적으로 받아온 데이터를 캐시에 저장
      if (_booksBestsellerData != null && _booksBestsellerData!.items != null) {
        await _cachedBestsellerService.cacheBestseller(_booksBestsellerData!);
        print("베스트셀러 데이터를 캐시에 저장했습니다.");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching bestseller from API: $e");

      // 5. API 호출 실패 시 가장 최근 캐시된 데이터 사용
      final cachedData = await _cachedBestsellerService.loadCachedBestseller();
      if (cachedData != null) {
        print("API 호출 실패. 캐시된 베스트셀러 데이터를 사용합니다.");
        _booksBestsellerData = cachedData;
      } else {
        print("캐시된 데이터도 없습니다. 오류 상태로 설정합니다.");
      }

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
      if (response.items != null && response.items!.isNotEmpty) {
        _bookSearchData = response;
      } else {
        _bookSearchData = null;
      }
      totalCount = response.totalResults;

      _isLoading = false;
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
