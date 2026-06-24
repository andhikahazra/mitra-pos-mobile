import 'package:flutter/material.dart';

/// App color scheme for production-ready UI
class AppColors {
  AppColors._();

  // Indigo System Tokens
  static const Color indigoPrimary = Color(0xFF000B60);
  static const Color indigoPrimaryContainer = Color(0xFF142283);
  static const Color indigoPrimaryFixed = Color(0xFFDFE0FF);
  static const Color indigoSurfaceTint = Color(0xFF4955B3);

  // Primary Colors (aliases for compatibility)
  static const Color primary = indigoPrimary;
  static const Color primaryLight = indigoPrimaryContainer;
  static const Color primaryDark = Color(0xFF000743);
  
  // Accent Colors
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFFA29BFE);
  
  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color successLight = Color(0xFFE8F8F5);
  static const Color warning = Color(0xFFFDAC3B);
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFFE5E5);
  static const Color info = Color(0xFF74B9FF);
  static const Color infoLight = Color(0xFFE8F4FF);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFDFDFE);
  static const Color surface = Color(0xFFFDFDFE);
  static const Color surfaceVariant = Color(0xFFF1F4F9);

  // Surface Hierarchy
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F7FB);
  static const Color surfaceContainer = Color(0xFFF0F3F8);
  static const Color surfaceContainerHigh = Color(0xFFEBEFF5);
  static const Color surfaceContainerHighest = Color(0xFFE5EAF2);

  // Reusable semantic token
  static const Color primaryFixed = indigoPrimaryFixed;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF454652);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textDisabled = Color(0xFFDFE6E9);
  
  // Border Colors
  static const Color border = Color(0xFFC8CEDA);
  static const Color borderLight = Color(0xFFF0F3F8);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [indigoPrimary, indigoPrimaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoActionGradient = LinearGradient(
    colors: [indigoPrimary, indigoPrimaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.05, 0.95],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
