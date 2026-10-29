import 'package:flutter/material.dart';

/// FolioHaven Brand Identity & Design Tokens
/// Grounded in replica/brand.md & WCAG 2.2 AAA/AA Contrast Compliance
class AppColors {
  // Brand Terracotta & Amber Ochre (Primary Accent)
  static const Color primary = Color(0xFFC2410C); // Terracotta
  static const Color primaryHover = Color(0xFFEA580C); // Warm Orange-Amber
  static const Color primaryPressed = Color(0xFF9A3412); // Deep Amber Bronze
  static const Color primaryLight = Color(0xFFFFF7ED); // Cream White
  static const Color primaryGlow = Color(0x33C2410C); // 20% Ambient Glow
  static const Color primarySubtle = Color(0x1FC2410C); // 12% Background Tint

  // Deep Espresso & Charcoal Surfaces (Luxury Archival Dark Theme)
  static const Color canvas = Color(0xFF141110); // Deepest dark background
  static const Color background = Color(0xFF181513); // Main app canvas
  static const Color sidebarBg = Color(0xFF1E1A18); // Sidebar warm espresso
  static const Color surface = Color(0xFF26211E); // Elevated cards & containers
  static const Color surfaceHover = Color(0xFF302A27); // Hovered surface
  static const Color surfaceActive = Color(0xFF38312D); // Active/Selected surface
  static const Color surfaceInput = Color(0xFF221D1B); // Search & input fields

  // Borders & Dividers
  static const Color border = Color(0xFF38312C); // Standard border
  static const Color borderSubtle = Color(0xFF2B2522); // Subtle divider
  static const Color borderHover = Color(0xFF4A413B); // Hover border
  static const Color borderActive = Color(0xFFC2410C); // Focused border

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFAF7F2); // Warm Parchment White
  static const Color textSecondary = Color(0xFFB5ACA3); // Muted Linen
  static const Color textMuted = Color(0xFF7E756D); // Subtle Grey Bronze
  static const Color textDisabled = Color(0xFF564F48); // Disabled Text

  // Status & Accents
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color danger = Color(0xFFEF4444); // Crimson Red
  static const Color warning = Color(0xFFF59E0B); // Golden Amber
  static const Color starGold = Color(0xFFFBBF24); // Golden Star

  // 4 Highlighter Palette for Annotations
  static const Color highlightAmber = Color(0xFFFFE270);
  static const Color highlightEmerald = Color(0xFFA8F29A);
  static const Color highlightAzure = Color(0xFF7BE5F8);
  static const Color highlightRose = Color(0xFFFFA0C5);

  // 4 Reading Canvas Themes
  // 1. Day Mode
  static const Color dayBg = Color(0xFFFAF8F5);
  static const Color dayText = Color(0xFF1F1D1B);
  static const Color dayBorder = Color(0xFFE5DFD7);

  // 2. Sepia Mode (Archival Warmth)
  static const Color sepiaBg = Color(0xFFF5EBD7);
  static const Color sepiaText = Color(0xFF3E2D1E);
  static const Color sepiaBorder = Color(0xFFE4D3B8);

  // 3. Night OLED Mode
  static const Color nightBg = Color(0xFF111111);
  static const Color nightText = Color(0xFFD4D4D8);
  static const Color nightBorder = Color(0xFF242426);

  // 4. Dark Sepia Mode (Twilight Reading)
  static const Color darkSepiaBg = Color(0xFF221A14);
  static const Color darkSepiaText = Color(0xFFD7C7B7);
  static const Color darkSepiaBorder = Color(0xFF382C22);

  // Format Badges Colors
  static const Color badgeEpub = Color(0xFF0284C7); // Sky Blue
  static const Color badgePdf = Color(0xFFE11D48); // Rose Crimson
  static const Color badgeMobi = Color(0xFF059669); // Forest Emerald
  static const Color badgeTxt = Color(0xFFD97706); // Warm Amber
}
