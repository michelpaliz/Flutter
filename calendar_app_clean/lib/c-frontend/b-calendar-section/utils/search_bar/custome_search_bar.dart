import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function onSearch;
  final Function onClear;

  CustomSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ThemeColors.getSearchBarBackgroundColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: ThemeColors.getTextColor(context),
              ),
              decoration: InputDecoration(
                hintText: 'Search user...',
                hintStyle: TextStyle(
                  color: ThemeColors.getSearchBarHintTextColor(context),
                ),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          IconButton(
            icon: Icon(Icons.clear,
                color: ThemeColors.getSearchBarIconColor(context)),
            onPressed: () {
              onClear();
            },
          ),
          IconButton(
            icon: Icon(Icons.search,
                color: ThemeColors.getSearchBarIconColor(context)),
            onPressed: () {
              onSearch();
            },
          ),
        ],
      ),
    );
  }
}
