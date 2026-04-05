import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SalienaLogo extends StatelessWidget {
  final bool isDarkBackground;
  final bool withText;
  final double scale;

  const SalienaLogo({
    super.key,
    this.isDarkBackground = false,
    this.withText = true,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLightMode = brightness == Brightness.light;
    
    if (withText) {
      // Use SVG logo with "saliena estate" text in light mode, PNG in dark mode
      final double baseHeight = 120.0;
      final double scaledHeight = baseHeight * scale;

      if (isLightMode) {
        return SvgPicture.asset(
          'assets/icons/LightMode-BigLogo.svg',
          height: scaledHeight,
          fit: BoxFit.contain,
        );
      } else {
        return Image.asset(
          'assets/icons/Saliena-Estate-logo.png',
          height: scaledHeight,
          fit: BoxFit.contain,
        );
      }
    } else {
      // Use PNG for icon-only (house/sun/lines without text)
      final double baseHeight = 50.0;
      final double scaledHeight = baseHeight * scale;

      return Image.asset(
        'assets/icons/BigLogo.png',
        height: scaledHeight,
        fit: BoxFit.contain,
      );
    }
  }
}
