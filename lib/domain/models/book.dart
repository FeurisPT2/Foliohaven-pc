class Book {
  final int id;
  final String title;
  final String author;
  final String format;
  final String filePath;
  final int fileSize;
  final int currentPage;
  final int totalPages;
  final double progressPercent;
  final bool isFavorite;
  final String category;
  final String coverPath;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.format,
    required this.filePath,
    this.fileSize = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.progressPercent = 0.0,
    this.isFavorite = false,
    this.category = 'All Books',
    this.coverPath = '',
    required this.createdAt,
  });

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? format,
    String? filePath,
    int? fileSize,
    int? currentPage,
    int? totalPages,
    double? progressPercent,
    bool? isFavorite,
    String? category,
    String? coverPath,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progressPercent: progressPercent ?? this.progressPercent,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      coverPath: coverPath ?? this.coverPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'format': format,
      'file_path': filePath,
      'file_size': fileSize,
      'current_page': currentPage,
      'total_pages': totalPages,
      'progress_percent': progressPercent,
      'is_favorite': isFavorite ? 1 : 0,
      'category': category,
      'cover_path': coverPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? 'Untitled',
      author: map['author'] as String? ?? 'Unknown Author',
      format: map['format'] as String? ?? 'EPUB',
      filePath: map['file_path'] as String? ?? '',
      fileSize: map['file_size'] as int? ?? 0,
      currentPage: map['current_page'] as int? ?? 1,
      totalPages: map['total_pages'] as int? ?? 1,
      progressPercent: (map['progress_percent'] as num?)?.toDouble() ?? 0.0,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      category: map['category'] as String? ?? 'All Books',
      coverPath: map['cover_path'] as String? ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
