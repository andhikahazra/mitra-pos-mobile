import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/core/theme/app_theme.dart';
import 'package:mitrapos/presentation/splash/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize intl locale data before using DateFormat with specific locales.
  await initializeDateFormatting('id_ID');

  // Configure dependency injection
  await configureDependencies();

  runApp(const ProviderScope(child: MitraPOSApp()));
}

class MitraPOSApp extends StatelessWidget {
  const MitraPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MitraPOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
