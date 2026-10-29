import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';

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
              SnackBar(content: Text('Importing ${validPaths.length} book(s)...')),
            );
          }
          await ref.read(libraryControllerProvider).importFiles(validPaths);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primary,
                content: Text('Successfully imported ${validPaths.length} book(s) into FolioHaven!'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
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
        title: const Text('New Category', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Category Name...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
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
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                book.isFavorite ? Icons.star : Icons.star_border,
                color: AppColors.primary,
              ),
              title: Text(
                book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(libraryControllerProvider).toggleFavorite(book.id, book.isFavorite);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete from Library', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteBook(book);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBook(Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Book', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${book.title}" from your library?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(libraryControllerProvider).deleteBook(book.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryCtrl = ref.watch(libraryControllerProvider);

    final content = Stack(
      children: [
        ResponsiveScaffold(
          sidebar: _buildSidebar(libraryCtrl),
          body: Container(
            color: AppColors.background,
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(libraryCtrl),

                // Main Content Area
                Expanded(
                  child: libraryCtrl.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : libraryCtrl.books.isEmpty
                          ? EmptyBookshelfWidget(
                              onAddBook: _pickAndImportBooks,
                            )
                          : libraryCtrl.isGridView
                              ? _buildGridView(libraryCtrl.books)
                              : _buildTableView(libraryCtrl.books),
                ),

                // Bottom Status Bar
                _buildBottomStatusBar(libraryCtrl.books.length, libraryCtrl.selectedCategory),
              ],
            ),
          ),
        ),

        // Drag and Drop Overlay
        if (_isDragging)
          Container(
            color: Colors.black.withValues(alpha: 0.75),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.file_download_outlined, size: 48, color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Drop book files here to import',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Supports EPUB, PDF, MOBI, CBZ, and TXT',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            SnackBar(content: Text('Importing ${paths.length} dragged book(s)...')),
          );
          await libraryCtrl.importFiles(paths);
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Successfully imported ${paths.length} book(s)!'),
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
          // App Identity Header (Logo Icon + Title + Subtitle)
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 1.5, color: AppColors.primary),
                          const SizedBox(height: 2),
                          Container(width: 10, height: 1.5, color: AppColors.primary),
                          const SizedBox(height: 2),
                          Container(width: 6, height: 1.5, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FolioHaven',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Desktop & Mobile Reader',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary Add Books Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickAndImportBooks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Books...',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories List
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: ListView(
                children: [
                  for (final cat in libraryCtrl.categories)
                    _buildNavItem(cat, _getIconForCategory(cat), libraryCtrl),

                  const SizedBox(height: 8),
                  // + Add Category Button
                  InkWell(
                    onTap: _onAddCategory,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF44403C)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Text(
                            'Add Category',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom tip
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Tip: Drag & drop book files to import instantly.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String title) {
    switch (title) {
      case 'All Books':
        return Icons.menu_book;
      case 'Favorites':
        return Icons.star_border;
      case 'Recent':
        return Icons.access_time;
      default:
        return Icons.folder_outlined;
    }
  }

  Widget _buildNavItem(String title, IconData icon, LibraryController libraryCtrl) {
    final isSelected = libraryCtrl.selectedCategory == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        selected: isSelected,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primary,
        selectedColor: Colors.white,
        textColor: const Color(0xFFD6D3D1),
        iconColor: isSelected ? Colors.white : const Color(0xFFD6D3D1),
        leading: Icon(icon, size: 16),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          libraryCtrl.setSelectedCategory(title);
        },
      ),
    );
  }

  Widget _buildTopBar(LibraryController libraryCtrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF292524), width: 1)),
      ),
      child: Row(
        children: [
          // Search Field
          SizedBox(
            width: 320,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                libraryCtrl.setSearchQuery(val);
              },
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search books by title, author...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          libraryCtrl.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const Spacer(),

          // View Mode Switcher: Grid vs Table
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.grid_view, size: 16),
                  color: libraryCtrl.isGridView ? Colors.white : AppColors.textSecondary,
                  style: IconButton.styleFrom(
                    backgroundColor: libraryCtrl.isGridView ? AppColors.primary : Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
                    ),
                  ),
                  tooltip: 'Grid View',
                  onPressed: () => libraryCtrl.setGridView(true),
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted, size: 16),
                  color: !libraryCtrl.isGridView ? Colors.white : AppColors.textSecondary,
                  style: IconButton.styleFrom(
                    backgroundColor: !libraryCtrl.isGridView ? AppColors.primary : Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                    ),
                  ),
                  tooltip: 'Table View',
                  onPressed: () => libraryCtrl.setGridView(false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Import Button shortcut
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, size: 18, color: AppColors.textSecondary),
            tooltip: 'Import Book File',
            onPressed: _pickAndImportBooks,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 170,
          childAspectRatio: 140 / 220,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onSecondaryTap: () => _showBookContextMenu(context, book),
            onLongPress: () => _showBookContextMenu(context, book),
            child: Column(
              children: [
                Expanded(
                  child: ArchivalBookCover(
                    book: book,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(book: book),
                        ),
                      ).then((_) {
                        // Refresh book progress when returning from reader
                        ref.read(libraryControllerProvider).loadBooks();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableView(List<Book> books) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: books.length,
      separatorBuilder: (context, index) => const Divider(color: Color(0xFF292524), height: 1),
      itemBuilder: (context, index) {
        final b = books[index];
        return ListTile(
          dense: true,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              b.format,
              style: const TextStyle(color: AppColors.primaryHover, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(b.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text(b.author, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${b.progressPercent.toInt()}%',
                style: const TextStyle(color: AppColors.primaryHover, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  b.isFavorite ? Icons.star : Icons.star_border,
                  size: 16,
                  color: b.isFavorite ? AppColors.primary : AppColors.textMuted,
                ),
                onPressed: () {
                  ref.read(libraryControllerProvider).toggleFavorite(b.id, b.isFavorite);
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 16, color: AppColors.textMuted),
                onPressed: () => _showBookContextMenu(context, b),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReaderScreen(book: b)),
            ).then((_) {
              ref.read(libraryControllerProvider).loadBooks();
            });
          },
        );
      },
    );
  }

  Widget _buildBottomStatusBar(int count, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(top: BorderSide(color: Color(0xFF292524), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count book(s) in collection • Category: $category',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
