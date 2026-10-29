import 'package:flutter/material.dart';
import '../../../../domain/models/book.dart';
import '../constants/app_colors.dart';

class ArchivalBookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const ArchivalBookCover({
    super.key,
    required this.book,
    this.width = 140,
    this.height = 200,
    this.onTap,
  });

  Color _getClothColor() {
    switch (book.format.toUpperCase()) {
      case 'EPUB':
        return const Color(0xFF1E293B); // Slate Navy
      case 'PDF':
        return const Color(0xFF3C1F1E); // Burgundy Clay
      case 'MOBI':
        return const Color(0xFF1E2E24); // Forest Leather
      case 'TXT':
      default:
        return const Color(0xFF292524); // Dark Charcoal
    }
  }

  Color _getBadgeColor() {
    switch (book.format.toUpperCase()) {
      case 'EPUB':
        return AppColors.badgeEpub;
      case 'PDF':
        return AppColors.badgePdf;
      case 'MOBI':
        return AppColors.badgeMobi;
      case 'TXT':
      default:
        return AppColors.badgeTxt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clothColor = _getClothColor();
    final badgeColor = _getBadgeColor();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: clothColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF44403C), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 3D Spine Shadow on left margin
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 12,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0x99000000), Color(0x00000000)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Inner Frame Border
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: const Color(0x28D6D3D1),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Format Pill Badge (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    book.format.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Content Area: Title, Divider, Author
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      // Title
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF5F0EB),
                          fontFamily: 'Georgia',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Terracotta Divider
                      Container(
                        width: 32,
                        height: 1.5,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),

                      // Author
                      Text(
                        book.author,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFA8A29E),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Bar at bottom
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 4,
                    color: const Color(0xFF171514),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (book.progressPercent / 100.0).clamp(0.0, 1.0),
                        child: Container(
                          color: AppColors.primaryHover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
