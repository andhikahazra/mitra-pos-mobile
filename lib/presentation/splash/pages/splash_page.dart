import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/presentation/auth/pages/login_page.dart';
import 'package:mitrapos/presentation/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = getIt<SharedPreferences>();
    final String? token = prefs.getString('auth_token');

    _navigateTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      if (token != null && token.isNotEmpty) {
        // Token ada, langsung ke Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // Token tidak ada, ke Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const SafeArea(
        child: Center(
          child: SizedBox(
            width: 96,
            height: 96,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
