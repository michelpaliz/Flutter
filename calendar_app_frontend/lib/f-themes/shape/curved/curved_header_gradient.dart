import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:flutter/material.dart';

class SolidHeader extends StatelessWidget {
  final double height;

  const SolidHeader({Key? key, this.height = 160}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color baseColor = ThemeColors.getButtonBackgroundColor(context);
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return ClipPath(
      clipper: BottomCurvedClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              baseColor,
              backgroundColor.withOpacity(0.70), // smooth transition
            ],
          ),
        ),
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
