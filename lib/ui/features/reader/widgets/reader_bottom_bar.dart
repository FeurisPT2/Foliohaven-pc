import 'package:flutter/material.dart';
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
        border: Border(top: BorderSide(color: Color(0xFF292524), width: 1)),
      ),
      child: Row(
        children: [
          // Slider with Terracotta Theme
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primaryHover,
                inactiveTrackColor: const Color(0xFF383330),
                trackHeight: 4.0,
                thumbColor: Colors.white,
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
          Text(
            'Page $currentPage of $totalPages • ${pct.toInt()}%',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
