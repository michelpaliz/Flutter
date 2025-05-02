import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class CustomEditableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int? maxLength;
  final bool isMultiline;
  final IconData? prefixIcon;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final Color? iconColor; // Optional override for icon
  final Color? backgroundColor; // Optional override for fill color
  final TextStyle? counterStyle; // ✅ External counter style override

  const CustomEditableTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.maxLength,
    this.isMultiline = false,
    this.prefixIcon,
    this.labelStyle,
    this.textStyle,
    this.iconColor,
    this.backgroundColor,
    this.counterStyle, // ✅ Added to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color resolvedFillColor =
        backgroundColor ?? ThemeColors.getLighterInputFillColor(context);
    final Color contrastTextColor =
        ThemeColors.getContrastTextColorForBackground(resolvedFillColor);
    final Color borderColor = contrastTextColor.withOpacity(0.5);

    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: isMultiline ? null : 1,
      style: textStyle ??
          TextStyle(
            color: contrastTextColor,
            fontWeight: FontWeight.bold,
          ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle ??
            TextStyle(
              color: contrastTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
        filled: true,
        fillColor: resolvedFillColor,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: iconColor ?? contrastTextColor,
              )
            : null,
        counterStyle: counterStyle ?? // ✅ use passed style or fallback
            TextStyle(color: contrastTextColor.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),
    );
  }
}
