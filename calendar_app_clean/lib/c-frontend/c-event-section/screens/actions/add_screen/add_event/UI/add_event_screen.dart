import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../d-stateManagement/user/user_management.dart';
import '../functions/add_event_dialogs.dart';
import '../functions/add_event_form.dart';
import '../functions/add_event_logic.dart';

class AddEventScreen extends StatefulWidget {
  final Group group;

  const AddEventScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen>
    with AddEventLogic<AddEventScreen>, AddEventDialogs {
  bool _initialized = false;
  bool _isLoading = true; // this is what drives the UI

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final groupManagement =
          Provider.of<GroupManagement>(context, listen: false);
      final userManagement =
          Provider.of<UserManagement>(context, listen: false);
      final notificationManagement =
          Provider.of<NotificationManagement>(context, listen: false);

      injectDependencies(
        groupMgmt: groupManagement,
        userMgmt: userManagement,
        notifMgmt: notificationManagement,
      );

      _initialized = true;
      _initializeLogic(); // async init
    }
  }

  Future<void> _initializeLogic() async {
    // ⚠️ sanity check in debug:

    try {
      await initializeLogic(widget.group, context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        body: _isLoading
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
