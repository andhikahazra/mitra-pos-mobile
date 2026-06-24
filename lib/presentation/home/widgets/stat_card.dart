import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';

/// Reusable statistic card widget with improved visuals
class StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final int growthPercentage;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.growthPercentage,
    this.iconColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.growthPercentage >= 0;
    final trendColor = isPositive ? AppColors.success : AppColors.error;
    final iconColor = widget.iconColor ?? AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFBFBFB),
              const Color(0xFFF8F8F8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: _isHovered ? AppColors.border.withValues(alpha: 0.5) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 15,
                    color: iconColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    isPositive ? '+${widget.growthPercentage}%' : '${widget.growthPercentage}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              widget.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.value,
                maxLines: 1,
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
            ),
            const Spacer(),
            Text(
              isPositive ? '+${widget.growthPercentage}% growth' : '${widget.growthPercentage}% decline',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: trendColor.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
