import 'package:first_project/costume_widgets/custom_text_field.dart';
import 'package:first_project/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetail extends StatefulWidget {
  final Event event;
  const EventDetail({super.key, required this.event});

  @override
  State<EventDetail> createState() => _EventDetailsWidget(event: event);
}

class _EventDetailsWidget extends State<EventDetail> {
  final Event event;

  _EventDetailsWidget({required this.event});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Event Details"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0),
            Center(
              child: Text(
                "EVENT DETAILS",
                style: TextStyle(
                  fontFamily: "bagel_fat_one.ttf",
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            CustomTextFieldWithIcons(
              text: event.title, // Pass the text directly
              hintText: "Title",
              fontFamily: 'lato.ttf',
              prefixIcon: Icons.title,
              suffixIcon: null,
              // height: 60,
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: CustomTextFieldWithIcons(
                      text:
                          '${DateFormat('yyyy - MM - dd').format(event.startDate)} ${DateFormat('HH:mm').format(event.startDate)}',
                      hintText: "Start Date",
                      fontFamily: 'lato',
                      prefixIcon: Icons.date_range,
                      suffixIcon: null,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: CustomTextFieldWithIcons(
                      text:
                          '${DateFormat('yyyy - MM - dd').format(event.endDate)} ${DateFormat('HH:mm').format(event.endDate)}',
                      hintText: "End Date",
                      fontFamily: 'lato',
                      prefixIcon: Icons.date_range,
                      suffixIcon: null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            if (event.localization != null)
              CustomTextFieldWithIcons(
                text: event.localization, // Pass the text directly
                hintText: "Localization",
                fontFamily: 'lato',
                prefixIcon: Icons.location_on,
                suffixIcon: null,
              ),
            if (event.description != null)
              CustomTextFieldWithIcons(
                text: event.description, // Pass the text directly
                hintText: "Description",
                fontFamily: 'lato',
                prefixIcon: Icons.description,
                suffixIcon: null,
              ),
            if (event.note != null)
              CustomTextFieldWithIcons(
                text: event.note, // Pass the text directly
                hintText: "Note",
                fontFamily: 'lato',
                prefixIcon: Icons.note,
                suffixIcon: null,
              ),
            SizedBox(height: 8.0),
            if (event.recurrenceRule != null)
              CustomTextFieldWithIcons(
                text: event.recurrenceRule.toString(), // Pass the text directly
                hintText: "Recurrence Rule",
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
