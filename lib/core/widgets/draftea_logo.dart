import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

/// Widget del logo DRAFTEA usando el SVG del proyecto
class DrafteaLogo extends StatelessWidget {
  const DrafteaLogo({
    super.key,
    double? height,
  }) : _height = height;

  final double? _height;

  double _getHeight(BuildContext context) {
    final height = _height;
    if (height != null) return height;
    // Tamaño más grande en web
    if (kIsWeb) {
      return 32;
    }
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final height = _getHeight(context);
    return SvgPicture.asset(
      'assets/logo.svg',
      height: height,
      width: height * 3.625, // Mantener proporción del SVG (58/16)
      colorFilter: const ColorFilter.mode(
        AppColors.textLight,
        BlendMode.srcIn,
      ),
    );
  }
}
