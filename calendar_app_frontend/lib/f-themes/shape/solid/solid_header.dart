import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class SolidHeader extends StatelessWidget {
  final double height;

  const SolidHeader({Key? key, this.height = 160}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color baseColor = ThemeColors.getButtonBackgroundColor(context);

    return ClipPath(
      clipper: BottomCurvedClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: baseColor, // ✅ Solid color only
      ),
    );
  }
}

class BottomCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
