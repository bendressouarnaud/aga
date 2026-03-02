import 'package:flutter/material.dart';

class CustomOptinCheckBox extends StatelessWidget {

  // Attributes
  final String libelle;
  final bool valeur;
  final IconData icone;
  final Color couleur;
  final ValueChanged<bool?> onChanged;

  // Methods :
  const CustomOptinCheckBox({super.key, required this.libelle, required this.valeur, required this.icone,
    required this.couleur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(libelle),
        value: valeur,
        onChanged: onChanged,
        secondary: Icon(
          icone,
          color: couleur,
        )
    );
  }
}
