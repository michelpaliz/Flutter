// lib/.../calendar/widgets/presence_status_strip.dart
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_main_view/logic/calendar_screen_controller.dart';
import 'package:hexora/f-themes/utilities/image/user_status_avatar_row.dart';
import 'package:flutter/material.dart';

class PresenceStatusStrip extends StatelessWidget {
  final Group group;
  final CalendarScreenController controller;
  const PresenceStatusStrip(
      {super.key, required this.group, required this.controller});

  @override
  Widget build(BuildContext context) {
    final connectedUsers = controller.buildPresenceFor(group);
    return UserStatusRow(userList: connectedUsers);
  }
}
