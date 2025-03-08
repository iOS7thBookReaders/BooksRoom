// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/book_model.dart';

class ReviewFirebaseService {
  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 사용자 이메일 가져오기
  String? get currentUserEmail => _auth.currentUser?.email;

  // 컬렉션 레퍼런스
  CollectionReference get usersCollection => _firestore.collection('users');

  // 현재 사용자의 books 컬렉션 참조 얻기
  CollectionReference? get currentUserBooks {
    final email = currentUserEmail;
    print('현재 사용자 Email: $email');
    if (email == null) return null;
    print('접근하는 컬렉션 경로: users/$email/books');
    return usersCollection.doc(email).collection('books');
  }

  // 책 목록 가져오기
  Stream<List<BookModel>> getBooks() {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      return Stream.value([]);
    }

    return booksRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    });
  }

  // 특정 책 상세 정보 가져오기
  Stream<BookModel?> getBookByIsbn(String isbn13) {
    final booksRef = currentUserBooks;
    print('특정 책 정보 요청 - ISBN: $isbn13');
    if (booksRef == null) {
      print('사용자 컬렉션 참조 없음 - 로그인 상태 확인 필요');
      return Stream.value(null);
    }

    return booksRef.doc(isbn13).snapshots().map((snapshot) {
      print('Firestore 문서 존재 여부: ${snapshot.exists}');
      if (snapshot.exists) {
        print('Firestore에서 가져온 데이터: ${snapshot.data()}');
        return BookModel.fromFirestore(snapshot);
      } else {
        print('ISBN $isbn13에 해당하는 책을 찾을 수 없음');
        return null;
      }
    });
  }

  // 책 추가하기
  Future<void> addBook(BookModel book) async {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    // ISBN을 문서 ID로 직접 지정하여 저장
    return booksRef.doc(book.isbn13).set(book.toFirestore());
  }

  // 책 정보 업데이트하기
  Future<void> updateBook(BookModel book) async {
    final booksRef = currentUserBooks;
    print('책 정보 업데이트 시작 - ISBN: ${book.isbn13}');
    if (booksRef == null) {
      print('사용자 컬렉션 참조 없음 - 업데이트 불가');
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    print('업데이트할 데이터: ${book.toFirestore()}');
    return booksRef
        .doc(book.isbn13)
        .update(book.toFirestore())
        .then((_) => print('업데이트 성공 - ISBN: ${book.isbn13}'))
        .catchError((error) => print('업데이트 실패: $error'));
  }

  // 책 삭제하기
  Future<void> deleteBook(String isbn13) async {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    return booksRef.doc(isbn13).delete();
  }

  // 읽고 있는 책 목록 가져오기 (isReading이 true인 책들)
  Stream<List<BookModel>> getReadingBooks() {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      return Stream.value([]);
    }

    return booksRef.where('isReading', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    });
  }

  // 찜한 책 목록 가져오기 (isWishing이 true인 책들)
  Stream<List<BookModel>> getWishingBooks() {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      return Stream.value([]);
    }

    return booksRef.where('isWishing', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    });
  }
}
