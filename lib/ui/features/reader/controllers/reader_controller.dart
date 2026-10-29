import 'package:flutter_riverpod/legacy.dart';
import 'package:foliohaven_flutter/data/repositories/book_repository.dart';
import 'package:foliohaven_flutter/domain/models/book.dart';
import 'package:foliohaven_flutter/domain/models/bookmark.dart';
import 'package:foliohaven_flutter/domain/models/annotation.dart';
import 'package:foliohaven_flutter/services/tts_service.dart';
import 'package:foliohaven_flutter/services/export_service.dart';
import 'package:foliohaven_flutter/ui/features/library/controllers/library_controller.dart';

class ReaderState {
  final Book book;
  final int currentPage;
  final int totalPages;
  final int activeThemeIndex; // 0: Day, 1: Sepia, 2: Night, 3: Dark Sepia
  final bool isTwoPage;
  final double fontSize;
  final List<Bookmark> bookmarks;
  final List<Annotation> annotations;
  final bool isPlayingTts;

  const ReaderState({
    required this.book,
    required this.currentPage,
    required this.totalPages,
    this.activeThemeIndex = 0,
    this.isTwoPage = false,
    this.fontSize = 18.0,
    this.bookmarks = const [],
    this.annotations = const [],
    this.isPlayingTts = false,
  });

  ReaderState copyWith({
    Book? book,
    int? currentPage,
    int? totalPages,
    int? activeThemeIndex,
    bool? isTwoPage,
    double? fontSize,
    List<Bookmark>? bookmarks,
    List<Annotation>? annotations,
    bool? isPlayingTts,
  }) {
    return ReaderState(
      book: book ?? this.book,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      activeThemeIndex: activeThemeIndex ?? this.activeThemeIndex,
      isTwoPage: isTwoPage ?? this.isTwoPage,
      fontSize: fontSize ?? this.fontSize,
      bookmarks: bookmarks ?? this.bookmarks,
      annotations: annotations ?? this.annotations,
      isPlayingTts: isPlayingTts ?? this.isPlayingTts,
    );
  }
}

class ReaderNotifier extends StateNotifier<ReaderState> {
  final BookRepository _repo;
  final TtsService _tts = TtsService.instance;
  final ExportService _export = ExportService.instance;

  ReaderNotifier(this._repo, Book initialBook)
      : super(ReaderState(
          book: initialBook,
          currentPage: initialBook.currentPage,
          totalPages: initialBook.totalPages > 0 ? initialBook.totalPages : 1,
        )) {
    _init();
  }

  Future<void> _init() async {
    await _tts.init();
    _tts.onStateChanged = () {
      if (mounted) {
        state = state.copyWith(isPlayingTts: _tts.isPlaying);
      }
    };
    await loadBookmarksAndAnnotations();
  }

  Future<void> loadBookmarksAndAnnotations() async {
    final bookmarks = await _repo.getBookmarks(state.book.id);
    final annotations = await _repo.getAnnotations(state.book.id);
    if (mounted) {
      state = state.copyWith(bookmarks: bookmarks, annotations: annotations);
    }
  }

  Future<void> setPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final progress = (page / state.totalPages * 100).clamp(0.0, 100.0);
    state = state.copyWith(currentPage: page);
    await _repo.updateProgress(state.book.id, page, state.totalPages, progress);
  }

  Future<void> nextPage() async {
    final step = state.isTwoPage ? 2 : 1;
    final next = (state.currentPage + step).clamp(1, state.totalPages);
    await setPage(next);
  }

  Future<void> previousPage() async {
    final step = state.isTwoPage ? 2 : 1;
    final prev = (state.currentPage - step).clamp(1, state.totalPages);
    await setPage(prev);
  }

  void setTheme(int themeIndex) {
    state = state.copyWith(activeThemeIndex: themeIndex);
  }

  void toggleSpread() {
    state = state.copyWith(isTwoPage: !state.isTwoPage);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(12.0, 36.0));
  }

  Future<void> addBookmark() async {
    final newBookmark = Bookmark(
      id: 0,
      bookId: state.book.id,
      page: state.currentPage,
      title: 'Page ${state.currentPage} Bookmark',
      createdAt: DateTime.now(),
    );
    await _repo.addBookmark(newBookmark);
    await loadBookmarksAndAnnotations();
  }

  Future<void> deleteBookmark(int id) async {
    await _repo.deleteBookmark(id);
    await loadBookmarksAndAnnotations();
  }

  Future<void> addAnnotation(String text, String color, {String note = ''}) async {
    final newAnnotation = Annotation(
      id: 0,
      bookId: state.book.id,
      text: text,
      note: note,
      color: color,
      page: state.currentPage,
      createdAt: DateTime.now(),
    );
    await _repo.addAnnotation(newAnnotation);
    await loadBookmarksAndAnnotations();
  }

  Future<void> deleteAnnotation(int id) async {
    await _repo.deleteAnnotation(id);
    await loadBookmarksAndAnnotations();
  }

  Future<void> toggleTts(String textToSpeak) async {
    if (state.isPlayingTts) {
      await _tts.stop();
    } else {
      await _tts.speak(textToSpeak);
    }
  }

  Future<String> exportNotes() async {
    final filePath = await _export.exportNotesToHtml(
      book: state.book,
      bookmarks: state.bookmarks,
      annotations: state.annotations,
    );
    await _export.openExportedFile(filePath);
    return filePath;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

final readerProvider = StateNotifierProvider.family<ReaderNotifier, ReaderState, Book>((ref, book) {
  final repo = ref.watch(bookRepositoryProvider);
  return ReaderNotifier(repo, book);
});
