import 'package:first_project/styles/view-item-styles/button_styles.dart';
import 'package:flutter/material.dart';

class ColorProperties {
  static const Color BUTTON_DEFAULT_PROPERTY =
      Color.fromARGB(255, 19, 99, 148);

  static const Color BUTTON_PRESSED_BACKGROUND =
      Color.fromARGB(255, 131, 205, 216);

  static const Color BUTTON_TEXT_COLOR = Colors.black;

  static const Color BUTTON_BORDER_COLOR = Color.fromARGB(255, 17, 159, 241);

  static ButtonStyle defaultButton() {
  ButtonStyle _myCustomButtonStyle = ButtonStyles.saucyButtonStyle(
    defaultBackgroundColor: ColorProperties.BUTTON_DEFAULT_PROPERTY,
    pressedBackgroundColor: const Color.fromARGB(255, 131, 212, 216),
    textColor: ColorProperties.BUTTON_TEXT_COLOR,
    borderColor: ColorProperties.BUTTON_BORDER_COLOR,
  );

  return _myCustomButtonStyle;
}

}
