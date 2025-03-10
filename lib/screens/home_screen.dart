// ignore_for_file: avoid_print

import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

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
  final ScrollController _paginationScrollController = ScrollController();

  bool _isFloatingButtonExpanded = true;

  // ReviewFirebaseService 인스턴스
  final ReviewFirebaseService _reviewFirebaseService = ReviewFirebaseService();

  // 읽고 있는 책 목록을 저장할 변수
  List<BookModel> _readingBooks = [];
  List<BookModel> _wishingBooks = [];

  // 데이터 로딩 상태 관리
  bool _isReadingBooksLoading = true;
  bool _isWishingBooksLoading = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _paginationScrollController.addListener(_onScrollPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      if (bookProvider.booksBestsellerData == null) {
        bookProvider.fetchBookBestseller(1);
        isLoading = false;
      }
      // 읽고 있는 책 데이터 구독
      _loadReadingBooks();
      // 찜한 책 데이터 구독
      _loadWishingBooks();
    });
  }

  void _onScroll() {
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

  void _onScrollPage() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (_paginationScrollController.position.pixels ==
        _paginationScrollController.position.maxScrollExtent) {
      print('페이지 끝');
      print('💗Loading in scrollPage func $isLoading');
      if (!bookProvider.isLoading && bookProvider.hasMore) {
        bookProvider.fetchBookBestseller(bookProvider.currentPage);
        print('💗Loading in scrollPage fetchBookBestseller func $isLoading');
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
    _paginationScrollController.dispose();
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
                : buildBestSellerListView(booksBestsellerData, bookProvider),
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

  Widget buildBestSellerListView(BookResponse bookData, BookProvider provider) {
    return ListView.builder(
      controller: _paginationScrollController,
      itemCount: bookData.items?.length ?? 0,
      itemBuilder: (context, index) {
        if (index == bookData.items!.length - 1) {
          // 마지막 항목일 경우 로딩 인디케이터 추가
          return Column(
            children: [
              BookListCell(bookItem: bookData.items![index]),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: MAIN_COLOR),
                ),
            ],
          );
        }
        return BookListCell(bookItem: bookData.items![index]);
      },
    );
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
