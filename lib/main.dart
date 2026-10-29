import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryHover,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
          outline: AppColors.border,
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        dividerTheme: const DividerThemeData(
          color: AppColors.borderSubtle,
          thickness: 1,
          space: 1,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.sidebarBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          waitDuration: const Duration(milliseconds: 400),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.borderHover;
            }
            return AppColors.border;
          }),
          radius: const Radius.circular(4),
          thickness: WidgetStateProperty.all(6),
        ),
      ),
      home: const LibraryScreen(),
    );
  }
}
