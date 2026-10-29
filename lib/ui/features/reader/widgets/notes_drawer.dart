import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foliohaven_flutter/domain/models/annotation.dart';
import 'package:foliohaven_flutter/domain/models/bookmark.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';

class NotesDrawer extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final List<Annotation> annotations;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<String> onAddHighlightWithColor;
  final VoidCallback onExportHtml;

  const NotesDrawer({
    super.key,
    required this.bookmarks,
    required this.annotations,
    required this.onSelectPage,
    required this.onAddHighlightWithColor,
    required this.onExportHtml,
  });

  @override
  State<NotesDrawer> createState() => _NotesDrawerState();
}

class _NotesDrawerState extends State<NotesDrawer> {
  Color _colorForName(String name) {
    switch (name.toLowerCase()) {
      case 'emerald':
        return AppColors.highlightEmerald;
      case 'azure':
        return AppColors.highlightAzure;
      case 'rose':
        return AppColors.highlightRose;
      case 'amber':
      default:
        return AppColors.highlightAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bookmarks & Notes',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // 4-Color Highlighter Palette Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HIGHLIGHT PALETTE',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildColorSwatch('amber', AppColors.highlightAmber, 'Amber'),
                      const SizedBox(width: 10),
                      _buildColorSwatch('emerald', AppColors.highlightEmerald, 'Emerald'),
                      const SizedBox(width: 10),
                      _buildColorSwatch('azure', AppColors.highlightAzure, 'Azure'),
                      const SizedBox(width: 10),
                      _buildColorSwatch('rose', AppColors.highlightRose, 'Rose'),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: widget.onExportHtml,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.download, size: 14),
                        label: Text(
                          'Export',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // Bookmarks section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'BOOKMARKS',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: widget.bookmarks.isEmpty
                  ? Center(
                      child: Text(
                        'No bookmarks saved.',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.bookmarks.length,
                      itemBuilder: (context, index) {
                        final bm = widget.bookmarks[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.bookmark, color: AppColors.primary, size: 16),
                          title: Text(
                            bm.title,
                            style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 12),
                          ),
                          subtitle: Text(
                            'Page ${bm.page}',
                            style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 10),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSelectPage(bm.page);
                          },
                        );
                      },
                    ),
            ),

            const Divider(color: AppColors.borderSubtle, height: 1),

            // Highlights & Annotations section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'ANNOTATIONS',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: widget.annotations.isEmpty
                  ? Center(
                      child: Text(
                        'No annotations saved.',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.annotations.length,
                      itemBuilder: (context, index) {
                        final a = widget.annotations[index];
                        final c = _colorForName(a.color);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border(left: BorderSide(color: c, width: 3.5)),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelectPage(a.page);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${a.text}"',
                                  style: GoogleFonts.newsreader(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if (a.note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    a.note,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Page ${a.page}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color, String tooltip) {
    return Tooltip(
      message: '$tooltip Highlight',
      child: InkWell(
        onTap: () => widget.onAddHighlightWithColor(name),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
        ),
      ),
    );
  }
}
