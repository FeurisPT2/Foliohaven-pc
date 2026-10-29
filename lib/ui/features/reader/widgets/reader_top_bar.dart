import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';

class ReaderTopBar extends StatelessWidget {
  final String title;
  final String format;
  final String currentTheme;
  final bool isTwoPages;
  final int fontSize;
  final VoidCallback onBack;
  final ValueChanged<String> onThemeChanged;
  final VoidCallback onToggleTwoPages;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleToc;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleNotes;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onToggleTts;

  const ReaderTopBar({
    super.key,
    required this.title,
    required this.format,
    required this.currentTheme,
    required this.isTwoPages,
    required this.fontSize,
    required this.onBack,
    required this.onThemeChanged,
    required this.onToggleTwoPages,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleToc,
    required this.onToggleSearch,
    required this.onToggleNotes,
    required this.onToggleFullscreen,
    required this.onToggleTts,
  });

  Color _badgeColor(String fmt) {
    switch (fmt.toUpperCase()) {
      case 'EPUB':
        return AppColors.badgeEpub;
      case 'PDF':
        return AppColors.badgePdf;
      case 'MOBI':
        return AppColors.badgeMobi;
      default:
        return AppColors.badgeTxt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor(format);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          // Left: Return to Library
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            icon: const Icon(Icons.arrow_back, size: 14),
            label: Text(
              'Library',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: AppColors.border),
          const SizedBox(width: 12),

          // Book Title
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.newsreader(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Format Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              format.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),

          // Center: Reading Canvas Theme Swatches
          _buildThemeBtn('day', AppColors.dayBg, AppColors.dayBorder, 'Day'),
          const SizedBox(width: 4),
          _buildThemeBtn('sepia', AppColors.sepiaBg, AppColors.sepiaBorder, 'Sepia'),
          const SizedBox(width: 4),
          _buildThemeBtn('night', AppColors.nightBg, AppColors.nightBorder, 'Night'),
          const SizedBox(width: 4),
          _buildThemeBtn('darkSepia', AppColors.darkSepiaBg, AppColors.darkSepiaBorder, 'Twilight'),

          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: AppColors.border),
          const SizedBox(width: 12),

          // 1 Page / 2 Pages Toggle
          OutlinedButton.icon(
            onPressed: onToggleTwoPages,
            style: OutlinedButton.styleFrom(
              foregroundColor: isTwoPages ? const Color(0xFFFFEDD5) : AppColors.textSecondary,
              backgroundColor: isTwoPages ? AppColors.primarySubtle : AppColors.surface,
              side: BorderSide(color: isTwoPages ? AppColors.primaryHover : AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            icon: Icon(
              isTwoPages ? Icons.auto_stories : Icons.menu_book,
              size: 14,
              color: isTwoPages ? AppColors.primaryHover : AppColors.textSecondary,
            ),
            label: Text(
              isTwoPages ? '2 Pages' : '1 Page',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(width: 8),

          // Zoom Out (A-) / Zoom In (A+)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onZoomOut,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      'A-',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 16, color: AppColors.border),
                InkWell(
                  onTap: onZoomIn,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      'A+',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Right: Table of Contents, Search, Notes, Read Aloud, Fullscreen
          _buildActionBtn(Icons.list_alt, 'Table of Contents', onToggleToc),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.search, 'Search Text', onToggleSearch),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.edit_note, 'Notes & Highlights', onToggleNotes),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.volume_up_outlined, 'Read Aloud (TTS)', onToggleTts),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.fullscreen, 'Fullscreen', onToggleFullscreen),
        ],
      ),
    );
  }

  Widget _buildThemeBtn(String themeKey, Color bg, Color border, String label) {
    final isSelected = currentTheme == themeKey;
    return InkWell(
      onTap: () => onThemeChanged(themeKey),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primaryHover : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.5),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? const Color(0xFFFFEDD5) : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: AppColors.textSecondary,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: onTap,
    );
  }
}
