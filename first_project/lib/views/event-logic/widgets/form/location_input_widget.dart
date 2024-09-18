import 'package:first_project/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
class LocationInputWidget extends StatelessWidget {
  final TextEditingController locationController;

  const LocationInputWidget({
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: locationController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.location,
        ),
      ),
      suggestionsCallback: (pattern) async {
        return await Utilities.getAddressSuggestions(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(title: Text(suggestion));
      },
      onSuggestionSelected: (suggestion) {
        locationController.text = suggestion;
      },
    );
  }
}
