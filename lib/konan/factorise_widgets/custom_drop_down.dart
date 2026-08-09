import 'package:flutter/material.dart';

import '../beans/generic_data.dart';

class CustomDropDown<T> extends StatelessWidget {

  // Attributes
  final double customWidth; // (MediaQuery.of(context).size.width / 2) - 20
  final double customMenuHeight;
  final T? defaultValue;
  final String hintText;
  final bool requestFocusOnTap;
  final bool enableSearch;
  final bool enableFilter;
  final String label;
  //
  final ValueChanged<T?> onSelected;
  final List<T> lesDonnees;

  // Methods :
  const CustomDropDown({super.key,
    required this.customWidth, required this.customMenuHeight, required this.defaultValue,
    required this.hintText, required this.requestFocusOnTap, required this.enableSearch,
    required this.enableFilter, required this.label, required this.onSelected, required this.lesDonnees});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
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
        dropdownMenuEntries: lesDonnees.map<DropdownMenuEntry<T>>((T menu) {
          return DropdownMenuEntry<T>(
              value: menu,
              label: menu is GenericData ? menu.libelle : '',
              leadingIcon: Icon(Icons.people_outline_outlined));
        }).toList()
    );
  }
}
