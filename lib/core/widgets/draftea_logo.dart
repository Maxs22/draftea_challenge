import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

/// Widget del logo DRAFTEA usando el SVG del proyecto
class DrafteaLogo extends StatelessWidget {
  const DrafteaLogo({
    super.key,
    this.height = 20,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
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
