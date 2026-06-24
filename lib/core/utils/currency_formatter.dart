import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility class for currency formatting
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format number to currency with symbol
  static String format(
    num amount, {
    String symbol = 'Rp ',
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Format number to compact currency (e.g., 1.2K, 1.5M)
  static String formatCompact(
    num amount, {
    String symbol = 'Rp ',
  }) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return format(amount, symbol: symbol);
    }
  }

  /// Format number without currency symbol
  static String formatNumber(num amount, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(amount);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final double value = double.parse(text);
    final formatter = NumberFormat.decimalPattern('id');
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
