import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/book_list_cell.dart';
import '../models/book_response.dart';
import '../providers/book_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  String _currentQueryType = '키워드';
  final List<String> _queryTypeOptions = ['키워드', '제목', '저자', '출판사'];
  String _currentSort = '관련순';
  final List<String> _sortOptions = ['관련순', '제목순', '판매량순'];
  String query = '';
  String queryType = 'Keyword';
  String sort = 'Accuracy';
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SearchScreen'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(bookProvider),
          if (bookProvider.bookSearchData != null)
            _buildListHeader(bookProvider),
          // 로딩 중일 때만 CircularProgressIndicator를 표시
          if (isLoading)
            Expanded(
              child: Center(
                child: const CircularProgressIndicator(color: POINT_COLOR),
              ),
            ),

          if (!isLoading && bookProvider.bookSearchData != null)
            _buildSearchResult(bookProvider),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BookProvider bookProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "검색어를 입력해주세요.",
              hintStyle: TextStyle(color: GRAY500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: POINT_COLOR),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: POINT_COLOR),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: POINT_COLOR),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentQueryType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _currentQueryType = newValue!;
                      });
                    },
                    items:
                        _queryTypeOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        }).toList(),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    dropdownColor: Colors.white,
                    elevation: 1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              suffixIcon: GestureDetector(
                child: const Icon(Icons.search),
                onTap: () {
                  isLoading = true;
                  bookProvider.resetSearchData();
                  String query = searchController.text.trim();
                  if (query.isEmpty) {
                    print('검색어를 입력해주세요.');
                    return;
                  }
                  if (_currentQueryType == '키워드') {
                    queryType = 'Keyword';
                  } else if (_currentQueryType == '제목') {
                    queryType = 'Title';
                  } else if (_currentQueryType == '저자') {
                    queryType = 'Author';
                  } else if (_currentQueryType == '출판사') {
                    queryType = 'Publisher';
                  }

                  if (_currentSort == '관련순') {
                    sort = 'Accuracy';
                  } else if (_currentSort == '제목순') {
                    sort = 'Title';
                  } else if (_currentSort == '판매량순') {
                    sort = 'Sales';
                  }
                  // 검색어가 있을 경우에만 상태 변경
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // 대기 후 데이터 요청
                    Future.delayed(Duration(milliseconds: 500), () {
                      Provider.of<BookProvider>(context, listen: false)
                          .fetchSearchResult(
                            query,
                            _currentQueryType,
                            _currentSort,
                          )
                          .then((_) {
                            setState(() {
                              isLoading = false; // 데이터가 로드되면 로딩 종료
                            });
                          });
                    });
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(BookProvider bookProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '검색 결과 ${bookProvider.bookSearchData?.totalResults ?? 0}건',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSort,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSort = newValue!;
                });
              },
              items:
                  _sortOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              dropdownColor: Colors.white,
              elevation: 1,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult(BookProvider bookProvider) {
    return Expanded(
      child: ListView.builder(
        itemCount: bookProvider.bookSearchData!.items!.length,
        itemBuilder: (context, index) {
          final bookItem = bookProvider.bookSearchData!.items![index];
          return BookListCell(bookItem: bookItem);
        },
      ),
    );
  }
}
