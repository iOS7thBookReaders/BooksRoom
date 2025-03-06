import 'package:books_room/color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
                labelColor: MAIN_COLOR,
                unselectedLabelColor: GRAY500,
                controller: tabController, // TabController를 TabBar에 연결
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
            _buildBestSellerListView(),
            _buildReadingListView(),
            _buildFavoriteListView(),
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
                        Icon(Icons.search, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "책 검색",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : const Center(
                      key: ValueKey(2),
                      child: Icon(Icons.ios_share, color: Colors.white),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildBestSellerListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(title: Text('베스트셀러 $index'));
      },
    );
  }

  Widget _buildReadingListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(title: Text('읽는중 $index'));
      },
    );
  }

  Widget _buildFavoriteListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(title: Text('찜 $index'));
      },
    );
  }
}
