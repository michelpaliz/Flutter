import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class CustomEditableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int? maxLength;
  final bool isMultiline;
  final IconData? prefixIcon;

  const CustomEditableTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.maxLength,
    this.isMultiline = false,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        ThemeColors.getTextColor(context).withOpacity(0.7);
    final Color fillColor = ThemeColors.getContainerBackgroundColor(context);

    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: isMultiline ? null : 1,
      style: TextStyle(
        color: ThemeColors.getTextColor(context),
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: ThemeColors.getTextColor(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: ThemeColors.getTextColor(context))
            : null,
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
