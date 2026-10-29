import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:foliohaven_flutter/domain/models/book.dart';
import 'package:foliohaven_flutter/domain/models/bookmark.dart';
import 'package:foliohaven_flutter/domain/models/annotation.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final dbDirectory = Directory(p.join(appDocDir.path, 'FolioHaven'));
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }

    final dbPath = p.join(dbDirectory.path, 'foliohaven.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        format TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER DEFAULT 0,
        current_page INTEGER DEFAULT 1,
        total_pages INTEGER DEFAULT 1,
        progress_percent REAL DEFAULT 0.0,
        is_favorite INTEGER DEFAULT 0,
        category TEXT DEFAULT 'All Books',
        cover_path TEXT DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        page INTEGER NOT NULL,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE annotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        note TEXT DEFAULT '',
        color TEXT DEFAULT 'amber',
        page INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Default categories
    final defaultCategories = [
      'Classic Literature',
      'Sci-Fi & Fantasy',
      'Philosophy',
      'History',
      'Art & Design',
    ];
    for (final cat in defaultCategories) {
      await db.insert('categories', {'name': cat});
    }

    // Default sample books
    final now = DateTime.now();
    final sampleBooks = [
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'format': 'EPUB',
        'file_path': 'sample://pride_and_prejudice.epub',
        'file_size': 745820,
        'current_page': 42,
        'total_pages': 380,
        'progress_percent': 11.0,
        'is_favorite': 1,
        'category': 'Classic Literature',
        'cover_path': '',
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'title': 'Frankenstein; or, The Modern Prometheus',
        'author': 'Mary Shelley',
        'format': 'EPUB',
        'file_path': 'sample://frankenstein.epub',
        'file_size': 512300,
        'current_page': 85,
        'total_pages': 280,
        'progress_percent': 30.0,
        'is_favorite': 1,
        'category': 'Sci-Fi & Fantasy',
        'cover_path': '',
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'title': 'The Republic',
        'author': 'Plato',
        'format': 'PDF',
        'file_path': 'sample://the_republic.pdf',
        'file_size': 1245000,
        'current_page': 1,
        'total_pages': 416,
        'progress_percent': 0.0,
        'is_favorite': 0,
        'category': 'Philosophy',
        'cover_path': '',
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'title': 'Meditations',
        'author': 'Marcus Aurelius',
        'format': 'MOBI',
        'file_path': 'sample://meditations.mobi',
        'file_size': 410000,
        'current_page': 195,
        'total_pages': 200,
        'progress_percent': 98.0,
        'is_favorite': 1,
        'category': 'Philosophy',
        'cover_path': '',
        'created_at': now.subtract(const Duration(days: 12)).toIso8601String(),
      },
    ];

    for (final book in sampleBooks) {
      await db.insert('books', book);
    }
  }

  // --- Books CRUD ---

  Future<List<Book>> getBooks({String? category, String? search}) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (category != null && category != 'All Books') {
      if (category == 'Favorites') {
        whereClause = 'is_favorite = 1';
      } else if (category == 'Recent') {
        // Just order by created_at desc
      } else {
        whereClause = 'category = ?';
        whereArgs = [category];
      }
    }

    if (search != null && search.trim().isNotEmpty) {
      final searchPattern = '%${search.trim()}%';
      if (whereClause != null) {
        whereClause += ' AND (title LIKE ? OR author LIKE ?)';
        whereArgs = [...whereArgs!, searchPattern, searchPattern];
      } else {
        whereClause = 'title LIKE ? OR author LIKE ?';
        whereArgs = [searchPattern, searchPattern];
      }
    }

    final maps = await db.query(
      'books',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: category == 'Recent' ? 'id DESC' : 'created_at DESC',
    );

    return maps.map((map) => Book.fromMap(map)).toList();
  }

  Future<Book?> getBookById(int id) async {
    final db = await database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    final map = book.toMap();
    map.remove('id'); // Auto-increment
    return await db.insert('books', map);
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    // Foreign keys delete bookmarks & annotations if CASCADE enabled, or manually:
    await db.delete('bookmarks', where: 'book_id = ?', whereArgs: [id]);
    await db.delete('annotations', where: 'book_id = ?', whereArgs: [id]);
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'books',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProgress(int id, int currentPage, int totalPages, double progressPercent) async {
    final db = await database;
    await db.update(
      'books',
      {
        'current_page': currentPage,
        'total_pages': totalPages,
        'progress_percent': progressPercent,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Bookmarks CRUD ---

  Future<List<Bookmark>> getBookmarks(int bookId) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'page ASC',
    );
    return maps.map((map) => Bookmark.fromMap(map)).toList();
  }

  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    final map = bookmark.toMap();
    map.remove('id');
    return await db.insert('bookmarks', map);
  }

  Future<int> deleteBookmark(int id) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // --- Annotations CRUD ---

  Future<List<Annotation>> getAnnotations(int bookId) async {
    final db = await database;
    final maps = await db.query(
      'annotations',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Annotation.fromMap(map)).toList();
  }

  Future<int> insertAnnotation(Annotation annotation) async {
    final db = await database;
    final map = annotation.toMap();
    map.remove('id');
    return await db.insert('annotations', map);
  }

  Future<int> deleteAnnotation(int id) async {
    final db = await database;
    return await db.delete('annotations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Categories CRUD ---

  Future<List<String>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> insertCategory(String name) async {
    final db = await database;
    await db.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCategory(String name) async {
    final db = await database;
    await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }
}
