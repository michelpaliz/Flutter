import 'package:calendar_app_frontend/e-drawer-style-menu/contextual_fab.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/horizontal_drawer_nav.dart';
import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  /// Keep `title` for back-compat; use `titleWidget` to show custom header (avatar + name).
  final String title;
  final Widget body;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;

  /// Stop passing per-screen FABs when using the center-docked FAB.
  final FloatingActionButton? fab; // legacy, unused now

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleWidget,
    this.leading,
    this.actions,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppDarkColors.background : AppColors.background;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bg,
      extendBody: true, // Allows body to extend behind bottom bar
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        titleSpacing: 16,
        centerTitle: false,
        leading: leading,
        title: titleWidget ?? Text(title),
        actions: actions,
        iconTheme: IconThemeData(color: onSurface),
        actionsIconTheme: IconThemeData(color: onSurface),
        // ⬇️ add this line
        automaticallyImplyLeading: false,
      ),
      // Removed SafeArea wrapper to let BottomAppBar handle safe areas
      body: Container(color: bg, child: body),
      bottomNavigationBar: BottomAppBar(
        // Host (bar) + guest (FAB) shapes so the notch matches our rounded FAB
        shape: AutomaticNotchedShape(
          const RoundedRectangleBorder(), // host
          ContinuousRectangleBorder(
            // guest (FAB)
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        notchMargin: 10,
        elevation: 8,
        color: (Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.background
                : AppColors.background)
            .withOpacity(0.96),
        // Slightly wider gap for the pill-shaped FAB
        child: const HorizontalDrawerNav(centerGapWidth: 96),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const ContextualFab(),
    );
  }
}
