// ignore_for_file: avoid_print

import 'package:books_room/screens/book_detail_screen.dart';
import 'package:books_room/components/color.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:books_room/models/book_response.dart';
import 'format.dart';

class BookListCell extends StatefulWidget {
  final BookItem bookItem;
  final String imageUrl;

  const BookListCell({
    super.key,
    required this.bookItem,
    this.imageUrl = 'https://picsum.photos/seed/picsum/80/100',
  });

  @override
  State<BookListCell> createState() => _BookListCellState();
}

class _BookListCellState extends State<BookListCell> {
  late Future<Image> _imageFuture;
  Future<Image> loadImage() async {
    try {
      return Image.network(widget.imageUrl);
    } catch (e) {
      throw Exception("Image loading failed");
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFuture = loadImage();
  }

  @override
  void dispose() {
    // 이미지 관련 리소스 명시적 해제
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Format format = Format();

    String isbn13 = widget.bookItem.isbn13 ?? '';
    String title = widget.bookItem.title ?? '';
    String author = widget.bookItem.author ?? '';
    String pubdate = widget.bookItem.pubDate ?? '';
    String publisher = widget.bookItem.publisher ?? '';
    String cover = widget.bookItem.cover ?? '';
    String categoryName = widget.bookItem.categoryName ?? '';

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
                CachedNetworkImage(
                  imageUrl: cover,
                  width: 80,
                  height: 100,
                  fit: BoxFit.fitHeight,
                  fadeInDuration: Duration.zero,
                  placeholderFadeInDuration: Duration.zero,
                  placeholder:
                      (context, url) => Container(
                        width: 80,
                        height: 100,
                        color: MAIN_COLOR.withAlpha(0),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              MAIN_COLOR.withAlpha(0),
                            ),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: MAIN_COLOR),
                      ),
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
                          Expanded(
                            child: Text(
                              author,
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                            ),
                          ),
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
