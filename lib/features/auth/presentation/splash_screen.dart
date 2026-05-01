import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E1A00), ScolarisPalette.terracotta],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 96,
                  height: 96,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 52),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppConfig.appName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(AppConfig.appTagline,
                  style: TextStyle(
                      color: ScolarisPalette.gold.withOpacity(.9),
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
