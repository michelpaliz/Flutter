import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final double height;

  const CurvedHeader({Key? key, this.height = 180}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedTopClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.getButtonBackgroundColor(context),
              ThemeColors.getContainerBackgroundColor(context),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
