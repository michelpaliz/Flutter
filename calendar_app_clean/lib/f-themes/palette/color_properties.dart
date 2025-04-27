import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:flutter/material.dart';

class ColorProperties {
  // Button Colors
  static const Color BUTTON_DEFAULT_PROPERTY = AppColors.green;
  static const Color BUTTON_PRESSED_BACKGROUND = AppColors.greenLight;
  static const Color BUTTON_TEXT_COLOR = AppColors.white;
  static const Color BUTTON_BORDER_COLOR = AppColors.greenDark;

  static ButtonStyle defaultButton() {
    return ButtonStyles.saucyButtonStyle(
      defaultBackgroundColor: BUTTON_DEFAULT_PROPERTY,
      pressedBackgroundColor: BUTTON_PRESSED_BACKGROUND,
      textColor: BUTTON_TEXT_COLOR,
      borderColor: BUTTON_BORDER_COLOR,
    );
  }

  // Optionally add more buttons
  static ButtonStyle dangerButton() {
    return ButtonStyles.saucyButtonStyle(
      defaultBackgroundColor: AppColors.red,
      pressedBackgroundColor: AppColors.redLight,
      textColor: AppColors.white,
      borderColor: AppColors.redDark,
    );
  }

  static ButtonStyle infoButton() {
    return ButtonStyles.saucyButtonStyle(
      defaultBackgroundColor: AppColors.blue,
      pressedBackgroundColor: AppColors.blueLight,
      textColor: AppColors.white,
      borderColor: AppColors.blueDark,
    );
  }
}
