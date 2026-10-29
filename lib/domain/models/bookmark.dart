class Bookmark {
  final int id;
  final int bookId;
  final int page;
  final String title;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.page,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'page': page,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int? ?? 0,
      bookId: map['book_id'] as int? ?? 0,
      page: map['page'] as int? ?? 1,
      title: map['title'] as String? ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
