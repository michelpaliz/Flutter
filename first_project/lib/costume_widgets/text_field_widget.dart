import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final bool obscureText;

  const TextFieldWidget({
    required this.controller,
    required this.decoration,
    required this.keyboardType,
    this.obscureText = false,
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
          onChanged: (value) {
            setState(() {
              showError = value.isEmpty;
            });
          },
        ),
      ],
    );
  }
}
