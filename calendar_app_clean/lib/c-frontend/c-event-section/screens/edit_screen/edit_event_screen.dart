import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/updateInfo.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/event_services.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/c-frontend/b-group-section/utils/event/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'functions/fetch_data.dart';
import 'functions/save_edited_event.dart';
import 'functions/select_date.dart';
import 'widgets/event/date_picker.dart';
import 'widgets/event/description_input.dart';
import 'widgets/event/event_color_dropdown.dart';
import 'widgets/event/location_input.dart';
import 'widgets/event/note_input.dart';
import 'widgets/event/repetition_toggle.dart';
import 'widgets/event/save_button.dart';
import 'widgets/event/title_input.dart';
import 'widgets/event/user_dropdown.dart';

part 'edit_event_screen_logic.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}
