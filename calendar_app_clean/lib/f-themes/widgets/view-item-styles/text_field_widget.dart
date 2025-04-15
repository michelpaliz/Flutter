import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator; // Custom validator function

  const TextFieldWidget({
    required this.controller,
    required this.decoration,
    required this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.validator, // Include a custom validator
  });

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          decoration: widget.decoration.copyWith(
            errorText: showError
                ? '${widget.decoration.labelText} cannot be empty'
                : null,
          ),
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          inputFormatters: widget.inputFormatters,
          onChanged: (value) {
            setState(() {
              showError = widget.validator != null && widget.validator!(value) != null;
            });
          },
        ),
      ],
    );
  }
}
