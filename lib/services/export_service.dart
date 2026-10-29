import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:foliohaven_flutter/domain/models/book.dart';
import 'package:foliohaven_flutter/domain/models/bookmark.dart';
import 'package:foliohaven_flutter/domain/models/annotation.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  Future<String> exportNotesToHtml({
    required Book book,
    required List<Bookmark> bookmarks,
    required List<Annotation> annotations,
  }) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(appDocDir.path, 'FolioHaven', 'exports'));
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final safeTitle = book.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filePath = p.join(exportsDir.path, '${safeTitle}_FolioHaven_Notes.html');

    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('  <title>${book.title} - Notes & Bookmarks</title>');
    buffer.writeln('  <style>');
    buffer.writeln('    body { font-family: "Georgia", serif; background-color: #FBF0D9; color: #382C1E; margin: 0; padding: 40px 20px; line-height: 1.6; }');
    buffer.writeln('    .container { max-width: 760px; margin: 0 auto; background: #FFFDF9; border: 1px solid #E3D3BA; border-radius: 8px; padding: 40px; box-shadow: 0 4px 12px rgba(0,0,0,0.06); }');
    buffer.writeln('    .header { border-bottom: 2px solid #C2410C; padding-bottom: 20px; margin-bottom: 30px; }');
    buffer.writeln('    h1 { color: #C2410C; font-size: 28px; margin: 0 0 8px 0; }');
    buffer.writeln('    .meta { color: #78716C; font-size: 14px; font-family: sans-serif; }');
    buffer.writeln('    h2 { font-size: 20px; border-bottom: 1px solid #E3D3BA; padding-bottom: 8px; margin-top: 32px; color: #1C1917; }');
    buffer.writeln('    .item-card { background: #FAF5EC; border-left: 4px solid #C2410C; padding: 12px 16px; margin-bottom: 16px; border-radius: 0 6px 6px 0; }');
    buffer.writeln('    .item-card.amber { border-left-color: #F59E0B; }');
    buffer.writeln('    .item-card.emerald { border-left-color: #10B981; }');
    buffer.writeln('    .item-card.azure { border-left-color: #3B82F6; }');
    buffer.writeln('    .item-card.rose { border-left-color: #F43F5E; }');
    buffer.writeln('    .quote { font-style: italic; color: #292524; font-size: 16px; margin-bottom: 6px; }');
    buffer.writeln('    .note { color: #57534E; font-size: 14px; margin-bottom: 4px; font-family: sans-serif; }');
    buffer.writeln('    .tag { font-size: 12px; color: #A8A29E; font-family: sans-serif; }');
    buffer.writeln('    .footer { text-align: center; margin-top: 40px; font-size: 13px; color: #A8A29E; font-family: sans-serif; }');
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <div class="container">');
    buffer.writeln('    <div class="header">');
    buffer.writeln('      <h1>${book.title}</h1>');
    buffer.writeln('      <div class="meta">By <strong>${book.author}</strong> | Format: ${book.format} | Exported via FolioHaven on ${DateTime.now().toLocal().toString().split('.')[0]}</div>');
    buffer.writeln('    </div>');

    // Bookmarks Section
    buffer.writeln('    <h2>Bookmarks (${bookmarks.length})</h2>');
    if (bookmarks.isEmpty) {
      buffer.writeln('    <p class="meta">No bookmarks recorded.</p>');
    } else {
      for (final bm in bookmarks) {
        buffer.writeln('    <div class="item-card">');
        buffer.writeln('      <div class="quote">${bm.title}</div>');
        buffer.writeln('      <div class="tag">Page ${bm.page} &bull; ${bm.createdAt.toLocal().toString().split(' ')[0]}</div>');
        buffer.writeln('    </div>');
      }
    }

    // Highlights & Annotations Section
    buffer.writeln('    <h2>Highlights & Annotations (${annotations.length})</h2>');
    if (annotations.isEmpty) {
      buffer.writeln('    <p class="meta">No highlights recorded.</p>');
    } else {
      for (final ann in annotations) {
        buffer.writeln('    <div class="item-card ${ann.color}">');
        buffer.writeln('      <div class="quote">&ldquo;${ann.text}&rdquo;</div>');
        if (ann.note.trim().isNotEmpty) {
          buffer.writeln('      <div class="note"><strong>Note:</strong> ${ann.note}</div>');
        }
        buffer.writeln('      <div class="tag">Page ${ann.page} &bull; Highlight: ${ann.color.toUpperCase()} &bull; ${ann.createdAt.toLocal().toString().split(' ')[0]}</div>');
        buffer.writeln('    </div>');
      }
    }

    buffer.writeln('    <div class="footer">');
    buffer.writeln('      Generated with ❤️ by <strong>FolioHaven</strong> &mdash; Archival Desktop & Mobile Ebook Reader');
    buffer.writeln('    </div>');
    buffer.writeln('  </div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  Future<void> openExportedFile(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
