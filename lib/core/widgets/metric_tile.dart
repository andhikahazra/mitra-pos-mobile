import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trendLabel;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.trendLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.indigoPrimary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, size: 11, color: iconColor),
              ),
              const Spacer(),
              if (trendLabel != null)
                Text(
                  trendLabel!,
                  style: AppTypePairing.labelSmCaps(
color: trendLabel!.startsWith('-')
                          ? context.error
                          : context.success,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label.toUpperCase(), style: AppTypePairing.labelSmCaps()),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypePairing.titleMd(),
          ),
        ],
      ),
    );
  }
}
