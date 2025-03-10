// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:books_room/components/color.dart';
import 'package:books_room/models/book_model.dart';
import 'package:books_room/services/review_firebase_service.dart';

import '../components/format.dart';

class ReviewScreen extends StatefulWidget {
  final BookModel bookModel;
  final ReviewFirebaseService firebaseService;

  const ReviewScreen({
    super.key,
    required this.bookModel,
    required this.firebaseService,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // 리뷰 상태 변수
  late TextEditingController reviewController;
  late TextEditingController oneLineCommentController;
  int starRating = 0;
  String oneLineCommentLength = '0/20'; // 한줄평 글자수
  bool _isEditMode = false;

  // 읽은 날짜 관련 변수
  DateTime? selectedReadEndDate;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    print('리뷰 화면 초기화 - 책 제목: ${widget.bookModel.title}');

    // 컨트롤러 초기화
    reviewController = TextEditingController();
    oneLineCommentController = TextEditingController();

    // 기존 리뷰 정보가 있으면 로드
    if (widget.bookModel.review != null) {
      print('기존 리뷰 정보 로드: ${widget.bookModel.review}');
      reviewController.text = widget.bookModel.review ?? '';
    }

    if (widget.bookModel.oneLineComment != null) {
      oneLineCommentController.text = widget.bookModel.oneLineComment ?? '';
      _updateOneLineCommentLength();
    }

    if (widget.bookModel.starRating != null) {
      starRating = widget.bookModel.starRating ?? 0;
    }

    // readEndDate 안전하게 처리
    selectedReadEndDate = null; // 기본값 설정
    if (widget.bookModel.readEndDate != null &&
        widget.bookModel.readEndDate!.isNotEmpty) {
      try {
        selectedReadEndDate = DateTime.parse(widget.bookModel.readEndDate!);
      } catch (e) {
        print('날짜 파싱 오류: $e');
        // 오류 발생 시 기본값 유지
      }
    }

    // 초기 모드 설정
    _isEditMode = false;

    // 한줄평 텍스트 변경 리스너
    oneLineCommentController.addListener(_updateOneLineCommentLength);
  }

  // 한줄평 글자 수 업데이트
  void _updateOneLineCommentLength() {
    setState(() {
      oneLineCommentLength = '${oneLineCommentController.text.length}/20';
    });
  }

  @override
  void dispose() {
    // 리스너 제거
    oneLineCommentController.removeListener(_updateOneLineCommentLength);
    // 컨트롤러 해제
    reviewController.dispose();
    oneLineCommentController.dispose();
    // 이미지 관련 리소스 명시적 해제
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    super.dispose();
  }

  // 날짜 선택기 열기
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedReadEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: MAIN_COLOR)),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedReadEndDate) {
      setState(() {
        selectedReadEndDate = picked;
      });
    }
  }

  // 리뷰 저장 메서드
  void _saveReview() async {
    print('리뷰 저장 시작');
    String? formattedReadEndDate;
    if (selectedReadEndDate != null) {
      formattedReadEndDate = dateFormat.format(selectedReadEndDate!);
    }
    try {
      print('저장할 한줄평: ${oneLineCommentController.text}');
      print('저장할 별점: $starRating');

      // 현재 입력된 리뷰 정보로 책 모델 업데이트
      final updatedBook = widget.bookModel.copyWith(
        review: reviewController.text,
        oneLineComment: oneLineCommentController.text,
        starRating: starRating,
        isReviewed: true, // 리뷰 작성 시 true로 설정
        readEndDate: formattedReadEndDate.toString(),
        isReading: false, // 리뷰 작성시 false로 설정
      );

      // 파이어베이스에 업데이트
      await widget.firebaseService.updateBook(updatedBook);
      print('파이어베이스 업데이트 완료');

      // 저장 완료 후 알림
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('리뷰가 저장되었습니다')));
        // 이전 화면으로 돌아가기
        Navigator.pop(context);
      }
    } catch (e) {
      print('리뷰 저장 중 오류 발생: $e');
      // 에러 발생 시 처리
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // BookModel에서 책 정보 가져오기
    final booktitle = widget.bookModel.title;
    final author = widget.bookModel.author;
    final publisher = widget.bookModel.publisher;
    final publishDate = widget.bookModel.publishDate ?? '';
    final genre = widget.bookModel.genre ?? '';
    final page = widget.bookModel.page ?? '';
    final bookIntro = widget.bookModel.bookIntro ?? '';
    final coverUrl = widget.bookModel.coverUrl ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.bookModel.isReviewed
              ? (_isEditMode ? '도서 리뷰 수정' : '도서 리뷰')
              : '도서 리뷰 작성',
        ),
        backgroundColor: Colors.white,

        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // 보기 모드일 때만 수정 버튼 표시
          if (widget.bookModel.isReviewed && !_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            ),
          // 수정 모드일 때만 삭제 버튼 표시
          if (widget.bookModel.isReviewed && _isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  // 삭제 확인 다이얼로그 표시
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('리뷰 삭제'),
                          content: Text('이 리뷰를 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(context), // 다이얼로그 닫기
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // 다이얼로그 닫기
                                Navigator.pop(context);

                                try {
                                  // 리뷰 정보 초기화하는 모델 생성
                                  final updatedBook = widget.bookModel.copyWith(
                                    review: '',
                                    oneLineComment: '',
                                    starRating: 0,
                                    isReviewed: false,
                                    readEndDate: '',
                                  );

                                  // Firebase에 업데이트
                                  await widget.firebaseService.updateBook(
                                    updatedBook,
                                  );

                                  // 성공 메시지 표시
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('리뷰가 삭제되었습니다'),
                                      ),
                                    );

                                    // 리뷰 화면 닫고 도서 상세 화면으로 돌아가기
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  print('리뷰 삭제 중 오류 발생: $e');
                                  // 오류 발생 시 메시지 표시
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('오류가 발생했습니다: $e')),
                                    );
                                  }
                                }
                              },
                              child: Text('삭제'),
                            ),
                          ],
                        ),
                  );
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 스크롤 가능 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 책 정보 섹션
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 책 표지
                      Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.only(right: 16.0),
                        child:
                            coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: coverUrl,
                                  fit: BoxFit.cover,
                                  fadeInDuration: Duration.zero,
                                  placeholderFadeInDuration: Duration.zero,
                                  width: 120,
                                  height: 180,
                                  placeholder:
                                      (context, url) => Container(
                                        color: MAIN_COLOR.withAlpha(0),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: MAIN_COLOR.withAlpha(0),
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.grey.shade300,
                                        child: Center(
                                          child: Icon(
                                            Icons.book,
                                            size: 50,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                )
                                : Container(
                                  color: Colors.grey.shade300,
                                  child: Center(
                                    child: Icon(
                                      Icons.book,
                                      size: 50,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                      ),
                      // 책 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bookInfoRow('저자', author),
                            _bookInfoRow('출판사', publisher),
                            _bookInfoRow(
                              '카테고리',
                              Format().formatCategoryName(genre),
                            ),
                            _bookInfoRow(
                              '발행연도',
                              Format().formatYearFromPubDate(publishDate),
                            ),
                            _bookInfoRow('페이지', page),
                          ],
                        ),
                      ),
                    ],
                  ), // 책 정보 섹션
                  const SizedBox(height: 10),

                  // 책 제목 및 소개 섹션
                  Text(
                    booktitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    bookIntro,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // 읽은 날짜 선택 섹션
                  const Text(
                    '다 읽은 날짜',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8.0),
                  // 작성 모드나 수정 모드일 때는 날짜 선택 가능
                  if (!widget.bookModel.isReviewed || _isEditMode)
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedReadEndDate != null
                                  ? dateFormat.format(selectedReadEndDate!)
                                  : '날짜를 선택해주세요',
                              style: TextStyle(
                                color:
                                    selectedReadEndDate != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                            Icon(Icons.calendar_today, color: GRAY500),
                          ],
                        ),
                      ),
                    )
                  // 보기 모드일 때는 날짜만 표시
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: GRAY50_BACKGROUND,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        selectedReadEndDate != null
                            ? dateFormat.format(selectedReadEndDate!)
                            : '날짜 정보가 없습니다.',
                      ),
                    ),

                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedReadEndDate != null
                                ? dateFormat.format(selectedReadEndDate!)
                                : '날짜를 선택해주세요',
                            style: TextStyle(
                              color:
                                  selectedReadEndDate != null
                                      ? Colors.black
                                      : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: GRAY500),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // 리뷰 입력 섹션
                  const Text(
                    '리뷰',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // 작성 모드나 수정 모드일 때 텍스트필드 표시
                  if (!widget.bookModel.isReviewed || _isEditMode)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        controller: reviewController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: '내용을 입력해주세요',
                          contentPadding: EdgeInsets.all(12.0),
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  // 보기 모드일 때는 텍스트만 표시
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: GRAY50_BACKGROUND,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        reviewController.text.isEmpty
                            ? '리뷰가 없습니다'
                            : reviewController.text,
                      ),
                    ), // 리뷰 입력 섹션
                  const SizedBox(height: 24.0),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: GRAY500),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      controller: reviewController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: '내용을 입력해주세요',

                        hintStyle: TextStyle(color: GRAY500, fontSize: 13),
                        contentPadding: EdgeInsets.all(12.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ), // 리뷰 입력 섹션
                  const SizedBox(height: 20.0),

                  // 한 줄 평 입력 섹션
                  const Text(
                    '한 줄 평가',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // 작성 모드나 수정 모드일 때 텍스트필드 표시
                  if (!widget.bookModel.isReviewed || _isEditMode)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        controller: oneLineCommentController,
                        maxLength: 20,
                        decoration: const InputDecoration(
                          hintText: '한줄평을 남겨주세요',
                          contentPadding: EdgeInsets.all(12.0),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    )
                  // 보기 모드일 때는 텍스트만 표시
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: GRAY50_BACKGROUND,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        oneLineCommentController.text.isEmpty
                            ? '한줄평이 없습니다.'
                            : oneLineCommentController.text,
                      ),
                    ),
                  // 작성 모드나 수정 모드일 때만 글자 수 표시
                  if (!widget.bookModel.isReviewed || _isEditMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        oneLineCommentLength,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ), // 한 줄 평 입력 섹션
                  const SizedBox(height: 8.0),

                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      controller: oneLineCommentController,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        hintText: '한줄평을 남겨주세요',
                        hintStyle: TextStyle(color: GRAY500, fontSize: 13),

                        contentPadding: EdgeInsets.all(12.0),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      oneLineCommentLength,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ), // 한 줄 평 입력 섹션
                  const SizedBox(height: 20.0),
                  // 별점 섹션
                  const Text(
                    '별점',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < starRating ? Icons.star : Icons.star_border,
                          color:
                              index < starRating
                                  ? Colors.amber
                                  : GRAY300_DISABLE,
                          size: 32,
                        ),
                        onPressed:
                            (!widget.bookModel.isReviewed || _isEditMode)
                                ? () {
                                  setState(() {
                                    starRating = index + 1;
                                  });
                                }
                                : null, // 보기 모드에서는 버튼 기능 비활성화
                      );
                    }),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
          // 저장 버튼
          // 작성 모드나 수정 모드일 때만 저장 버튼 표시
          if (!widget.bookModel.isReviewed || _isEditMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: MAIN_COLOR,
                  ),
                  child: const Text(
                    '저장하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ), // 저장 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: MAIN_COLOR,
                ),
                child: const Text(
                  '저장하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  // 책 정보 행을 생성하는 헬퍼 메서드
  Widget _bookInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: GRAY900),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: GRAY900),
            ),
          ),
        ],
      ),
    );
  }
}
