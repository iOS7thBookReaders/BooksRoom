class BookRequestModel {
  final String ttbKey;
  final String queryType;
  final int maxResults;
  final int start;
  final String searchTarget;
  final String output;
  final String version;
  final String year;
  final String month;
  final String week;
  final String? sort;

  BookRequestModel({
    required this.ttbKey,
    required this.queryType,
    required this.maxResults,
    required this.start,
    required this.searchTarget,
    required this.output,
    required this.version,
    required this.year,
    required this.month,
    required this.week,
    this.sort,
  });

  // Request URL 파라미터로 변환
  Map<String, String> toQueryParameters() {
    return {
      'ttbkey': ttbKey,
      'QueryType': queryType,
      'MaxResults': maxResults.toString(),
      'start': start.toString(),
      'SearchTarget': searchTarget,
      'output': output,
      'Version': version,
      'Year': year.toString(),
      'Month': month.toString(),
      'Week': week.toString(),
    };
  }
}
