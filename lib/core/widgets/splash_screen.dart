import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'draftea_logo.dart';

/// Pantalla de splash con imagen de fondo
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
  });

  final VoidCallback onAnimationComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: AppColors.backgroundDark,
          ),
          Center(
            child: Image.asset(
              'assets/imagen_splash.jpg',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.backgroundDark,
                );
              },
            ),
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DrafteaLogo(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
