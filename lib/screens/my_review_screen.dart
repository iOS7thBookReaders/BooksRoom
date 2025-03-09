import 'package:flutter/material.dart';

import '../models/book_model.dart';

class MyReviewScreen extends StatelessWidget {
  final List<BookModel> items;
  final String title;

  MyReviewScreen({super.key, required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView.builder(
        itemCount: 0,
        itemBuilder: (context, index) {
          return null;
        },
      ),
    );
  }
}
