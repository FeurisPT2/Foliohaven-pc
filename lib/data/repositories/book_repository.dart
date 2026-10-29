import 'package:foliohaven_flutter/data/datasources/database_service.dart';
import 'package:foliohaven_flutter/domain/models/book.dart';
import 'package:foliohaven_flutter/domain/models/bookmark.dart';
import 'package:foliohaven_flutter/domain/models/annotation.dart';
import 'package:foliohaven_flutter/services/document_parser_service.dart';

class BookRepository {
  final DatabaseService _dbService;
  final DocumentParserService _parserService;

  BookRepository({
    DatabaseService? dbService,
    DocumentParserService? parserService,
  })  : _dbService = dbService ?? DatabaseService.instance,
        _parserService = parserService ?? DocumentParserService.instance;

  Future<List<Book>> getBooks({String? category, String? search}) =>
      _dbService.getBooks(category: category, search: search);

  Future<Book?> getBook(int id) => _dbService.getBookById(id);

  Future<Book> importBook(String sourcePath, {String category = 'All Books'}) async {
    final book = await _parserService.importBook(sourcePath, category: category);
    final id = await _dbService.insertBook(book);
    return book.copyWith(id: id);
  }

  Future<int> updateBook(Book book) => _dbService.updateBook(book);

  Future<int> deleteBook(int id) => _dbService.deleteBook(id);

  Future<void> toggleFavorite(int id, bool isFavorite) =>
      _dbService.toggleFavorite(id, isFavorite);

  Future<void> updateProgress(int id, int page, int totalPages, double percent) =>
      _dbService.updateProgress(id, page, totalPages, percent);

  // Bookmarks
  Future<List<Bookmark>> getBookmarks(int bookId) => _dbService.getBookmarks(bookId);

  Future<int> addBookmark(Bookmark bookmark) => _dbService.insertBookmark(bookmark);

  Future<int> deleteBookmark(int id) => _dbService.deleteBookmark(id);

  // Annotations
  Future<List<Annotation>> getAnnotations(int bookId) => _dbService.getAnnotations(bookId);

  Future<int> addAnnotation(Annotation annotation) => _dbService.insertAnnotation(annotation);

  Future<int> deleteAnnotation(int id) => _dbService.deleteAnnotation(id);

  // Categories
  Future<List<String>> getCategories() => _dbService.getCategories();

  Future<void> addCategory(String name) => _dbService.insertCategory(name);

  Future<void> deleteCategory(String name) => _dbService.deleteCategory(name);
}
