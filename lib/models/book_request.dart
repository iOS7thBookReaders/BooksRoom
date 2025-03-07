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
  });

  // Request URL 파라미터로 변환
  Map<String, String> toBestSellerQueryParameters() {
    return {
      'ttbkey': ttbKey,
      'output': output,
      'Version': version,
      'QueryType': queryType ?? '',
      'MaxResults': maxResults?.toString() ?? '',
      'start': start?.toString() ?? '',
      'SearchTarget': searchTarget ?? '',
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
}
