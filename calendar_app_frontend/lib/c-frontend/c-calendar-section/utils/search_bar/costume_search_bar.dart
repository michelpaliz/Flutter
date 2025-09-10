import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function() onClear;
  final Function() onSearch;

  CustomSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.searchPerson,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            20.0,
          ), // Adjust the border radius as needed
        ),
        filled: true,
        fillColor: ThemeColors.getContainerBackgroundColor(
          context,
        ), // Background color
        prefixIcon: MouseRegion(
          onEnter: (_) {
            onSearch(); // Perform search when the icon is clicked
          },
          onExit: (_) {
            // Revert the icon to its original state when the mouse exits
          },
          child: GestureDetector(
            onTap: onSearch,
            child: Icon(
              Icons.search,
              color: Colors.black, // Icon color when not hovered
            ),
          ),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(onTap: onClear, child: Icon(Icons.clear))
            : null, // Show clear button when the input is not empty
      ),
    );
  }
}
