import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';

class ReaderBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const ReaderBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double pct = totalPages > 0 ? (currentPage / totalPages * 100.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          // Slider with Terracotta Theme
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primaryHover,
                inactiveTrackColor: AppColors.border,
                trackHeight: 4.0,
                thumbColor: AppColors.textPrimary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayColor: AppColors.primaryGlow,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              ),
              child: Slider(
                value: currentPage.toDouble().clamp(1.0, totalPages.toDouble()),
                min: 1.0,
                max: totalPages > 0 ? totalPages.toDouble() : 1.0,
                divisions: totalPages > 1 ? totalPages - 1 : 1,
                onChanged: (val) {
                  onPageChanged(val.round());
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Page & Percentage Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Page $currentPage of $totalPages • ${pct.toInt()}%',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
