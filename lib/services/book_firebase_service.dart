import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:books_room/models/book_model.dart';
import 'package:books_room/models/book_response.dart';

class BookFirebaseService {
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

  // API 응답에서 Firebase에 저장할 BookModel로 변환
  BookModel convertToBookModel(BookItem bookItem) {
    return BookModel(
      isbn13: bookItem.isbn13 ?? '',
      title: bookItem.title ?? '',
      author: bookItem.author ?? '',
      publisher: bookItem.publisher ?? '',
      publishDate: bookItem.pubDate,
      genre: bookItem.categoryName,
      page: bookItem.subInfo?.itemPage?.toString(),
      bookIntro: bookItem.description,
      // 리뷰 관련 필드는 초기에는 null로 설정
      review: null,
      oneLineComment: null,
      starRating: null,
      // 상태 필드 기본값
      isWishing: false,
      isReading: false,
      isReviewed: false,
    );
  }

  // 책이 이미 존재하는지 확인
  Future<bool> isBookExists(String isbn13) async {
    final booksRef = currentUserBooks;
    if (booksRef == null) return false;

    final docSnapshot = await booksRef.doc(isbn13).get();
    return docSnapshot.exists;
  }

  // 책 저장하기
  Future<void> saveBook(BookModel book) async {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    // ISBN을 문서 ID로 사용하여 책 정보 저장
    return booksRef.doc(book.isbn13).set(book.toFirestore());
  }

  // 책 정보 가져오기
  Future<BookModel?> getBook(String isbn13) async {
    final booksRef = currentUserBooks;
    if (booksRef == null) return null;

    final docSnapshot = await booksRef.doc(isbn13).get();
    if (docSnapshot.exists) {
      return BookModel.fromFirestore(docSnapshot);
    }
    return null;
  }
}
