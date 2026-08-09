import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  // Attributes
  final TextInputType textInputType;
  final TextEditingController textEditingController;
  final String labelText;
  final double height;
  final TextAlignVertical textAlignVertical;
  final TextAlign textAlign;
  final TextInputAction textInputAction;

  // Methods :
  const CustomTextField(
  {
    super.key,
    required this.textInputType, required this.textEditingController, required this.labelText,
    required this.height, required this.textAlignVertical, required this.textAlign,
    required this.textInputAction
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        keyboardType: textInputType,
        controller: textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
        ),
        style: TextStyle(
            height: height
        ),
        textAlignVertical: textAlignVertical,
        textAlign: textAlign,
        textInputAction: textInputAction
    );
  }
}
