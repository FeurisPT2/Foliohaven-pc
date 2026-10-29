import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class EmptyBookshelfWidget extends StatelessWidget {
  final VoidCallback? onAddBook;

  const EmptyBookshelfWidget({super.key, this.onAddBook});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(220, 120),
                painter: _ArchivalBookshelfPainter(),
              ),
              const SizedBox(height: 28),
              Text(
                'Kệ sách đang chờ bạn',
                style: GoogleFonts.newsreader(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Không gian đọc sách tĩnh lặng, không quảng cáo, không đếm ngược hay giới hạn. '
                'Kéo thả tệp sách vào đây hoặc bấm nút bên dưới để bắt đầu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onAddBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primaryGlow,
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  '+ Thêm cuốn sách đầu tiên',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  'Hỗ trợ: EPUB • PDF • MOBI • CBZ • FB2 • TXT',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

class _ArchivalBookshelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plankPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A3E38), Color(0xFF2C2420)],
      ).createShader(Rect.fromLTWH(15, 95, size.width - 30, 8));

    final bracketPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final bookPaint1 = Paint()..color = const Color(0xFF23354E); // Navy
    final bookPaint2 = Paint()..color = const Color(0xFF4A2524); // Burgundy
    final bookPaint3 = Paint()..color = const Color(0xFF244030); // Forest
    final bookPaint4 = Paint()..color = AppColors.primary; // Terracotta Accent

    // Shelf base plank
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(15, 95, size.width - 30, 7), const Radius.circular(3.5)),
      plankPaint,
    );

    // Support brackets
    canvas.drawLine(const Offset(35, 102), const Offset(35, 114), bracketPaint);
    canvas.drawLine(Offset(size.width - 35, 102), Offset(size.width - 35, 114), bracketPaint);

    // Book 1 (Tilted left)
    canvas.save();
    canvas.translate(45, 95);
    canvas.rotate(-0.08);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, -68, 18, 68), const Radius.circular(2)), bookPaint1);
    canvas.restore();

    // Book 2 (Standing tall)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(68, 22, 22, 73), const Radius.circular(2)),
      bookPaint2,
    );

    // Book 3 (Hero Book with gold bookmark)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(94, 15, 28, 80), const Radius.circular(3)),
      bookPaint4,
    );

    // Bookmark on Hero Book
    final ribbonPath = Path()
      ..moveTo(104, 15)
      ..lineTo(104, 38)
      ..lineTo(108, 34)
      ..lineTo(112, 38)
      ..lineTo(112, 15)
      ..close();
    canvas.drawPath(ribbonPath, Paint()..color = const Color(0xFFFBBF24));

    // Book 4 (Compact)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(126, 32, 20, 63), const Radius.circular(2)),
      bookPaint3,
    );

    // Book 5 (Tilted right)
    canvas.save();
    canvas.translate(150, 95);
    canvas.rotate(0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, -60, 16, 60), const Radius.circular(2)), bookPaint1);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
