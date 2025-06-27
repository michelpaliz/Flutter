import 'package:flutter/material.dart';

enum LogoSize { small, medium, large }

class LogoWidget {
  static Widget buildLogoAvatar({LogoSize size = LogoSize.medium}) {
    double radius;
    switch (size) {
      case LogoSize.small:
        radius = 40.0;
        break;
      case LogoSize.medium:
        radius = 75.0;
        break;
      case LogoSize.large:
        radius = 100.0;
        break;
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage('assets/images/logo.jpeg'),
      backgroundColor: Colors.transparent,
    );
  }
}
