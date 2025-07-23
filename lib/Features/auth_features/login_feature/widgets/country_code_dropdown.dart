import 'package:flutter/material.dart';

class CountryCodeDropdown extends StatelessWidget {
  final String selectedCountryCode;
  final Function(String) onChanged;

  const CountryCodeDropdown({
    super.key,
    required this.selectedCountryCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCountryCode,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(value: '+966', child: Text('+966')),
        DropdownMenuItem(value: '+971', child: Text('+971')),
        DropdownMenuItem(value: '+965', child: Text('+965')),
        DropdownMenuItem(value: '+973', child: Text('+973')),
        DropdownMenuItem(value: '+974', child: Text('+974')),
      ],
      onChanged: (String? value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
