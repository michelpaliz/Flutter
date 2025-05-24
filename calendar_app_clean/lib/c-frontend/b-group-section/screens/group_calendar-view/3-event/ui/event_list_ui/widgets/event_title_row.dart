import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/screens/event_screen/event_detail.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';

class EventTitleRow extends StatelessWidget {
  final Event event;
  final Color textColor;
  final ColorManager colorManager;

  const EventTitleRow({
    Key? key,
    required this.event,
    required this.textColor,
    required this.colorManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = colorManager.getColor(event.eventColorIndex);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 4),
      child: Row(
        children: [
          Icon(Icons.event, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: accent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetail(event: event),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
