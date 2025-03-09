import 'package:books_room/components/color.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const Divider(height: 1, color: GRAY200_LINE);
          },
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildReviewCell(items[index]);
          },
        ),
      ),
    );
  }

  Widget _buildReviewCell(BookModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.author,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${item.oneLineComment}',
                style: const TextStyle(fontSize: 14),
              ),
              Spacer(),
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    if (i < item.starRating!)
                      const Icon(Icons.star, color: MAIN_COLOR, size: 20)
                    else
                      const Icon(
                        Icons.star_outline_outlined,
                        color: GRAY300_DISABLE,
                        size: 20,
                      ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
