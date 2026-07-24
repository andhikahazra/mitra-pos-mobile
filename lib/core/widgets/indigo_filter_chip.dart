import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';

class IndigoFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const IndigoFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? context.indigoPrimary : context.primaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypePairing.labelSmCaps(
          color: selected ? Colors.white : context.indigoPrimary,
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: chip,
    );
  }
}
