import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle saucyButtonStyle(bool buttonHovered) {
    return ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Colors.black,
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.grey.withOpacity(0.8); // Apply opacity when button is pressed
          }
          return Color.fromARGB(75, 131, 205, 216); // Default background color
        },
      ),
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.all(10),
      ),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color.fromARGB(255, 17, 159, 241)),
        ),
      ),
    );
  }
}
