import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(bottom: BorderSide(color: Color(0xFF292524), width: 1)),
      ),
      child: Row(
        children: [
          // Cluster 1 (Left): Back to Library & Book Identity
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD6D3D1),
              backgroundColor: const Color(0xFF24201E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xFF3D3835)),
              ),
            ),
            icon: const Icon(Icons.arrow_back, size: 14),
            label: const Text('Library', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: const Color(0xFF383330)),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              format,
              style: const TextStyle(color: AppColors.primaryHover, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),

          const Spacer(),

          // Cluster 2 (Center): Theme Swatches, Layout, Font Size
          _buildThemeBtn('day', const Color(0xFFFAFAF9), const Color(0xFFA8A29E), 'Day'),
          const SizedBox(width: 4),
          _buildThemeBtn('sepia', const Color(0xFFF5EBD7), const Color(0xFFB49B78), 'Sepia'),
          const SizedBox(width: 4),
          _buildThemeBtn('night', const Color(0xFF121212), const Color(0xFF52525B), 'Night'),
          const SizedBox(width: 4),
          _buildThemeBtn('darkSepia', const Color(0xFF251D16), const Color(0xFF634832), 'Dark Sepia'),

          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: const Color(0xFF383330)),
          const SizedBox(width: 12),

          // 1 Page / 2 Pages Toggle
          OutlinedButton.icon(
            onPressed: onToggleTwoPages,
            style: OutlinedButton.styleFrom(
              foregroundColor: isTwoPages ? const Color(0xFFFFEDD5) : const Color(0xFFD6D3D1),
              backgroundColor: isTwoPages ? const Color(0xFF382A20) : const Color(0xFF24201E),
              side: BorderSide(color: isTwoPages ? AppColors.primaryHover : const Color(0xFF3D3835)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            icon: Icon(isTwoPages ? Icons.auto_stories : Icons.menu_book, size: 14),
            label: Text(isTwoPages ? '2 Pages' : '1 Page', style: const TextStyle(fontSize: 12)),
          ),

          const SizedBox(width: 8),

          // Zoom Out (A-) / Zoom In (A+)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF24201E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3D3835)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onZoomOut,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text('A-', style: TextStyle(color: Color(0xFFD6D3D1), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                Container(width: 1, height: 16, color: const Color(0xFF3D3835)),
                InkWell(
                  onTap: onZoomIn,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text('A+', style: TextStyle(color: Color(0xFFD6D3D1), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Cluster 3 (Right): Contents, Search, Notes, Speech, Fullscreen
          _buildActionBtn(Icons.list_alt, 'Contents', onToggleToc),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.search, 'Search', onToggleSearch),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.edit_note, 'Notes', onToggleNotes),
          const SizedBox(width: 4),
          _buildActionBtn(Icons.volume_up_outlined, 'Read Aloud', onToggleTts),
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
          color: isSelected ? const Color(0xFF382A20) : const Color(0xFF24201E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.primaryHover : const Color(0xFF3D3835), width: isSelected ? 1.5 : 1.0),
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
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFEDD5) : const Color(0xFFA8A29E),
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
      color: const Color(0xFFD6D3D1),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF24201E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFF3D3835)),
        ),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: onTap,
    );
  }
}
