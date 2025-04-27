import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? hintText;

  const TextFieldWidget({
    required this.controller,
    required this.decoration,
    required this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.hintText,
    Key? key,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final baseDecoration = widget.decoration.copyWith(
      hintText: widget.hintText ?? widget.decoration.hintText,
      errorText: showError
          ? (widget.validator != null
              ? widget.validator!(widget.controller.text)
              : null)
          : null,
    );

    return Column(
      children: [
        TextField(
          controller: widget.controller,
          decoration: baseDecoration,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          inputFormatters: widget.inputFormatters,
          onChanged: (value) {
            setState(() {
              showError =
                  widget.validator != null && widget.validator!(value) != null;
            });
          },
        ),
      ],
    );
  }
}
