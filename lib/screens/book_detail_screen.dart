// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:books_room/providers/book_provider.dart';
import 'package:books_room/components/format.dart';
import 'package:books_room/services/book_firebase_service.dart';
import 'package:books_room/models/book_model.dart';
import 'package:books_room/components/color.dart';
import 'package:books_room/services/review_firebase_service.dart';
import 'package:books_room/screens/review_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookISBN;
  const BookDetailScreen({super.key, required this.bookISBN});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  // 상태 변수
  bool isWishing = false;
  bool isReading = false;
  bool isReviewed = false;
  int starRating = 0;
  bool isDataLoaded = false; // 데이터가 이미 로드되었는지 여부 체크

  // Firebase 서비스 인스턴스
  final BookFirebaseService _bookFirebaseService = BookFirebaseService();
  // 현재 책의 Firebase 저장 모델
  BookModel? _savedBookModel;
  // 로딩 상태 추가
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      if (!isDataLoaded) {
        bookProvider.fetchBookDetail(widget.bookISBN).then((_) {
          setState(() {
            isDataLoaded = true;
          });
          _checkAndSaveBookIfNeeded();
        });
      }
    });
  }

  @override
  void dispose() {
    // 이미지 관련 리소스 명시적 해제
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    super.dispose();
  }

  // 책이 Firebase에 있는지 확인하고 없으면 저장
  Future<void> _checkAndSaveBookIfNeeded() async {
    try {
      // 책이 이미 저장되어 있는지 확인
      final savedBook = await _bookFirebaseService.getBook(widget.bookISBN);

      if (savedBook != null) {
        // 이미 저장된 책이면 상태 로드
        print('이미 저장된 책 발견: ${savedBook.title}');
        setState(() {
          _savedBookModel = savedBook;
          // 저장된 상태 정보로 UI 업데이트
          isWishing = savedBook.isWishing;
          isReading = savedBook.isReading;
          isReviewed = savedBook.isReviewed;
          starRating = savedBook.starRating ?? 0;
        });
        print(
          '저장된 책 정보: 찜=${savedBook.isWishing}, 읽는중=${savedBook.isReading}, 리뷰=${savedBook.isReviewed}, 별점=${savedBook.starRating}',
        );
      } else {
        // 저장된 책이 없으면 API에서 가져온 정보를 Firebase에 저장
        if (!mounted) return;

        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        final bookDetailData = bookProvider.bookDetailData;

        if (bookDetailData != null && bookDetailData.items!.isNotEmpty) {
          final bookItem = bookDetailData.items![0];

          // API 응답에서 BookModel 생성
          final bookModel = _bookFirebaseService.convertToBookModel(bookItem);

          // Firebase에 저장
          await _bookFirebaseService.saveBook(bookModel);
          print('새 책 정보 Firebase에 저장: ${bookModel.title}');

          // 저장 후 다시 불러와 _savedBookModel 업데이트
          final updatedBook = await _bookFirebaseService.getBook(
            widget.bookISBN,
          );
          if (updatedBook != null) {
            setState(() {
              _savedBookModel = updatedBook;
            });
          }
        }
      }
    } catch (e) {
      print('저장된 책 정보 확인 오류: $e');
    }
  }

  // 책 상태 업데이트 메서드
  Future<void> _updateBookStatus({
    required bool isWishing,
    required bool isReading,
    required bool isReviewed,
    required int? starRating,
  }) async {
    if (_savedBookModel == null) {
      print('저장된 책 모델이 없어 상태를 업데이트할 수 없습니다');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 이미 저장된 모델의 상태만 업데이트
      final updatedModel = _savedBookModel!.copyWith(
        isWishing: isWishing,
        isReading: isReading,
        isReviewed: isReviewed,
        starRating: starRating,
      );

      await _bookFirebaseService.saveBook(updatedModel);
      setState(() {
        _savedBookModel = updatedModel;
      });
    } catch (e) {
      print('책 상태 업데이트 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다')));
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // 리뷰 화면으로 이동하는 헬퍼 메서드
  void _navigateToReviewScreen() {
    if (_savedBookModel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ReviewScreen(
                bookModel: _savedBookModel!,
                firebaseService: ReviewFirebaseService(),
              ),
        ),
      ).then((_) {
        // 리뷰 작성 후 돌아오면 책 상태 다시 확인
        _checkAndSaveBookIfNeeded();
      });
    } else {
      // 저장된 모델이 없으면 먼저 책 정보 확인/저장 후 이동
      _checkAndSaveBookIfNeeded().then((_) {
        if (_savedBookModel != null) {
          _navigateToReviewScreen();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('책 정보를 저장할 수 없어 리뷰를 작성할 수 없습니다')),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Format format = Format();
    final bookProvider = Provider.of<BookProvider>(context);
    final bookDetailData = bookProvider.bookDetailData;
    print(bookDetailData);

    if (bookDetailData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      if (bookDetailData.items!.isEmpty) {
        return Scaffold(body: Center(child: Text('존재하지 않는 책입니다.')));
      }
    }

    final title = bookDetailData.items?[0].title ?? '제목 없음';
    final formattedTitle = format.formatTitle(title)[0];
    final subtitle =
        format.formatTitle(title).length > 1
            ? format.formatTitle(title)[1]
            : '';
    final author = bookDetailData.items?[0].author ?? '저자 정보 없음';
    final category = bookDetailData.items?[0].categoryName ?? '카테고리 정보 없음';
    final formattedCategories = format.formatCategoryName(category);
    final itemPage = bookDetailData.items?[0].subInfo?.itemPage ?? 0;
    final publisher = bookDetailData.items?[0].publisher ?? '출판사 정보 없음';
    final cover = bookDetailData.items?[0].cover ?? '';
    final pubDate = bookDetailData.items?[0].pubDate ?? '';
    final formattedPubDate = format.formatYearFromPubDate(pubDate);
    final description = bookDetailData.items?[0].description ?? '설명 없음';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '책 상세정보',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedTitle,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: subtitle,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: GRAY900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: formattedPubDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              infoRow('저자', author),
                              SizedBox(height: 2),
                              infoRow('출판사', publisher),
                              SizedBox(height: 2),
                              infoRow('카테고리', formattedCategories),
                              SizedBox(height: 2),
                              infoRow('페이지', itemPage.toString()),
                            ],
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: cover,
                          fit: BoxFit.contain,
                          fadeInDuration: Duration.zero,
                          placeholderFadeInDuration: Duration.zero,
                          placeholder:
                              (context, url) => Container(
                                color: MAIN_COLOR.withAlpha(0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      MAIN_COLOR.withAlpha(0),
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.error, color: MAIN_COLOR),
                              ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),

                    // 별점 섹션
                    buildStarRating(),
                    SizedBox(height: 20),

                    // 작품 정보 섹션
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '작품 정보',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(description, style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),

            // 버튼 섹션(찜, 읽는중, 리뷰)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 찜 버튼
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline_outlined,
                          size: 30,
                          color: isWishing ? POINT_COLOR : GRAY300_DISABLE,
                        ),
                        onPressed:
                            _isSaving
                                ? null
                                : () {
                                  setState(() {
                                    isWishing = !isWishing;
                                  });
                                  // firebase 업데이트
                                  _updateBookStatus(
                                    isWishing: isWishing,
                                    isReading: isReading,
                                    isReviewed: isReviewed,
                                    starRating: starRating,
                                  );
                                },
                      ),
                      Text(
                        '찜',
                        style: TextStyle(
                          fontSize: 13,
                          color: isWishing ? POINT_COLOR : GRAY500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                // 읽는중 버튼
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.book_fill,
                          size: 30,
                          color: isReading ? POINT_COLOR : GRAY300_DISABLE,
                        ),
                        onPressed:
                            _isSaving
                                ? null
                                : () {
                                  setState(() {
                                    // 읽기 시작할 때(false->true) isWishing을 false로 설정
                                    if (!isReading) {
                                      isWishing = false;
                                    }
                                    isReading = !isReading;
                                  });
                                  // firebase 업데이트
                                  _updateBookStatus(
                                    isWishing: isWishing,
                                    isReading: isReading,
                                    isReviewed: isReviewed,
                                    starRating: starRating,
                                  );
                                },
                      ),
                      Text(
                        '읽는중',
                        style: TextStyle(
                          fontSize: 13,
                          color: isReading ? POINT_COLOR : GRAY500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                // 리뷰 버튼
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_note_rounded,
                          size: 30,
                          color: isReviewed ? POINT_COLOR : GRAY300_DISABLE,
                        ),
                        onPressed:
                            _isSaving
                                ? null
                                : () {
                                  if (_savedBookModel == null) {
                                    // 먼저 책 정보 저장
                                    _updateBookStatus(
                                      isWishing: isWishing,
                                      isReading: isReading,
                                      isReviewed: isReviewed,
                                      starRating: starRating,
                                    ).then((_) {
                                      // 그 후 리뷰 화면으로 이동
                                      _navigateToReviewScreen();
                                    });
                                  } else {
                                    _navigateToReviewScreen();
                                  }
                                },
                      ),
                      Text(
                        '독후감',
                        style: TextStyle(
                          fontSize: 13,
                          color: isReviewed ? POINT_COLOR : GRAY500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: GRAY900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: GRAY900),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < starRating ? Icons.star : Icons.star_border_outlined,
            color: index < starRating ? MAIN_COLOR : GRAY200_LINE,
            size: 50,
          ),
          onPressed: () {
            setState(() {
              if (starRating == index + 1) {
                starRating = 0;
              } else {
                starRating = index + 1;
                isWishing = false;
                isReading = false;
              }
            });

            _updateBookStatus(
              isWishing: isWishing,
              isReading: isReading,
              isReviewed: isReviewed,
              starRating: starRating,
            );
          },
        );
      }),
    );
  }
}
