import 'package:calendar_app_frontend/e-drawer-style-menu/horizontal_drawer_nav.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // ✅ Ensure full screen height using MediaQuery
        height: MediaQuery.of(context).size.height,
        color: ThemeColors.getLighterInputFillColor(context),
        // child: SingleChildScrollView(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       MyHeaderDrawer(),
        //       MyDrawerList(context),
        //     ],
        //   ),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            // MyHeaderDrawer(),
            // SizedBox(height: 8),
            HorizontalDrawerNav(), // ⬅️ NEW horizontal 3-icon bar
            // SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
