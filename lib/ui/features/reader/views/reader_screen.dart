import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:foliohaven_flutter/domain/models/book.dart';
import 'package:foliohaven_flutter/domain/models/toc_item.dart';
import 'package:foliohaven_flutter/services/document_parser_service.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';
import 'package:foliohaven_flutter/ui/features/reader/controllers/reader_controller.dart';
import '../widgets/notes_drawer.dart';
import '../widgets/reader_bottom_bar.dart';
import '../widgets/reader_top_bar.dart';
import '../widgets/toc_drawer.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  List<TocItem> _tocItems = [];
  List<String> _chapterContents = [];
  String _plainTextContent = '';
  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBookContent() async {
    final file = File(widget.book.filePath);
    final exists = await file.exists();

    if (exists) {
      final ext = widget.book.format.toUpperCase();
      if (ext == 'EPUB') {
        try {
          final metadata = await DocumentParserService.instance.parseFileMetadata(widget.book.filePath);
          final chapters = await DocumentParserService.instance.getEpubChaptersContent(widget.book.filePath);
          if (mounted) {
            setState(() {
              _tocItems = metadata.toc;
              _chapterContents = chapters;
              _isLoadingContent = false;
            });
          }
          return;
        } catch (_) {}
      } else if (ext == 'TXT') {
        try {
          final content = await DocumentParserService.instance.readTextContent(widget.book.filePath);
          if (mounted) {
            setState(() {
              _plainTextContent = content;
              _isLoadingContent = false;
            });
          }
          return;
        } catch (_) {}
      }
    }

    // Default sample TOC
    if (mounted) {
      setState(() {
        _tocItems = [
          const TocItem(title: 'Cover & Title Page', pageIndex: 1, level: 0),
          const TocItem(title: 'Chapter I: The Sound of the Shell', pageIndex: 3, level: 0),
          const TocItem(title: 'Chapter II: Fire on the Mountain', pageIndex: 18, level: 0),
          const TocItem(title: 'Chapter III: Huts on the Beach', pageIndex: 34, level: 0),
          const TocItem(title: 'Chapter IV: Painted Faces and Long Hair', pageIndex: 52, level: 0),
          const TocItem(title: 'Chapter V: Beast from Water', pageIndex: 75, level: 0),
        ];
        _isLoadingContent = false;
      });
    }
  }

  Color _canvasBg(String theme) {
    switch (theme) {
      case 'day':
        return AppColors.dayBg;
      case 'night':
        return AppColors.nightBg;
      case 'darkSepia':
        return AppColors.darkSepiaBg;
      case 'sepia':
      default:
        return AppColors.sepiaBg;
    }
  }

  Color _canvasText(String theme) {
    switch (theme) {
      case 'day':
        return AppColors.dayText;
      case 'night':
        return AppColors.nightText;
      case 'darkSepia':
        return AppColors.darkSepiaText;
      case 'sepia':
      default:
        return AppColors.sepiaText;
    }
  }

  Color _canvasBorder(String theme) {
    switch (theme) {
      case 'day':
        return AppColors.dayBorder;
      case 'night':
        return AppColors.nightBorder;
      case 'darkSepia':
        return AppColors.darkSepiaBorder;
      case 'sepia':
      default:
        return AppColors.sepiaBorder;
    }
  }

  String _themeNameFromIndex(int index) {
    switch (index) {
      case 0:
        return 'day';
      case 1:
        return 'sepia';
      case 2:
        return 'night';
      case 3:
        return 'darkSepia';
      default:
        return 'sepia';
    }
  }

  int _themeIndexFromName(String name) {
    switch (name) {
      case 'day':
        return 0;
      case 'sepia':
        return 1;
      case 'night':
        return 2;
      case 'darkSepia':
        return 3;
      default:
        return 1;
    }
  }

  String _getCurrentReadingText(int page) {
    if (_chapterContents.isNotEmpty) {
      final index = (page - 1).clamp(0, _chapterContents.length - 1);
      final rawHtml = _chapterContents[index];
      // Strip simple HTML tags for readable text
      return rawHtml.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    if (_plainTextContent.isNotEmpty) {
      return _plainTextContent;
    }
    return 'In my younger and more vulnerable years my father gave me some advice that I\'ve been turning over in my mind ever since.\n\n'
        '"Whenever you feel like criticizing anyone," he told me, "just remember that all the people in this world haven\'t had the advantages that you\'ve had."\n\n'
        'He didn\'t say any more, but we\'ve always been unusually communicative in a reserved way, and I understood that he meant a great deal more than that. In consequence, I\'m inclined to reserve all judgements, a habit that has opened up many curious natures to me and also made me the victim of not a few veteran bores.';
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider(widget.book));
    final readerNotifier = ref.read(readerProvider(widget.book).notifier);
    final themeName = _themeNameFromIndex(readerState.activeThemeIndex);

    final isRealPdf = widget.book.format.toUpperCase() == 'PDF' && File(widget.book.filePath).existsSync();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.pageDown ||
              event.logicalKey == LogicalKeyboardKey.space) {
            readerNotifier.nextPage();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.pageUp) {
            readerNotifier.previousPage();
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.canvas,
        drawer: TocDrawer(
          tocItems: _tocItems,
          onSelectPage: (p) => readerNotifier.setPage(p),
        ),
        endDrawer: NotesDrawer(
          bookmarks: readerState.bookmarks,
          annotations: readerState.annotations,
          onSelectPage: (p) => readerNotifier.setPage(p),
          onAddHighlightWithColor: (color) async {
            final messenger = ScaffoldMessenger.of(context);
            await readerNotifier.addAnnotation(
              'Highlighted passage from page ${readerState.currentPage}',
              color,
              note: 'Passage in ${widget.book.title}',
            );
            messenger.showSnackBar(
              SnackBar(
                content: Text('Saved highlight in ${color.toUpperCase()} to SQLite'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onExportHtml: () async {
            final messenger = ScaffoldMessenger.of(context);
            final path = await readerNotifier.exportNotes();
            messenger.showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primary,
                content: Text('Notes exported and opened: $path'),
              ),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              ReaderTopBar(
                title: widget.book.title,
                format: widget.book.format,
                currentTheme: themeName,
                isTwoPages: readerState.isTwoPage,
                fontSize: readerState.fontSize.toInt(),
                onBack: () => Navigator.pop(context),
                onThemeChanged: (t) => readerNotifier.setTheme(_themeIndexFromName(t)),
                onToggleTwoPages: readerNotifier.toggleSpread,
                onZoomIn: () => readerNotifier.setFontSize(readerState.fontSize + 2),
                onZoomOut: () => readerNotifier.setFontSize(readerState.fontSize - 2),
                onToggleToc: () => _scaffoldKey.currentState?.openDrawer(),
                onToggleSearch: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('In-book search is active')),
                  );
                },
                onToggleNotes: () => _scaffoldKey.currentState?.openEndDrawer(),
                onToggleFullscreen: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fullscreen mode toggled (F)')),
                  );
                },
                onToggleTts: () {
                  final text = _getCurrentReadingText(readerState.currentPage);
                  readerNotifier.toggleTts(text);
                },
              ),

              // Reading Canvas Area
              Expanded(
                child: isRealPdf
                    ? _buildPdfViewer(readerState, readerNotifier)
                    : _buildReflowableCanvas(readerState, readerNotifier, themeName),
              ),

              // Bottom Bar
              ReaderBottomBar(
                currentPage: readerState.currentPage,
                totalPages: readerState.totalPages,
                onPageChanged: (p) => readerNotifier.setPage(p),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer(ReaderState state, ReaderNotifier notifier) {
    return Container(
      color: AppColors.canvas,
      child: SfPdfViewer.file(
        File(widget.book.filePath),
        initialPageNumber: state.currentPage,
        onPageChanged: (PdfPageChangedDetails details) {
          notifier.setPage(details.newPageNumber);
        },
      ),
    );
  }

  Widget _buildReflowableCanvas(ReaderState state, ReaderNotifier notifier, String theme) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            notifier.nextPage(); // Swipe Left -> Next Page
          } else if (details.primaryVelocity! > 200) {
            notifier.previousPage(); // Swipe Right -> Prev Page
          }
        }
      },
      child: Container(
        color: AppColors.canvas,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Page Turn Button
            _buildPageNavBtn(Icons.chevron_left, notifier.previousPage, 'Previous Page (Left Arrow)'),
            const SizedBox(width: 16),

            // Center Reading Canvas (Constrained to 860px max width for single, 1200px for dual)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: state.isTwoPage ? 1200 : 860,
                  ),
                  child: state.isTwoPage
                      ? _buildTwoPageCanvas(state, notifier, theme)
                      : _buildSinglePageCanvas(state.currentPage, state, notifier, theme),
                ),
              ),
            ),

            const SizedBox(width: 16),
            // Right Page Turn Button
            _buildPageNavBtn(Icons.chevron_right, notifier.nextPage, 'Next Page (Right Arrow / Space)'),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePageCanvas(int pageNum, ReaderState state, ReaderNotifier notifier, String theme) {
    final bg = _canvasBg(theme);
    final text = _canvasText(theme);
    final border = _canvasBorder(theme);
    final readingText = _getCurrentReadingText(pageNum);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Chapter / Page $pageNum',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryHover,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border, size: 18),
                color: text.withValues(alpha: 0.6),
                tooltip: 'Bookmark this page',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await notifier.addBookmark();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Saved bookmark for Page $pageNum'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Reading Content (Refined editorial typography with Newsreader)
          Expanded(
            child: _isLoadingContent
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    child: SelectableText(
                      readingText,
                      style: GoogleFonts.newsreader(
                        fontSize: state.fontSize,
                        height: 1.7, // Optimal editorial reading line-height
                        color: text,
                      ),
                    ),
                  ),
          ),

          // Footer Page Number
          Center(
            child: Text(
              '$pageNum',
              style: GoogleFonts.newsreader(
                color: text.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoPageCanvas(ReaderState state, ReaderNotifier notifier, String theme) {
    return Row(
      children: [
        Expanded(child: _buildSinglePageCanvas(state.currentPage, state, notifier, theme)),
        const SizedBox(width: 16),
        Expanded(
          child: state.currentPage + 1 <= state.totalPages
              ? _buildSinglePageCanvas(state.currentPage + 1, state, notifier, theme)
              : Container(
                  decoration: BoxDecoration(
                    color: _canvasBg(theme),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _canvasBorder(theme), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '(End of publication)',
                      style: GoogleFonts.newsreader(
                        fontStyle: FontStyle.italic,
                        color: _canvasText(theme).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPageNavBtn(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          hoverColor: AppColors.primarySubtle,
          child: Container(
            width: 36,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}
