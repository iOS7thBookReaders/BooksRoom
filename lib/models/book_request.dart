class BookRequestModel {
  final String ttbKey;
  final String output;
  final String version;
  final String? queryType;
  final int? maxResults;
  final int? start;
  final String? searchTarget;
  final String? sort;
  final String? itemIdType;
  final String? itemId;
  final String? cover;
  final String? query;

  BookRequestModel({
    required this.ttbKey,
    required this.output,
    required this.version,
    this.queryType,
    this.maxResults,
    this.start,
    this.searchTarget,
    this.sort,
    this.itemIdType,
    this.itemId,
    this.cover,
    this.query,
  });

  // Request URL 파라미터로 변환
  Map<String, String> toBestSellerQueryParameters() {
    return {
      'ttbkey': ttbKey,
      'output': output,
      'Version': version,
      'QueryType': queryType ?? 'Bestseller',
      'MaxResults': maxResults?.toString() ?? '10',
      'start': start?.toString() ?? '1',
      'SearchTarget': searchTarget ?? 'Book',
    };
  }

  Map<String, String> toDetailQueryParameters() {
    return {
      'ttbkey': ttbKey,
      'output': output,
      'Version': version,
      'itemIdType': itemIdType ?? '',
      'ItemId': itemId ?? '',
      'Cover': cover ?? 'Mid',
    };
  }

  Map<String, String> toSearchQueryParameters() {
    return {
      'ttbkey': ttbKey,
      'output': output,
      'Version': version,
      'Query': query ?? '',
      'QueryType': queryType ?? 'Keyword',
      'Sort': sort ?? 'Accuracy',
      'MaxResults': maxResults?.toString() ?? '10',
      'start': start?.toString() ?? '1',
      'SearchTarget': searchTarget ?? 'Book',
    };
  }
}
