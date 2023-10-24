import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle saucyButtonStyle({
    required Color defaultBackgroundColor,
    required Color pressedBackgroundColor,
    required Color textColor,
    required Color borderColor,
    IconData? iconData,
  }) {
    return ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return pressedBackgroundColor; // Apply pressed background color
          } else if (states.contains(MaterialState.hovered)) {
            return defaultBackgroundColor; // Apply hovered background color
          }
          return defaultBackgroundColor; // Default background color
        },
      ),
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.all(10),
      ),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
      ),
    );
  }

  static Widget buttonWithIcon({
    required IconData iconData,
    required String label,
    required ButtonStyle style,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData),
          SizedBox(width: 8), // Add some spacing between icon and text
          Text(label),
        ],
      ),
    );
  }
}



