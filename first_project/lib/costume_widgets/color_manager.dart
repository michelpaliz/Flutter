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

  // Define a method to get the name of a color based on its value
  static String getColorName(Color color) {
    if (color == Colors.red) {
      return 'Red';
    } else if (color == Colors.blue) {
      return 'Blue';
    } else if (color == Colors.green) {
      return 'Green';
    } else if (color == Colors.yellow) {
      return 'Yellow';
    } else if (color == Colors.orange) {
      return 'Orange';
    } else if (color == Colors.purple) {
      return 'Purple';
    } else if (color == Colors.pink) {
      return 'Pink';
    } else if (color == Colors.teal) {
      return 'Teal';
    } else if (color == Colors.indigo) {
      return 'Indigo';
    } else if (color == Colors.deepOrange) {
      return 'Deep Orange';
    } else if (color == Colors.white) {
      return 'White';
    } else {
      return 'Unknown';
    }
  }
}
