import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';

class EventContentBuilder {
  final ColorManager colorManager;
  const EventContentBuilder({required this.colorManager});

  /// Small “pill” used in month‐cell tiles
  Widget buildEventContent(Event event, Color textColor) {
    final accent = colorManager.getColor(event.eventColorIndex);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        event.title,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildDefaultEventCard({
    required Widget dateRow,
    required Widget timeRow,
    required Widget titleRow,
    String? description,
    required Color cardColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dateRow,
          timeRow,

          // Allow the title to shrink if there's not enough room
          Flexible(
            child: titleRow,
          ),

          if (description?.isNotEmpty ?? false)
            // And likewise for the description
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
