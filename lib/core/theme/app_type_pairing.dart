import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitrapos/core/theme/app_colors.dart';

/// Small helper for consistent Manrope + Inter pairing across screens.
class AppTypePairing {
  AppTypePairing._();

  static TextStyle headlineLg({Color? color, FontWeight? weight}) => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: weight ?? FontWeight.w700,
    letterSpacing: -0.35,
    height: 1.2,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle titleMd({Color? color, FontWeight? weight, double? fontSize}) => GoogleFonts.manrope(
    fontSize: fontSize ?? 16,
    fontWeight: weight ?? FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle bodyMd({Color? color, FontWeight? weight}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: weight ?? FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle bodySm({Color? color, FontWeight? weight}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: weight ?? FontWeight.w400,
    letterSpacing: 0,
    height: 1.35,
    color: color ?? AppColors.textSecondary,
  );

  static TextStyle labelSmCaps({Color? color, FontWeight? weight}) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: weight ?? FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.25,
    color: color ?? AppColors.textSecondary,
  );

  static TextStyle valueMd({Color? color, FontWeight? weight}) => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: weight ?? FontWeight.w700,
    letterSpacing: -0.15,
    height: 1.2,
    color: color ?? AppColors.textPrimary,
  );
}
