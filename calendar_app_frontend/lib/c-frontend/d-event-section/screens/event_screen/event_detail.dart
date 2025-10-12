import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/f-themes/utilities/view-item-styles/text_field/static/custom_text_field.dart';
import 'package:hexora/l10n/app_localizations.dart'; // ✅ Add this
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetail extends StatefulWidget {
  final Event event;
  const EventDetail({super.key, required this.event});

  @override
  State<EventDetail> createState() => _EventDetailsWidget();
}

class _EventDetailsWidget extends State<EventDetail> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final loc = AppLocalizations.of(context)!; // ✅ Access localization

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.eventDetailsTitle), // ✅ Localized
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: null,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            CustomTextFieldWithIcons(
              text: event.title,
              hintText: loc.eventTitleHint,
              fontFamily: 'lato.ttf',
              prefixIcon: Icons.title,
              suffixIcon: null,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: CustomTextFieldWithIcons(
                    text:
                        '${DateFormat('yyyy - MM - dd').format(event.startDate)} ${DateFormat('HH:mm').format(event.startDate)}',
                    hintText: loc.eventStartDateHint,
                    fontFamily: 'lato',
                    prefixIcon: Icons.date_range,
                    suffixIcon: null,
                  ),
                ),
                Expanded(
                  child: CustomTextFieldWithIcons(
                    text:
                        '${DateFormat('yyyy - MM - dd').format(event.endDate)} ${DateFormat('HH:mm').format(event.endDate)}',
                    hintText: loc.eventEndDateHint,
                    fontFamily: 'lato',
                    prefixIcon: Icons.date_range,
                    suffixIcon: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (event.localization != null)
              CustomTextFieldWithIcons(
                text: event.localization!,
                hintText: loc.eventLocationHint,
                fontFamily: 'lato',
                prefixIcon: Icons.location_on,
                suffixIcon: null,
              ),
            if (event.description != null)
              CustomTextFieldWithIcons(
                text: event.description!,
                hintText: loc.eventDescriptionHint,
                fontFamily: 'lato',
                prefixIcon: Icons.description,
                suffixIcon: null,
              ),
            if (event.note != null)
              CustomTextFieldWithIcons(
                text: event.note!,
                hintText: loc.eventNoteHint,
                fontFamily: 'lato',
                prefixIcon: Icons.note,
                suffixIcon: null,
              ),
            const SizedBox(height: 8.0),
            if (event.recurrenceRule != null)
              CustomTextFieldWithIcons(
                text: event.recurrenceRule.toString(),
                hintText: loc.eventRecurrenceHint,
                fontFamily: 'lato',
                prefixIcon: Icons.repeat,
                suffixIcon: null,
              ),
          ],
        ),
      ),
    );
  }
}
