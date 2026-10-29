import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foliohaven_flutter/data/datasources/database_service.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';
import 'package:foliohaven_flutter/ui/features/library/views/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SQLite database
  await DatabaseService.instance.database;
  runApp(
    const ProviderScope(
      child: FolioHavenApp(),
    ),
  );
}

class FolioHavenApp extends StatelessWidget {
  const FolioHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FolioHaven — Distraction-Free Ebook Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryHover,
          surface: AppColors.surface,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const LibraryScreen(),
    );
  }
}
