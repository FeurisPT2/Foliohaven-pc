import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  List<Color> _getCoverGradient() {
    switch (book.format.toUpperCase()) {
      case 'EPUB':
        return const [Color(0xFF1E2D4A), Color(0xFF111A2E)];
      case 'PDF':
        return const [Color(0xFF451E1D), Color(0xFF261010)];
      case 'MOBI':
        return const [Color(0xFF1B3828), Color(0xFF0F2117)];
      case 'TXT':
      default:
        return const [Color(0xFF38291F), Color(0xFF201610)];
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
    final gradient = _getCoverGradient();
    final badgeColor = _getBadgeColor();
    final progress = (book.progressPercent / 100.0).clamp(0.0, 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            ),
            border: Border.all(color: const Color(0x38FFFFFF), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 12,
                offset: Offset(4, 6),
              ),
              BoxShadow(
                color: Color(0x22C2410C),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Realistic Book Spine Crease & Shadow (Left edge)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 14,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      bottomLeft: Radius.circular(3),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xB3000000),
                        Color(0x22000000),
                        Color(0x33FFFFFF),
                        Color(0x00000000),
                      ],
                      stops: [0.0, 0.45, 0.6, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // 2. Subtle Lighting Sheen (Top-to-bottom diagonal sheen)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      topLeft: Radius.circular(3),
                      bottomLeft: Radius.circular(3),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 3. Inner Embossed Decorative Frame
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, top: 10, right: 10, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0x38D4AF37), // Subtle gold foil outline
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Bookmark Ribbon (Top edge)
              Positioned(
                top: 0,
                left: 28,
                child: CustomPaint(
                  size: const Size(14, 22),
                  painter: _RibbonPainter(
                    color: book.isFavorite ? AppColors.starGold : AppColors.primary,
                  ),
                ),
              ),

              // 5. Format Badge (Top Right Pill)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    book.format.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // 6. Centered Title & Author (Classical Typography)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 18, top: 24, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Book Title
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.newsreader(
                          color: const Color(0xFFFAF7F2),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          shadows: const [
                            Shadow(
                              color: Color(0x88000000),
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Golden/Terracotta Accent Divider
                      Container(
                        width: 28,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Author
                      Text(
                        book.author,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFC7BFB5),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 7. Reading Progress Bar & Status (Bottom)
              Positioned(
                left: 18,
                right: 14,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3.5,
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: progress >= 1.0
                                      ? [AppColors.success, const Color(0xFF34D399)]
                                      : [AppColors.primary, AppColors.primaryHover],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final Color color;
  const _RibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 4)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Subtle edge shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) => oldDelegate.color != color;
}
