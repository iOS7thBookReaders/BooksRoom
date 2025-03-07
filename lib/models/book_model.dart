import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String isbn13; // 문서 ID로 사용할 ISBN
  final String title;
  final String author;
  final String publisher;
  String? publishDate;
  String? genre;
  String? page;
  String? bookIntro;

  // 리뷰 관련 필드
  String? review;
  String? oneLineComment;
  int? starRating;

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
    this.review,
    this.oneLineComment,
    this.starRating,
  });

  // Firestore 문서에서 BookModel 객체 생성
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return BookModel(
      isbn13: doc.id, // 문서 ID를 ISBN으로 사용
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'] ?? '',
      publishDate: data['publishDate'],
      genre: data['genre'],
      page: data['page'],
      bookIntro: data['bookIntro'],
      review: data['review'],
      oneLineComment: data['oneLineComment'],
      starRating: data['starRating'],
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
      'review': review,
      'oneLineComment': oneLineComment,
      'starRating': starRating,
    };
  }
}
