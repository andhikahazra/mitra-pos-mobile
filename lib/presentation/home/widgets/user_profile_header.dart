import 'package:flutter/material.dart';
import 'package:mitrapos/core/constants/app_constants.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';

/// User profile header widget
class UserProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final bool isPrinterConnected;
  final VoidCallback onProfileTap;

  const UserProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.isPrinterConnected,
    required this.onProfileTap,
  });

  String _initials(String fullName) {
    final words = fullName
        .trim()
        .split(RegExp(r'\\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'MP';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    final initials = words.take(3).map((w) => w.substring(0, 1).toUpperCase()).join();
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.indigoPrimary, AppColors.indigoPrimaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                _initials(name),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypePairing.titleMd(weight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    email,
                    style: AppTypePairing.bodySm(
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: (isPrinterConnected ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.print_rounded,
                color: isPrinterConnected ? AppColors.success : AppColors.error,
                size: 18,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textSecondary,
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
