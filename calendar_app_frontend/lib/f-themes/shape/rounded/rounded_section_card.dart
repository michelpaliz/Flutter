import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:flutter/material.dart';

class RoundedSectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const RoundedSectionCard({
    Key? key,
    required this.child,
    this.title,
    this.backgroundColor, // Allows override, still respected
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultBackground = backgroundColor ??
        ThemeColors.getLighterInputFillColor(
            context); // ✅ lighter surface color

    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: defaultBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface, // ✅ Respect text contrast
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
