// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book_request.dart';
import '../models/book_response.dart';

class ApiService {
  final String _baseURL = 'http://www.aladin.co.kr/ttb/api';
  String dateFormatted = '';

  Future<BookResponse> fetchBookBestseller(
    BookRequestModel requestModel,
  ) async {
    final queryParameters = requestModel.toBestSellerQueryParameters();
    final uri = Uri.parse(
      '$_baseURL/ItemList.aspx',
    ).replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        print("통신 성공");
        final data = json.decode(response.body);
        final bookResponse = BookResponse.fromJson(data);
        return bookResponse;
      } else {
        print("통신 실패");
        throw Exception('Failed to load data!');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<BookResponse> fetchBookDetail(BookRequestModel requestModel) async {
    final queryParameters = requestModel.toDetailQueryParameters();
    final uri = Uri.parse(
      '$_baseURL/ItemLookUp.aspx',
    ).replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        print("통신 성공");
        final data = json.decode(response.body);
        final bookResponse = BookResponse.fromJson(data);
        return bookResponse;
      } else {
        print("통신 실패");
        throw Exception('Failed to load data!');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<BookResponse> fetchSearchResult(BookRequestModel requestModel) async {
    final queryParameters = requestModel.toSearchQueryParameters();
    final uri = Uri.parse(
      '$_baseURL/ItemSearch.aspx',
    ).replace(queryParameters: queryParameters);
    print(uri);
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        print("통신 성공");
        final data = json.decode(response.body);
        final bookResponse = BookResponse.fromJson(data);
        return bookResponse;
      } else {
        print("통신 실패");
        throw Exception('Failed to load data!');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
