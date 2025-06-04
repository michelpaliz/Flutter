import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/functions/edit/edit_event_logic.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/shared/form/event_form.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen>
    with EditEventLogic<EditEventScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initLogic(
      event: widget.event,
      gm: context.read<GroupManagement>(),
      um: context.read<UserManagement>(),
    );
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return Scaffold(
    appBar: AppBar(title: Text(loc.event)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: EventForm(
        logic: this,
        onSubmit: saveEditedEvent, // <-- from your logic mixin
        isEditing: true,           // <-- tells EventForm to use edit mode
      ),
    ),
  );
}

}
