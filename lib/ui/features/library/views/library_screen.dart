import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:foliohaven_flutter/domain/models/book.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';
import 'package:foliohaven_flutter/ui/core/widgets/archival_book_cover.dart';
import 'package:foliohaven_flutter/ui/core/widgets/empty_bookshelf.dart';
import 'package:foliohaven_flutter/ui/core/widgets/responsive_scaffold.dart';
import 'package:foliohaven_flutter/ui/features/library/controllers/library_controller.dart';
import 'package:foliohaven_flutter/ui/features/reader/views/reader_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDragging = false;
  String _sortBy = 'recent'; // 'recent', 'title', 'progress'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndImportBooks() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub', 'pdf', 'mobi', 'cbz', 'fb2', 'txt'],
        allowMultiple: true,
      );

      if (result != null && result.paths.isNotEmpty) {
        final validPaths = result.paths.whereType<String>().toList();
        if (validPaths.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.surfaceHover,
                content: Text(
                  'Đang nhập ${validPaths.length} tệp sách vào thư viện...',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            );
          }
          await ref.read(libraryControllerProvider).importFiles(validPaths);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primary,
                content: Text(
                  'Đã nhập thành công ${validPaths.length} cuốn sách vào FolioHaven!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Lỗi khi chọn tệp: $e'),
          ),
        );
      }
    }
  }

  void _onAddCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Tạo Kệ Sách Mới',
          style: GoogleFonts.newsreader(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Tên kệ sách (ví dụ: Nghiên cứu, Triết học...)',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tạo Kệ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(libraryControllerProvider).addCategory(result);
    }
  }

  void _showBookContextMenu(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(book.format, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle),
              ListTile(
                leading: Icon(
                  book.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: book.isFavorite ? AppColors.starGold : AppColors.textSecondary,
                ),
                title: Text(
                  book.isFavorite ? 'Xóa khỏi Mục Yêu thích' : 'Thêm vào Mục Yêu thích',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(libraryControllerProvider).toggleFavorite(book.id, book.isFavorite);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                title: const Text('Đọc Sách Ngay', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _openReader(book);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: const Text('Xóa khỏi Thư viện', style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteBook(book);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteBook(Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
        title: Text(
          'Xóa Sách Khỏi Kệ',
          style: GoogleFonts.newsreader(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tác phẩm "${book.title}" khỏi thư viện FolioHaven?',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Giữ Lại', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(libraryControllerProvider).deleteBook(book.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Xác Nhận Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openReader(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(book: book),
      ),
    ).then((_) {
      ref.read(libraryControllerProvider).loadBooks();
    });
  }

  List<Book> _getSortedBooks(List<Book> books) {
    final list = List<Book>.from(books);
    if (_sortBy == 'title') {
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_sortBy == 'progress') {
      list.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final libraryCtrl = ref.watch(libraryControllerProvider);
    final sortedBooks = _getSortedBooks(libraryCtrl.books);

    final content = Stack(
      children: [
        ResponsiveScaffold(
          sidebar: _buildSidebar(libraryCtrl),
          body: Container(
            color: AppColors.canvas,
            child: Column(
              children: [
                // 1. Refined Main Action & Search Bar
                _buildTopBar(libraryCtrl),

                // 2. Main Bookshelf Area
                Expanded(
                  child: libraryCtrl.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : sortedBooks.isEmpty
                          ? EmptyBookshelfWidget(
                              onAddBook: _pickAndImportBooks,
                            )
                          : libraryCtrl.isGridView
                              ? _buildGridView(sortedBooks)
                              : _buildTableView(sortedBooks),
                ),

                // 3. Subtle Status Bar
                _buildBottomStatusBar(sortedBooks.length, libraryCtrl.selectedCategory),
              ],
            ),
          ),
        ),

        // Drag and Drop Overlay
        if (_isDragging)
          Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySubtle,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.file_download_outlined, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Thả tệp sách vào đây để nhập ngay',
                      style: GoogleFonts.newsreader(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hỗ trợ đầy đủ: EPUB • PDF • MOBI • CBZ • FB2 • TXT',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return content;
    }

    return DropTarget(
      onEnter: (detail) => setState(() => _isDragging = true),
      onLeave: () => setState(() => _isDragging = false),
      onDrop: (detail) async {
        setState(() => _isDragging = false);
        final paths = <String>[];
        for (final item in detail.items) {
          if (item is DropFileItem && item.localPath != null) {
            paths.add(item.localPath!);
          }
        }
        if (paths.isNotEmpty) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceHover,
              content: Text('Đang xử lý ${paths.length} tệp được thả vào...'),
            ),
          );
          await libraryCtrl.importFiles(paths);
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text(
                'Đã nhập thành công ${paths.length} cuốn sách vào FolioHaven!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      },
      child: content,
    );
  }

  Widget _buildSidebar(LibraryController libraryCtrl) {
    return Container(
      color: AppColors.sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FolioHaven Brand Logo & Identity
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryPressed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'F',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FolioHaven',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Thư viện & Trình đọc sách',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 2. Primary Add Books Action Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryHover],
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _pickAndImportBooks,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                '+ Thêm sách mới...',
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 3. Main Navigation Items
          _buildNavItem('Tất cả sách', 'All Books', Icons.auto_stories_rounded, libraryCtrl, libraryCtrl.books.length),
          _buildNavItem('Sách yêu thích', 'Favorites', Icons.star_rounded, libraryCtrl, null),
          _buildNavItem('Đang đọc gần đây', 'Recent', Icons.history_rounded, libraryCtrl, null),

          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 8),

          // 4. Custom Shelves Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'KỆ SÁCH CỦA BẠN',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                tooltip: 'Thêm Kệ Sách Mới',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _onAddCategory,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 5. Category Shelves List
          Expanded(
            child: ListView(
              children: [
                for (final cat in libraryCtrl.categories)
                  if (cat != 'All Books' && cat != 'Favorites' && cat != 'Recent')
                    _buildNavItem(cat, cat, Icons.folder_rounded, libraryCtrl, null),
              ],
            ),
          ),

          // 6. Bottom Library Card (Stats)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Cục bộ & Bảo mật',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tất cả sách lưu trong máy bạn',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textMuted,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, String categoryKey, IconData icon, LibraryController libraryCtrl, int? count) {
    final isSelected = libraryCtrl.selectedCategory == categoryKey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: InkWell(
        onTap: () => libraryCtrl.setSelectedCategory(categoryKey),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceHover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppColors.border) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(LibraryController libraryCtrl) {
    final categoryName = libraryCtrl.selectedCategory == 'All Books'
        ? 'Tất cả sách'
        : libraryCtrl.selectedCategory == 'Favorites'
            ? 'Sách yêu thích'
            : libraryCtrl.selectedCategory == 'Recent'
                ? 'Đang đọc gần đây'
                : libraryCtrl.selectedCategory;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          return Row(
            children: [
              // Current Shelf Title & Book Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryName,
                    style: GoogleFonts.newsreader(
                      color: AppColors.textPrimary,
                      fontSize: isCompact ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${libraryCtrl.books.length} tác phẩm',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Search Field
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isCompact ? 140 : 260,
                  minWidth: 90,
                ),
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => libraryCtrl.setSearchQuery(val),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      hintText: isCompact ? 'Tìm...' : 'Tìm sách, tác giả...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryHover),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Sort Dropdown
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600),
                    items: [
                      DropdownMenuItem(value: 'recent', child: Text(isCompact ? 'Gần đây' : 'Gần đây nhất')),
                      DropdownMenuItem(value: 'title', child: Text(isCompact ? 'Tên (A-Z)' : 'Tên sách (A-Z)')),
                      DropdownMenuItem(value: 'progress', child: Text(isCompact ? 'Tiến độ' : 'Tiến độ đọc')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // View Mode Switcher: Grid vs Table
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                      color: libraryCtrl.isGridView ? Colors.white : AppColors.textSecondary,
                      style: IconButton.styleFrom(
                        backgroundColor: libraryCtrl.isGridView ? AppColors.primary : Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(7)),
                        ),
                        padding: const EdgeInsets.all(6),
                      ),
                      tooltip: 'Xem dạng Kệ sách',
                      onPressed: () => libraryCtrl.setGridView(true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
                      color: !libraryCtrl.isGridView ? Colors.white : AppColors.textSecondary,
                      style: IconButton.styleFrom(
                        backgroundColor: !libraryCtrl.isGridView ? AppColors.primary : Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(7)),
                        ),
                        padding: const EdgeInsets.all(6),
                      ),
                      tooltip: 'Xem dạng Danh sách chi tiết',
                      onPressed: () => libraryCtrl.setGridView(false),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 140 / 240,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _BookGridCard(
            book: book,
            onTap: () => _openReader(book),
            onMenu: () => _showBookContextMenu(context, book),
            onToggleFavorite: () => ref.read(libraryControllerProvider).toggleFavorite(book.id, book.isFavorite),
          );
        },
      ),
    );
  }

  Widget _buildTableView(List<Book> books) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      itemCount: books.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.borderSubtle, height: 1),
      itemBuilder: (context, index) {
        final b = books[index];
        return InkWell(
          onTap: () => _openReader(b),
          onSecondaryTap: () => _showBookContextMenu(context, b),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Format Tag
                Container(
                  width: 44,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    b.format,
                    style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),

                // Title & Author
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Progress Bar & Percentage
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trang ${b.currentPage} / ${b.totalPages}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          Text('${b.progressPercent.toInt()}%', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (b.progressPercent / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.surface,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Favorite Button
                IconButton(
                  icon: Icon(
                    b.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: b.isFavorite ? AppColors.starGold : AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => ref.read(libraryControllerProvider).toggleFavorite(b.id, b.isFavorite),
                ),

                // Context Menu
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: () => _showBookContextMenu(context, b),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomStatusBar(int count, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 7, color: AppColors.success),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Thư viện sẵn sàng • $count cuốn sách',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'FolioHaven • Offline 100%',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _BookGridCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onMenu;
  final VoidCallback onToggleFavorite;

  const _BookGridCard({
    required this.book,
    required this.onTap,
    required this.onMenu,
    required this.onToggleFavorite,
  });

  @override
  State<_BookGridCard> createState() => _BookGridCardState();
}

class _BookGridCardState extends State<_BookGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onMenu,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surfaceHover : AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.borderSubtle,
              width: 1.2,
            ),
            boxShadow: [
              if (_isHovered)
                const BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                child: Center(
                  child: ArchivalBookCover(
                    book: widget.book,
                    onTap: widget.onTap,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                widget.book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),

              // Author
              Text(
                widget.book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),

              // Progress percentage & Pages
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.book.progressPercent >= 100
                        ? 'Đã đọc xong'
                        : '${widget.book.progressPercent.toInt()}% hoàn thành',
                    style: TextStyle(
                      color: widget.book.progressPercent >= 100 ? AppColors.success : AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onToggleFavorite,
                    child: Icon(
                      widget.book.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: widget.book.isFavorite ? AppColors.starGold : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
