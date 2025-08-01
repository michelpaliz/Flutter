import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

import 'my_drawer.dart';

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? fab;

  const MainScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customBackgroundColor =
        isDark ? AppDarkColors.background : AppColors.background;

    return Scaffold(
      backgroundColor: customBackgroundColor,
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: MyDrawer(),
      body: SafeArea(
        child: Container(
          color: customBackgroundColor, // ✅ Custom palette color
          child: body,
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
