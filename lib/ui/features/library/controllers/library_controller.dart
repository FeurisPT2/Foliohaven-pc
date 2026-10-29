import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:foliohaven_flutter/data/repositories/book_repository.dart';
import 'package:foliohaven_flutter/domain/models/book.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

class LibraryController extends ChangeNotifier {
  final BookRepository _repo;
  List<Book> _books = [];
  List<String> _categories = ['All Books', 'Favorites', 'Recent'];
  String _selectedCategory = 'All Books';
  String _searchQuery = '';
  bool _isGridView = true;
  bool _isLoading = true;

  LibraryController(this._repo) {
    loadCategories();
    loadBooks();
  }

  List<Book> get books => _books;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  void setGridView(bool value) {
    _isGridView = value;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    loadBooks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadBooks();
  }

  Future<void> loadCategories() async {
    try {
      final dbCategories = await _repo.getCategories();
      _categories = ['All Books', 'Favorites', 'Recent', ...dbCategories.where((c) => c != 'All Books')];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _books = await _repo.getBooks(category: _selectedCategory, search: _searchQuery);
    } catch (_) {
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importFiles(List<String> filePaths) async {
    final cat = (_selectedCategory == 'All Books' || _selectedCategory == 'Favorites' || _selectedCategory == 'Recent')
        ? 'All Books'
        : _selectedCategory;

    for (final path in filePaths) {
      try {
        await _repo.importBook(path, category: cat);
      } catch (_) {}
    }
    await loadBooks();
  }

  Future<void> toggleFavorite(int bookId, bool currentFavorite) async {
    await _repo.toggleFavorite(bookId, !currentFavorite);
    await loadBooks();
  }

  Future<void> deleteBook(int bookId) async {
    await _repo.deleteBook(bookId);
    await loadBooks();
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    await _repo.addCategory(name.trim());
    await loadCategories();
  }
}

final libraryControllerProvider = ChangeNotifierProvider<LibraryController>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return LibraryController(repo);
});
