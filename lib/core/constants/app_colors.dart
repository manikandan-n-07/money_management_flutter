// lib/core/constants/app_colors.dart
// Premium color palette for PennyWise

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === Brand Colors ===
  static const Color primary = Color(0xFF6C63FF);      // Electric Violet
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);

  static const Color secondary = Color(0xFF00D4AA);    // Emerald Teal
  static const Color secondaryLight = Color(0xFF4DFFDA);
  static const Color secondaryDark = Color(0xFF00A882);

  static const Color accent = Color(0xFFFF6B6B);       // Coral Red
  static const Color accentOrange = Color(0xFFFF9F43); // Warm Orange
  static const Color accentBlue = Color(0xFF54A0FF);   // Sky Blue

  // === Dark Theme ===
  static const Color darkBackground = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkCardBorder = Color(0xFF2A2A4A);
  static const Color darkDivider = Color(0xFF252540);

  static const Color darkText = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFF9999BB);
  static const Color darkTextMuted = Color(0xFF666688);

  // === Light Theme ===
  static const Color lightBackground = Color(0xFFF8F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE8E8F5);
  static const Color lightDivider = Color(0xFFEEEEF8);

  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF555570);
  static const Color lightTextMuted = Color(0xFF9999BB);

  // === Category Colors ===
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTravel = Color(0xFF54A0FF);
  static const Color catFuel = Color(0xFFFF9F43);
  static const Color catShopping = Color(0xFFFF78C4);
  static const Color catEntertainment = Color(0xFFA29BFE);
  static const Color catEducation = Color(0xFF00D4AA);
  static const Color catMedical = Color(0xFFFF4757);
  static const Color catBills = Color(0xFF5352ED);
  static const Color catSubscription = Color(0xFF2ED573);
  static const Color catFestival = Color(0xFFFFD32A);
  static const Color catGifts = Color(0xFFECCC68);
  static const Color catInvestment = Color(0xFF26de81);
  static const Color catPersonal = Color(0xFF45AAF2);
  static const Color catOthers = Color(0xFF95ABBE);

  // === Status Colors ===
  static const Color success = Color(0xFF2ED573);
  static const Color warning = Color(0xFFFFD32A);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF54A0FF);

  // === Budget States ===
  static const Color budgetSafe = Color(0xFF2ED573);       // < 60%
  static const Color budgetWarning = Color(0xFFFF9F43);    // 60-85%
  static const Color budgetDanger = Color(0xFFFF4757);     // > 85%

  // === Chart Colors ===
  static const List<Color> chartPalette = [
    Color(0xFF6C63FF),
    Color(0xFF00D4AA),
    Color(0xFFFF6B6B),
    Color(0xFFFF9F43),
    Color(0xFF54A0FF),
    Color(0xFFFF78C4),
    Color(0xFFA29BFE),
    Color(0xFF2ED573),
    Color(0xFFFFD32A),
    Color(0xFF26de81),
    Color(0xFF45AAF2),
    Color(0xFF95ABBE),
    Color(0xFFECCC68),
    Color(0xFFFF4757),
  ];

  // === Glassmorphism ===
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // === Gradient Definitions ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E3A), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF26de81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
