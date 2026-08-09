import 'package:flutter/material.dart';

import '../beans/generic_data.dart';

class CustomDropDownTwoAttributes extends StatelessWidget {

  // Attributes
  final double customWidth; // (MediaQuery.of(context).size.width / 2) - 20
  final double customMenuHeight;
  final GenericData? defaultValue;
  final String hintText;
  final bool requestFocusOnTap;
  final bool enableSearch;
  final bool enableFilter;
  final String label;
  //
  final ValueChanged<GenericData?> onSelected;
  final List<GenericData> lesDonnees;

  // Methods :
  const CustomDropDownTwoAttributes({super.key,
    required this.customWidth, required this.customMenuHeight, required this.defaultValue,
    required this.hintText, required this.requestFocusOnTap, required this.enableSearch,
    required this.enableFilter, required this.label, required this.onSelected, required this.lesDonnees});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<GenericData>(
        width: customWidth,
        menuHeight: customMenuHeight,
        initialSelection: defaultValue,
        //controller: statutMatrimonialController,
        hintText: hintText,
        requestFocusOnTap: requestFocusOnTap,
        enableSearch: enableSearch,
        enableFilter: enableFilter,
        label: Text(label),
        // Initial Value
        onSelected: onSelected,
        dropdownMenuEntries: lesDonnees.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
          return DropdownMenuEntry<GenericData>(
              value: menu,
              label: menu.libelle,
              leadingIcon: Icon(Icons.people_outline_outlined));
        }).toList()
    );
  }
}
