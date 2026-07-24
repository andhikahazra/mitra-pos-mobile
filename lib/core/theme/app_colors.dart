import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Theme - Indigo System Tokens
  static const Color indigoPrimary = Color(0xFF000B60);
  static const Color indigoPrimaryContainer = Color(0xFF142283);
  static const Color indigoPrimaryFixed = Color(0xFFDFE0FF);
  static const Color indigoSurfaceTint = Color(0xFF4955B3);

  // Light Theme - Primary Colors (aliases for compatibility)
  static const Color primary = indigoPrimary;
  static const Color primaryLight = indigoPrimaryContainer;
  static const Color primaryDark = Color(0xFF000743);

  // Light Theme - Accent Colors
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFFA29BFE);

  // Light Theme - Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color successLight = Color(0xFFE8F8F5);
  static const Color warning = Color(0xFFFDAC3B);
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFFE5E5);
  static const Color info = Color(0xFF74B9FF);
  static const Color infoLight = Color(0xFFE8F4FF);

  // Light Theme - Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFDFDFE);
  static const Color surface = Color(0xFFFDFDFE);
  static const Color surfaceVariant = Color(0xFFF1F4F9);

  // Light Theme - Surface Hierarchy
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F7FB);
  static const Color surfaceContainer = Color(0xFFF0F3F8);
  static const Color surfaceContainerHigh = Color(0xFFEBEFF5);
  static const Color surfaceContainerHighest = Color(0xFFE5EAF2);

  // Light Theme - Semantic Token
  static const Color primaryFixed = indigoPrimaryFixed;

  // Light Theme - Text Colors
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF454652);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textDisabled = Color(0xFFDFE6E9);

  // Light Theme - Border & Divider
  static const Color border = Color(0xFFC8CEDA);
  static const Color borderLight = Color(0xFFF0F3F8);
  static const Color divider = Color(0xFFEAECF0);

  // Light Theme - Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Light Theme - Gradients
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

  // ============ DARK THEME ============

  // Dark Theme - Background & Surface (AMOLED Black)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF0D0D0D);
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A);
  static const Color darkSurfaceContainerLowest = Color(0xFF000000);
  static const Color darkSurfaceContainerLow = Color(0xFF141414);
  static const Color darkSurfaceContainer = Color(0xFF1A1A1A);
  static const Color darkSurfaceContainerHigh = Color(0xFF242424);
  static const Color darkSurfaceContainerHighest = Color(0xFF2E2E2E);

  // Dark Theme - Text Colors (Material3 Dark)
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF888888);
  static const Color darkTextDisabled = Color(0xFF666666);

  // Dark Theme - Border & Divider
  static const Color darkBorder = Color(0xFF272727);
  static const Color darkBorderLight = Color(0xFF1A1A1A);
  static const Color darkDivider = Color(0xFF1A1A1A);

  // Dark Theme - Indigo
  static const Color darkIndigoPrimary = Color(0xFF818CF8);
  static const Color darkIndigoPrimaryContainer = Color(0xFF4F46E5);
  static const Color darkIndigoPrimaryFixed = Color(0xFF1E1E2E);
  static const Color darkIndigoSurfaceTint = Color(0xFFA5B4FC);

  static const Color darkPrimary = darkIndigoPrimary;
  static const Color darkPrimaryLight = darkIndigoPrimaryContainer;
  static const Color darkPrimaryDark = Color(0xFF8F97FF);

  // Dark Theme - Accent
  static const Color darkAccent = Color(0xFFA3A9F5);
  static const Color darkAccentLight = Color(0xFF4A4A6A);

  // Dark Theme - Status
  static const Color darkSuccess = Color(0xFF00D68B);
  static const Color darkSuccessLight = Color(0xFF04381F);
  static const Color darkWarning = Color(0xFFFFB62A);
  static const Color darkWarningLight = Color(0xFF5E3600);
  static const Color darkError = Color(0xFFFF7373);
  static const Color darkErrorLight = Color(0xFF5A1515);
  static const Color darkInfo = Color(0xFF5FB4F6);
  static const Color darkInfoLight = Color(0xFF164D73);

  // Dark Theme - Shadow
  static const Color darkShadow = Color(0x1A000000);
  static const Color darkShadowLight = Color(0x0D000000);

  // Dark Theme - Gradients
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [darkIndigoPrimary, darkIndigoPrimaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkIndigoActionGradient = LinearGradient(
    colors: [darkIndigoPrimary, darkIndigoPrimaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.05, 0.95],
  );

  static const LinearGradient darkSuccessGradient = LinearGradient(
    colors: [Color(0xFF00D68B), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? AppColors.darkBackground : AppColors.background;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surfaceVariant => isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
  Color get surfaceContainerLowest => isDark ? AppColors.darkSurfaceContainerLowest : AppColors.surfaceContainerLowest;
  Color get surfaceContainerLow => isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow;
  Color get surfaceContainer => isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainer;
  Color get surfaceContainerHigh => isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh;
  Color get surfaceContainerHighest => isDark ? AppColors.darkSurfaceContainerHighest : AppColors.surfaceContainerHighest;

  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textTertiary => isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
  Color get textDisabled => isDark ? AppColors.darkTextDisabled : AppColors.textDisabled;

  Color get border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get borderLight => isDark ? AppColors.darkBorderLight : AppColors.borderLight;
  Color get divider => isDark ? AppColors.darkDivider : AppColors.divider;

  Color get indigoPrimary => isDark ? AppColors.darkIndigoPrimary : AppColors.indigoPrimary;
  Color get indigoPrimaryContainer => isDark ? AppColors.darkIndigoPrimaryContainer : AppColors.indigoPrimaryContainer;
  Color get indigoSurfaceTint => isDark ? AppColors.darkIndigoSurfaceTint : AppColors.indigoSurfaceTint;
  Color get indigoPrimaryFixed => isDark ? AppColors.darkIndigoPrimaryFixed : AppColors.indigoPrimaryFixed;

  Color get primaryFixed => indigoPrimaryFixed;

  Color get success => isDark ? AppColors.darkSuccess : AppColors.success;
  Color get successLight => isDark ? AppColors.darkSuccessLight : AppColors.successLight;
  Color get warning => isDark ? AppColors.darkWarning : AppColors.warning;
  Color get warningLight => isDark ? AppColors.darkWarningLight : AppColors.warningLight;
  Color get error => isDark ? AppColors.darkError : AppColors.error;
  Color get errorLight => isDark ? AppColors.darkErrorLight : AppColors.errorLight;

  Color get shadow => isDark ? AppColors.darkShadow : AppColors.shadow;
  Color get shadowLight => isDark ? AppColors.darkShadowLight : AppColors.shadowLight;

  LinearGradient get primaryGradient => isDark ? AppColors.darkPrimaryGradient : AppColors.primaryGradient;
  LinearGradient get indigoActionGradient => isDark ? AppColors.darkIndigoActionGradient : AppColors.indigoActionGradient;
}
