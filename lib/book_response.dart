class BookResponse {
  final String title;
  final String pubDate;
  final int totalResults;
  final int startIndex;
  final int itemsPerPage;
  final String? query;
  final List<BookItem>? items;

  BookResponse({
    required this.title,
    required this.pubDate,
    required this.totalResults,
    required this.startIndex,
    required this.itemsPerPage,
    this.query,
    this.items,
  });

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['item'] as List;
    List<BookItem> itemList =
        itemsList.map((i) => BookItem.fromJson(i)).toList();

    return BookResponse(
      title: json['title'],
      pubDate: json['pubDate'],
      totalResults: json['totalResults'],
      startIndex: json['startIndex'],
      itemsPerPage: json['itemsPerPage'],
      query: json['query'],
      items: itemList,
    );
  }
}

class BookItem {
  final String? title;
  final String? author;
  final String? pubDate;
  final String? description;
  final String? isbn13;
  final String? mallType;
  final String? cover;
  final String? publisher;
  final String? bestDuration;
  final String? categoryName;
  final BookSubInfo? subInfo;

  BookItem({
    this.title,
    this.author,
    this.pubDate,
    this.description,
    required this.isbn13,
    this.mallType,
    this.cover,
    this.publisher,
    this.bestDuration,
    this.subInfo,
    this.categoryName,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      title: json['title'],
      author: json['author'],
      pubDate: json['pubDate'],
      description: json['description'],
      isbn13: json['isbn13'],
      mallType: json['mallType'],
      cover: json['cover'],
      publisher: json['publisher'],
      bestDuration: json['bestDuration'],
      categoryName: json['categoryName'],
      subInfo: BookSubInfo.fromJson(json['subInfo']),
    );
  }
}

class BookSubInfo {
  final String? subTitle;
  final int? itemPage;

  BookSubInfo({required this.subTitle, required this.itemPage});

  factory BookSubInfo.fromJson(Map<String, dynamic> json) {
    return BookSubInfo(subTitle: json['subTitle'], itemPage: json['itemPage']);
  }
}
