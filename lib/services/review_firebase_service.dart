import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/book_model.dart';

class ReviewFirebaseService {
  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 사용자 ID 가져오기
  String? get currentUserId => _auth.currentUser?.uid;

  // 컬렉션 레퍼런스
  CollectionReference get usersCollection => _firestore.collection('users');

  // 사용자별 books 컬렉션 참조 얻기
  CollectionReference getBooksCollection(String userId) {
    return usersCollection.doc(userId).collection('books');
  }

  // 현재 사용자의 books 컬렉션 참조 얻기
  CollectionReference? get currentUserBooks {
    final userId = currentUserId;
    if (userId == null) return null;
    return getBooksCollection(userId);
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
    if (booksRef == null) {
      return Stream.value(null);
    }

    return booksRef.doc(isbn13).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return BookModel.fromFirestore(snapshot);
      } else {
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
    if (booksRef == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    return booksRef.doc(book.isbn13).update(book.toFirestore());
  }

  // 책 삭제하기
  Future<void> deleteBook(String isbn13) async {
    final booksRef = currentUserBooks;
    if (booksRef == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    return booksRef.doc(isbn13).delete();
  }
}
