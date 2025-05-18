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
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final groupManagement = Provider.of<GroupManagement>(context);
      final userManagement = Provider.of<UserManagement>(context);
      final notificationManagement =
          Provider.of<NotificationManagement>(context);

      // ✅ Inject dependencies
      injectDependencies(
        groupMgmt: groupManagement,
        userMgmt: userManagement,
        notifMgmt: notificationManagement,
      );

      // ✅ Now run init logic
      Future.microtask(() async {
        await initializeLogic(widget.group, context);
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });

      _initialized = true;
    }
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
