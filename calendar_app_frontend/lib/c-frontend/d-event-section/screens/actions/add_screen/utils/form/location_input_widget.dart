import 'package:hexora/f-themes/app_utilities/app_utils.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class LocationInputWidget extends StatelessWidget {
  final TextEditingController locationController;

  const LocationInputWidget({required this.locationController});

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
        return await AppUtils.getAddressSuggestions(pattern);
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
