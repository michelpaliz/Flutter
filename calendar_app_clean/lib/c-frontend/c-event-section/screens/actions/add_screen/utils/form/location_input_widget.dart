import 'package:first_project/f-themes/utilities/utilities.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';

class LocationInputWidget extends StatelessWidget {
  final TextEditingController locationController;

  const LocationInputWidget({
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: locationController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.location,
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        return await Utilities.getAddressSuggestions(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(title: Text(suggestion));
      },
      onSelected: (suggestion) {
        locationController.text = suggestion;
      },
    );
  }
}
