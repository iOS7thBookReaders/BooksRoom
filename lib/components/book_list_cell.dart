import 'package:books_room/screens/book_detail_screen.dart';
import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';

import '../models/book_response.dart';
import 'format.dart';

class BookListCell extends StatelessWidget {
  final BookItem bookItem;
  const BookListCell({super.key, required this.bookItem});

  @override
  Widget build(BuildContext context) {
    Format format = Format();

    String isbn13 = bookItem.isbn13 ?? '';
    String title = bookItem.title ?? '';
    String author = bookItem.author ?? '';
    String pubdate = bookItem.pubDate ?? '';
    String publisher = bookItem.publisher ?? '';
    String cover = bookItem.cover ?? '';
    String categoryName = bookItem.categoryName ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              print("🔥 isbn13: $isbn13");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(bookISBN: isbn13),
                ),
              );
            },
            child: Row(
              children: [
                Image.network(
                  cover,
                  width: 80,
                  height: 100,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '[${format.formatCategoryName(categoryName)}] ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: GRAY500,
                              ),
                            ),
                            TextSpan(
                              text: format.formatTitle(title)[0],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (format.formatTitle(title).length > 1)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                format.formatTitle(title)[1],
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(author, style: TextStyle(fontSize: 12)),
                          Spacer(),
                        ],
                      ),

                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(publisher, style: TextStyle(fontSize: 12)),
                          Text(
                            ' | ${format.formatYearFromPubDate(pubdate)}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
