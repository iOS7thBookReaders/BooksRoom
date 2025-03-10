// ignore_for_file: avoid_print

import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:books_room/components/book_list_cell.dart';
import 'package:books_room/providers/book_provider.dart';
import 'package:books_room/models/book_response.dart';
import 'package:books_room/screens/search_screen.dart';
import 'package:books_room/services/review_firebase_service.dart';
import 'package:books_room/models/book_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isFloatingButtonExpanded = true;

  // 현재 스크롤 위치가 타이틀을 가리는지 여부
  bool _isTitleHidden = false;

  // ReviewFirebaseService 인스턴스
  final ReviewFirebaseService _reviewFirebaseService = ReviewFirebaseService();

  // 읽고 있는 책 목록을 저장할 변수
  List<BookModel> _readingBooks = [];
  List<BookModel> _wishingBooks = [];

  // 데이터 로딩 상태 관리
  bool _isReadingBooksLoading = true;
  bool _isWishingBooksLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    // 탭 변경 이벤트 리스너
    tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.fetchBookBestseller();

      // 읽고 있는 책 데이터 구독
      _loadReadingBooks();
      // 찜한 책 데이터 구독
      _loadWishingBooks();
    });
  }

  // 탭 변경 시 스크롤 위치 유지하기
  void _handleTabChange() {
    if (tabController.indexIsChanging) {
      // 현재 탭이 변경되는 중입니다
      // 타이틀이 이미 가려져 있으면 새 탭도 같은 상태로 설정
      if (_isTitleHidden) {
        // 타이틀이 가려져 있는 스크롤 위치를 설정
        // SliverAppBar의 높이만큼 스크롤
        // 정확한 값은 앱바의 실제 높이에 맞게 조정 필요
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 앱바가 접힌 상태가 되도록 스크롤 포지션 설정
          // 이 값은 앱바의 높이와 전체 설정에 따라 조정 필요
          _scrollController.jumpTo(60.0); // 예시 값, 실제 앱바 높이에 맞게 조정
        });
      } else {
        // 타이틀이 보이는 상태이면 스크롤 위치를 맨 위로 설정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(0);
        });
      }
    }
  }

  void _onScroll() {
    // 현재 스크롤 위치에 따라 타이틀 표시 상태 감지
    if (_scrollController.hasClients) {
      // 스크롤 위치가 특정 값보다 크면 타이틀이 가려진 것으로 판단
      // 이 값은 앱바의 높이와 동작에 따라 적절히 조정 필요
      bool isTitleHiddenNow = _scrollController.offset > 50.0; // 예시 값

      if (isTitleHiddenNow != _isTitleHidden) {
        setState(() {
          _isTitleHidden = isTitleHiddenNow;
        });
      }
    }

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isFloatingButtonExpanded) {
        setState(() {
          _isFloatingButtonExpanded = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFloatingButtonExpanded) {
        setState(() {
          _isFloatingButtonExpanded = true;
        });
      }
    }
  }

  // 읽고 있는 책 로드 메서드
  void _loadReadingBooks() {
    _reviewFirebaseService.getReadingBooks().listen((books) {
      setState(() {
        _readingBooks = books;
        _isReadingBooksLoading = false;
      });
    });
  }

  // 찜한 책 로드 메서드
  void _loadWishingBooks() {
    _reviewFirebaseService.getWishingBooks().listen((books) {
      setState(() {
        _wishingBooks = books;
        _isWishingBooksLoading = false;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final booksBestsellerData = bookProvider.booksBestsellerData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              title: innerBoxIsScrolled ? null : const Text('HomeScreen'),
              floating: true,
              snap: true,
              pinned: true,
              bottom: TabBar(
                indicatorColor: MAIN_COLOR,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: SUB_DARK_BROWN_COLOR,
                unselectedLabelColor: GRAY500,
                controller: tabController,
                tabs: const [
                  Tab(text: '베스트셀러'),
                  Tab(text: '읽는중'),
                  Tab(text: '찜'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController, // TabController를 TabBarView에 연결
          children: [
            bookProvider.isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: MAIN_COLOR),
                )
                : booksBestsellerData == null
                ? Center(child: Text('데이터가 없습니다.'))
                : buildBestSellerListView(booksBestsellerData),
            buildReadingListView(),
            buildWishingListView(),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isFloatingButtonExpanded ? 120 : 50,
        height: 50,
        child: FloatingActionButton.extended(
          onPressed: () {
            bookProvider.resetSearchData();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          backgroundColor: MAIN_COLOR,
          elevation: 0,
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                _isFloatingButtonExpanded
                    ? const Row(
                      key: ValueKey(1),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, color: SUB_DARK_BROWN_COLOR),
                        SizedBox(width: 8),
                        Text(
                          "책 검색",
                          style: TextStyle(
                            color: SUB_DARK_BROWN_COLOR,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : const Center(
                      key: ValueKey(2),
                      child: Icon(Icons.search, color: SUB_DARK_BROWN_COLOR),
                    ),
          ),
        ),
      ),
    );
  }

  Widget buildBestSellerListView(BookResponse bookData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          if (bookData.items != null)
            Column(
              children:
                  bookData.items!.map((bookItem) {
                    return BookListCell(bookItem: bookItem);
                  }).toList(),
            ),
        ],
      ),
    );

    // ListView.builder(
    //   shrinkWrap: true,
    //   itemCount: bookData.items?.length,
    //   itemBuilder: (context, index) {
    //     return BookListCell(bookItem: bookData.items![index]);
    //   },
    // );
  }

  Widget buildReadingListView() {
    if (_isReadingBooksLoading) {
      return Center(child: CircularProgressIndicator(color: MAIN_COLOR));
    }

    if (_readingBooks.isEmpty) {
      return Center(child: Text('읽고 있는 책이 없습니다.'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Column(
            children:
                _readingBooks.map((book) {
                  // BookModel을 BookItem으로 변환
                  return BookListCell(bookItem: book.toBookItem());
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildWishingListView() {
    if (_isWishingBooksLoading) {
      return Center(child: CircularProgressIndicator(color: MAIN_COLOR));
    }

    if (_wishingBooks.isEmpty) {
      return Center(child: Text('찜한 책이 없습니다.'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Column(
            children:
                _wishingBooks.map((book) {
                  // BookModel을 BookItem으로 변환
                  return BookListCell(bookItem: book.toBookItem());
                }).toList(),
          ),
        ],
      ),
    );
  }
}
