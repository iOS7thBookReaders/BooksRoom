import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookISBN;
  const BookDetailScreen({super.key, required this.bookISBN});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Book Detail'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(child: Text(bookISBN)),
    );
  }
}
