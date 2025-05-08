import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../d-stateManagement/group_management.dart';
import '../../../../../../d-stateManagement/notification_management.dart';
import '../../../../../../d-stateManagement/user_management.dart';
import 'add_event_dialogs.dart';
import 'add_event_form.dart';
import 'add_event_logic.dart';

class AddEvent extends StatefulWidget {
  final Group group;

  const AddEvent({Key? key, required this.group}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent>
    with AddEventLogic<AddEvent>, AddEventDialogs {
  @override
  void initState() {
    super.initState();
    initializeLogic(widget.group, context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notificationManagement = Provider.of<NotificationManagement>(context);
    userManagement = Provider.of<UserManagement>(context);
    groupManagement = Provider.of<GroupManagement>(context);
    user = userManagement.user!;
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.event),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: AddEventForm(
                  logic: this,
                  dialogs: this,
                ),
              ),
      ),
    );
  }
}
