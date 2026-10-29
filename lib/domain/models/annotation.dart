class Annotation {
  final int id;
  final int bookId;
  final String text;
  final String note;
  final String color; // amber, emerald, azure, rose
  final int page;
  final DateTime createdAt;

  const Annotation({
    required this.id,
    required this.bookId,
    required this.text,
    this.note = '',
    this.color = 'amber',
    this.page = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'text': text,
      'note': note,
      'color': color,
      'page': page,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Annotation.fromMap(Map<String, dynamic> map) {
    return Annotation(
      id: map['id'] as int? ?? 0,
      bookId: map['book_id'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      note: map['note'] as String? ?? '',
      color: map['color'] as String? ?? 'amber',
      page: map['page'] as int? ?? 1,
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
