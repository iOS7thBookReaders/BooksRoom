import 'package:books_room/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'book_list_cell.dart';
import 'book_provider.dart';
import 'book_response.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isFloatingButtonExpanded = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.fetchBookBestseller();
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
            buildFavoriteListView(),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isFloatingButtonExpanded ? 120 : 50,
        height: 50,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                '이번주 베스트셀러',
                style: TextStyle(
                  color: POINT_COLOR,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (bookData.items != null)
              Column(
                children:
                    bookData.items!.map((bookItem) {
                      return BookListCell(bookItem: bookItem);
                    }).toList(),
              ),
          ],
        ),
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
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(title: Text('읽는중 $index'));
      },
    );
  }

  Widget buildFavoriteListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(title: Text('찜 $index'));
      },
    );
  }
}
