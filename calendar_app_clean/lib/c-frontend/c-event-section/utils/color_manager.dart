import 'package:flutter/material.dart';

class ColorManager {
  // Define a list of colors
  static final List<Color> eventColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.white, // Add white color
  ];

  // Define a map to associate color names with Color objects
  static final Map<String, Color> colorNameToColor = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
    'Teal': Colors.teal,
    'Indigo': Colors.indigo,
    'Deep Orange': Colors.deepOrange,
    'White': Colors.white,
  };

  // Define a method to get the name of a color based on its value
  static String getColorName(Color color) {
    for (var entry in colorNameToColor.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return 'Unknown';
  }

  int getColorIndex(Color color) {
    return eventColors.indexOf(color);
  }

  Color getColor(int index) {
    return ColorManager.eventColors[index];
  }
}
