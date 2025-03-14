// ignore_for_file: avoid_print

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

  // 캐시 삭제
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedBestsellerKey);
    await prefs.remove(_cachedDateKey);
  }
}

// 상세화면 캐시 설정
class CachedBookDetailService {
  // ISBN13을 키로 사용하여 각 책마다 고유한 캐시 키 생성
  String _getCacheKey(String stringISBN) {
    return 'cached_book_detail_$stringISBN';
  }

  // 책 상세 정보 캐싱
  Future<void> cacheBookDetail(
    String stringISBN,
    BookResponse bookResponse,
  ) async {
    final prefs = await SharedPreferences.getInstance();

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

    // 데이터 저장
    await prefs.setString(_getCacheKey(stringISBN), jsonEncode(dataToCache));
    print("책 상세 정보를 캐시에 저장했습니다: $stringISBN");
  }

  // 캐시된 책 상세 정보 로딩
  Future<BookResponse?> loadCachedBookDetail(String stringISBN) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_getCacheKey(stringISBN));

    if (cachedData == null) {
      print("캐시된 책 상세 정보가 없습니다: $stringISBN");
      return null;
    }

    try {
      print("캐시된 책 상세 정보를 로드합니다: $stringISBN");
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

  // 캐시된 데이터 확인
  Future<bool> isBookDetailCached(String stringISBN) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_getCacheKey(stringISBN));
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

  // 모든 상세정보 캐시 삭제
  Future<void> clearAllBookDetailCache() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    int count = 0;
    for (String key in allKeys) {
      if (key.startsWith('cached_book_detail_')) {
        await prefs.remove(key);
        count++;
      }
    }

    print("총 $count개의 책 상세 정보 캐시가 삭제되었습니다.");
  }
}

// 검색 결과 캐시
class CachedSearchService {
  static const String _cachedSearchIdsKey = 'cached_search_ids';

  // 검색 쿼리, 유형, 정렬 방식을 조합하여 고유한 캐시 키 생성
  String _getCacheKey(String query, String? queryType, String? sort) {
    return 'cached_search_${query}_${queryType ?? "Keyword"}_${sort ?? "Accuracy"}';
  }

  // 검색 결과 캐싱
  Future<void> cacheSearchResult(
    String query,
    String? queryType,
    String? sort,
    BookResponse bookResponse,
  ) async {
    final prefs = await SharedPreferences.getInstance();

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

    final cacheKey = _getCacheKey(query, queryType, sort);

    // 데이터 저장
    await prefs.setString(cacheKey, jsonEncode(dataToCache));

    // 캐시된 검색 목록에 추가
    List<String> cachedIds = prefs.getStringList(_cachedSearchIdsKey) ?? [];
    if (!cachedIds.contains(cacheKey)) {
      cachedIds.add(cacheKey);
      await prefs.setStringList(_cachedSearchIdsKey, cachedIds);
    }

    print("검색 결과를 캐시에 저장했습니다: $query ($queryType, $sort)");
  }

  // 캐시된 검색 결과 로딩
  Future<BookResponse?> loadCachedSearchResult(
    String query,
    String? queryType,
    String? sort,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getCacheKey(query, queryType, sort);
    final cachedData = prefs.getString(cacheKey);

    if (cachedData == null) {
      print("캐시된 검색 결과가 없습니다: $query ($queryType, $sort)");
      return null;
    }

    try {
      print("캐시된 검색 결과를 로드합니다: $query ($queryType, $sort)");
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

  // 모든 검색 결과 캐시 삭제
  Future<void> clearAllSearchCache() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedIds = prefs.getStringList(_cachedSearchIdsKey) ?? [];

    int count = 0;
    for (String cacheKey in cachedIds) {
      await prefs.remove(cacheKey);
      count++;
    }

    await prefs.remove(_cachedSearchIdsKey);
    print("총 $count개의 검색 결과 캐시가 삭제되었습니다.");
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
