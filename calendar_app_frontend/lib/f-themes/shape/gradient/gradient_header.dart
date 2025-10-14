import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final double height;

  const GradientHeader({Key? key, this.height = 160}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
