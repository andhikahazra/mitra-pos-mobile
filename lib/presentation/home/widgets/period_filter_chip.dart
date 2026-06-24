import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';

/// Period filter chip widget with improved visuals
class PeriodFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PeriodFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<PeriodFilterChip> createState() => _PeriodFilterChipState();
}

class _PeriodFilterChipState extends State<PeriodFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: widget.isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.indigoPrimary,
                    AppColors.indigoPrimaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    AppColors.surfaceContainerLowest,
                    AppColors.surfaceContainerLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: _isPressed ? 0.18 : 0.12)
                  : AppColors.indigoSurfaceTint.withValues(alpha: _isPressed ? 0.07 : 0.04),
              blurRadius: _isPressed ? 10 : 6,
              offset: Offset(0, _isPressed ? 3 : 2),
            ),
          ],
        ),
        child: Transform.scale(
          scale: _isPressed ? 0.98 : 1.0,
          child: Text(
            widget.label,
            style: AppTypePairing.bodySm(
              color: widget.isSelected ? AppColors.white : AppColors.textSecondary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
