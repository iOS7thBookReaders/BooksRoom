import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:books_room/models/book_response.dart';

// 베스트셀러 캐시 설정
class CachedBestsellerService {
  static const String _cachedBestsellerKey = 'cached_bestseller';
  static const String _cachedDateKey = 'cached_bestseller_date';

  // 베스트셀러 데이터 캐싱
  Future<void> cacheBestseller(BookResponse bookResponse) async {
    final prefs = await SharedPreferences.getInstance();
    final String today =
        DateTime.now().toIso8601String().split('T')[0]; // yyyy-MM-dd 형식

    // 데이터를 JSON 문자열로 변환
    final Map<String, dynamic> dataToCache = {
      'title': bookResponse.title,
      'pubDate': bookResponse.pubDate,
      'totalResults': bookResponse.totalResults,
      'startIndex': bookResponse.startIndex,
      'itemsPerPage': bookResponse.itemsPerPage,
      'query': bookResponse.query,
      'items':
          bookResponse.items?.map((item) => _bookItemToJson(item)).toList(),
    };

    // 데이터와 날짜 저장
    await prefs.setString(_cachedBestsellerKey, jsonEncode(dataToCache));
    await prefs.setString(_cachedDateKey, today);
  }

  // 캐시된 베스트셀러 데이터 로딩
  Future<BookResponse?> loadCachedBestseller() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cachedBestsellerKey);

    if (cachedData == null) {
      return null;
    }

    try {
      final Map<String, dynamic> jsonData = jsonDecode(cachedData);
      final List<dynamic>? itemsJson = jsonData['items'];

      List<BookItem>? items;
      if (itemsJson != null) {
        items = itemsJson.map((itemJson) => _jsonToBookItem(itemJson)).toList();
      }

      return BookResponse(
        title: jsonData['title'] ?? '',
        pubDate: jsonData['pubDate'] ?? '',
        totalResults: jsonData['totalResults'] ?? 0,
        startIndex: jsonData['startIndex'] ?? 0,
        itemsPerPage: jsonData['itemsPerPage'] ?? 0,
        query: jsonData['query'],
        items: items,
      );
    } catch (e) {
      print('캐시 데이터 로딩 오류: $e');
      return null;
    }
  }

  // 캐시된 날짜 확인
  Future<String?> getCachedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedDateKey);
  }

  // 캐시된 데이터가 오늘 날짜인지 확인
  Future<bool> isCachedDataFromToday() async {
    final cachedDate = await getCachedDate();
    if (cachedDate == null) return false;

    final today = DateTime.now().toIso8601String().split('T')[0];
    return cachedDate == today;
  }

  // BookItem을 JSON으로 변환
  Map<String, dynamic> _bookItemToJson(BookItem item) {
    return {
      'title': item.title,
      'author': item.author,
      'pubDate': item.pubDate,
      'description': item.description,
      'isbn13': item.isbn13,
      'mallType': item.mallType,
      'cover': item.cover,
      'publisher': item.publisher,
      'bestDuration': item.bestDuration,
      'categoryName': item.categoryName,
      'subInfo':
          item.subInfo != null
              ? {
                'subTitle': item.subInfo!.subTitle,
                'itemPage': item.subInfo!.itemPage,
              }
              : null,
    };
  }

  // JSON을 BookItem으로 변환
  BookItem _jsonToBookItem(Map<String, dynamic> json) {
    BookSubInfo? subInfo;
    if (json['subInfo'] != null) {
      subInfo = BookSubInfo(
        subTitle: json['subInfo']['subTitle'],
        itemPage: json['subInfo']['itemPage'],
      );
    }

    return BookItem(
      title: json['title'],
      author: json['author'],
      pubDate: json['pubDate'],
      description: json['description'],
      isbn13: json['isbn13'],
      mallType: json['mallType'],
      cover: json['cover'],
      publisher: json['publisher'],
      bestDuration: json['bestDuration'],
      categoryName: json['categoryName'],
      subInfo: subInfo,
    );
  }
}
