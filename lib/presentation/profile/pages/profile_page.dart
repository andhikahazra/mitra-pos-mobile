import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/core/services/theme_provider.dart';

import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/presentation/auth/controller/auth_controller.dart';
import 'package:mitrapos/presentation/auth/pages/login_page.dart';
import 'package:mitrapos/presentation/profile/pages/thermal_printer_settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _initials(String fullName) {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'MP';
    return words.take(3).map((w) => w.substring(0, 1).toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Profil', style: AppTypePairing.headlineLg()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.surfaceContainerLowest, context.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.indigoSurfaceTint.withValues(alpha: 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.indigoPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.indigoSurfaceTint.withValues(alpha: 0.24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: context.primaryGradient,
                    ),
                    child: Center(
                      child: Text(
                        _initials(user?.name ?? 'MP'),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Memuat...',
                      style: AppTypePairing.headlineLg(),
                    ),
                    const SizedBox(height: 3),
                    Text(user?.email ?? '...', style: AppTypePairing.bodySm()),
                    const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.indigoSurfaceTint.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          user?.role ?? 'User',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: context.indigoPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.indigoSurfaceTint.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: context.indigoPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            children: [
              _ProfileInfoTile(
                icon: Icons.storefront_outlined,
                title: 'Peran Pengguna',
                value: user?.role ?? 'Karyawan',
                accentColor: context.indigoPrimary,
              ),
              Divider(
                height: 1,
                color: context.indigoSurfaceTint.withValues(alpha: 0.12),
              ),
              _ProfileInfoTile(
                icon: Icons.check_circle_outline,
                title: 'Status Akun',
                value: (user?.status ?? false) ? 'Aktif' : 'Non-aktif',
                accentColor: (user?.status ?? false) ? context.success : context.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              _ProfileMenuTile(
                icon: Icons.lock_outline,
                title: 'Keamanan Akun',
                subtitle: 'Atur kata sandi dan proteksi akun',
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: context.indigoSurfaceTint.withValues(alpha: 0.12),
              ),
              _ProfileMenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifikasi',
                subtitle: 'Kelola pengingat dan update sistem',
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: context.indigoSurfaceTint.withValues(alpha: 0.12),
              ),
              _ProfileMenuTile(
                icon: Icons.print_rounded,
                title: 'Pengaturan Printer',
                subtitle: 'Hubungkan printer bluetooth thermal',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ThermalPrinterSettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              _ThemeModeTile(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);

                // Hapus token dari memori
                await ref.read(authControllerProvider.notifier).add(const LogoutRequested());
                
                if (!mounted) return;
                
                // Pindah ke halaman Login dan hapus semua history navigasi
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.textPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: Text(
                'Keluar',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypePairing.bodySm(weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypePairing.bodySm(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: context.indigoSurfaceTint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: context.indigoPrimary),
      ),
      title: Text(title, style: AppTypePairing.bodySm(weight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: AppTypePairing.bodySm(color: context.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.textSecondary,
      ),
    );
  }
}

class _ThemeModeTile extends StatefulWidget {
  const _ThemeModeTile();

  @override
  State<_ThemeModeTile> createState() => _ThemeModeTileState();
}

class _ThemeModeTileState extends State<_ThemeModeTile> {
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = getIt<ThemeProvider>();
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: context.indigoSurfaceTint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.dark_mode_outlined,
          size: 18,
          color: context.indigoPrimary,
        ),
      ),
      title: Text('Mode Gelap', style: AppTypePairing.bodySm(weight: FontWeight.w600)),
      subtitle: Text(
        'Gunakan tampilan gelap untuk aplikasi',
        style: AppTypePairing.bodySm(color: context.textSecondary),
      ),
      trailing: Switch(
        value: _themeProvider.isDark,
        onChanged: (_) => _themeProvider.toggleTheme(),
        activeThumbColor: context.indigoPrimary,
      ),
    );
  }
}
