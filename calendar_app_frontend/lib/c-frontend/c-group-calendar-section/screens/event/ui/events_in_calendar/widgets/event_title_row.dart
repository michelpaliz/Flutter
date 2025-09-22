import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/utils/color_manager.dart';
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
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        children: [
          // Icon(Icons.event, size: 18, color: accent),
          // const SizedBox(width: 8),
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
          // IconButton(
          //   icon: Icon(Icons.more_vert, color: accent),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => EventDetail(event: event),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
