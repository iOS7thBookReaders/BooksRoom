import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:books_room/models/book_response.dart';

import '../components/format.dart';

class BookModel {
  final String isbn13; // 문서 ID로 사용할 ISBN
  final String title;
  final String author;
  final String publisher;
  String? publishDate;
  String? genre;
  String? page;
  String? bookIntro;
  String? coverUrl;

  // 리뷰 관련 필드
  String? review;
  String? oneLineComment;
  int? starRating;

  // 날짜 관련 필드
  String? readEndDate; // 독서 완료 날짜

  // 상태 필드
  bool isWishing;
  bool isReading;
  bool isReviewed;

  // 기본 생성자
  BookModel({
    required this.isbn13,
    required this.title,
    required this.author,
    required this.publisher,
    this.publishDate,
    this.genre,
    this.page,
    this.bookIntro,
    this.coverUrl,
    this.review,
    this.oneLineComment,
    this.starRating,
    this.readEndDate,
    this.isWishing = false, // 기본값 false
    this.isReading = false, // 기본값 false
    this.isReviewed = false, // 기본값 false
  });

  // Firestore 문서에서 BookModel 객체 생성
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Timestamp를 String으로 변환
    String? readEndDate;
    if (data['readEndDate'] != null) {
      readEndDate = Format().formatDate(data['readEndDate']);
    }

    return BookModel(
      isbn13: doc.id, // 문서 ID를 ISBN으로 사용
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'] ?? '',
      publishDate: data['publishDate'],
      genre: data['genre'],
      page: data['page'],
      bookIntro: data['bookIntro'],
      coverUrl: data['coverUrl'],
      review: data['review'],
      oneLineComment: data['oneLineComment'],
      starRating: data['starRating'],
      readEndDate: readEndDate,
      isWishing: data['isWishing'] ?? false,
      isReading: data['isReading'] ?? false,
      isReviewed: data['isReviewed'] ?? false,
    );
  }

  // BookModel 객체를 Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'publishDate': publishDate,
      'genre': genre,
      'page': page,
      'bookIntro': bookIntro,
      'coverUrl': coverUrl,
      'review': review,
      'oneLineComment': oneLineComment,
      'starRating': starRating,
      'readEndDate': readEndDate,
      'isWishing': isWishing,
      'isReading': isReading,
      'isReviewed': isReviewed,
    };
  }

  // 복사본을 생성하는 메서드 추가
  BookModel copyWith({
    String? isbn13,
    String? title,
    String? author,
    String? publisher,
    String? publishDate,
    String? genre,
    String? page,
    String? bookIntro,
    String? coverUrl,
    String? review,
    String? oneLineComment,
    int? starRating,
    String? readEndDate,
    bool? isWishing,
    bool? isReading,
    bool? isReviewed,
  }) {
    return BookModel(
      isbn13: isbn13 ?? this.isbn13,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publishDate: publishDate ?? this.publishDate,
      genre: genre ?? this.genre,
      page: page ?? this.page,
      bookIntro: bookIntro ?? this.bookIntro,
      coverUrl: coverUrl ?? this.coverUrl,
      review: review ?? this.review,
      oneLineComment: oneLineComment ?? this.oneLineComment,
      starRating: starRating ?? this.starRating,
      readEndDate: readEndDate ?? this.readEndDate,
      isWishing: isWishing ?? this.isWishing,
      isReading: isReading ?? this.isReading,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }

  // 홈화면에 Firebase 데이터를 API 방식으로 전달
  BookItem toBookItem() {
    return BookItem(
      isbn13: isbn13,
      title: title,
      author: author,
      pubDate: publishDate,
      publisher: publisher,
      cover: coverUrl,
      categoryName: genre,
      description: bookIntro,
      subInfo: BookSubInfo(
        subTitle: "", // BookModel에는 부제목 필드가 없으므로 빈 문자열 사용
        itemPage: int.tryParse(page ?? "0"), // 문자열에서 정수로 변환
      ),
    );
  }
}
