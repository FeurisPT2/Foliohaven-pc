import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmptyBookshelfWidget extends StatelessWidget {
  final VoidCallback? onAddBook;

  const EmptyBookshelfWidget({super.key, this.onAddBook});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(220, 130),
              painter: _BookshelfPainter(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Library is Waiting',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 360,
              child: Text(
                'A calm place for your books — no nags, no timers, no subscriptions. Just pure reading.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Your First Book',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Supports EPUB, PDF, MOBI, and TXT • Drop files anywhere to import',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookshelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plankPaint = Paint()..color = const Color(0xFF3D3835);
    final bracketPaint = Paint()
      ..color = const Color(0xFF57534E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashBookPaint = Paint()
      ..color = const Color(0xFF57534E)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final ghostFill = Paint()..color = const Color(0x333D3835);
    final centerFill = Paint()..color = const Color(0x6644403C);
    final centerBorder = Paint()
      ..color = const Color(0xFFA8A29E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final ribbonPaint = Paint()..color = AppColors.primary;

    // Shelf base plank
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(20, 105, 180, 6), const Radius.circular(3)),
      plankPaint,
    );

    // Support brackets
    canvas.drawLine(const Offset(40, 111), const Offset(40, 120), bracketPaint);
    canvas.drawLine(const Offset(180, 111), const Offset(180, 120), bracketPaint);

    // Bookends
    canvas.drawLine(const Offset(28, 105), const Offset(28, 75), bracketPaint);
    canvas.drawLine(const Offset(28, 75), const Offset(34, 75), bracketPaint);
    canvas.drawLine(const Offset(192, 105), const Offset(192, 75), bracketPaint);
    canvas.drawLine(const Offset(192, 75), const Offset(186, 75), bracketPaint);

    // Ghost Book 1 (Left tall)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(42, 38, 20, 67), const Radius.circular(2)), ghostFill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(42, 38, 20, 67), const Radius.circular(2)), dashBookPaint);

    // Ghost Book 2 (Medium)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(66, 48, 18, 57), const Radius.circular(2)), ghostFill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(66, 48, 18, 57), const Radius.circular(2)), dashBookPaint);

    // Center Book (Solid with ribbon)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(88, 28, 28, 77), const Radius.circular(3)), centerFill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(88, 28, 28, 77), const Radius.circular(3)), centerBorder);

    // Terracotta Ribbon on Center Book
    final ribbonPath = Path()
      ..moveTo(100, 28)
      ..lineTo(100, 48)
      ..lineTo(104, 44)
      ..lineTo(108, 48)
      ..lineTo(108, 28)
      ..close();
    canvas.drawPath(ribbonPath, ribbonPaint);

    // Ghost Book 4 (Compact)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(120, 52, 18, 53), const Radius.circular(2)), ghostFill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(120, 52, 18, 53), const Radius.circular(2)), dashBookPaint);

    // Ghost Book 5 (Right medium tall)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(142, 42, 22, 63), const Radius.circular(2)), ghostFill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(142, 42, 22, 63), const Radius.circular(2)), dashBookPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
