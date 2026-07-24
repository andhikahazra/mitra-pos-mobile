import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/core/services/theme_provider.dart';
import 'package:mitrapos/core/theme/app_theme.dart';
import 'package:mitrapos/presentation/splash/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID');
  await configureDependencies();

  runApp(ProviderScope(child: MitraPOSApp(themeProvider: getIt<ThemeProvider>())));
}

class MitraPOSApp extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MitraPOSApp({super.key, required this.themeProvider});

  @override
  State<MitraPOSApp> createState() => _MitraPOSAppState();
}

class _MitraPOSAppState extends State<MitraPOSApp> {
  @override
  void initState() {
    super.initState();
    widget.themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MitraPOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: widget.themeProvider.themeMode,
      home: const SplashPage(),
    );
  }
}
