class Format {
  String formatCategoryName(String categoryName) {
    // > 기준 분리
    List<String> categoryParts = categoryName.split('>');

    // 두 번째 depth만
    if (categoryParts.length > 1) {
      return categoryParts[1]; // depth2 추출
    } else {
      return categoryName; // depth2 없으면 depth1
    }
  }

  List<String> formatTitle(String title) {
    // - 기준 분리
    List<String> titleParts = title.split(' - ');
    return titleParts;
  }

  String formatYearFromPubDate(String pubDate) {
    // pubDate를 DateTime 객체로 변환
    DateTime date = DateTime.parse(pubDate);

    // 연도만 반환
    return date.year.toString();
  }
}
