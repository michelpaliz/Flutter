
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class ColorPickerWidget extends StatelessWidget {
  final Color? selectedEventColor;
  final ValueChanged<Color?> onColorChanged;
  final List<Color> colorList;

  const ColorPickerWidget({
    required this.selectedEventColor,
    required this.onColorChanged,
    required this.colorList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.chooseEventColor,
          style: TextStyle(
              fontSize: 14, color: Color.fromARGB(255, 121, 122, 124)),
        ),
        DropdownButtonFormField<Color>(
          value: selectedEventColor,
          onChanged: onColorChanged,
          items: colorList.map((color) {
            String colorName = ColorManager.getColorName(color);
            return DropdownMenuItem<Color>(
              value: color,
              child: Row(
                children: [
                  Container(width: 20, height: 20, color: color),
                  SizedBox(width: 10),
                  Text(colorName),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
