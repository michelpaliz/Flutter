import 'package:first_project/c-frontend/c-event-section/screens/actions/shared/form/event_form.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/shared/form/event_form_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../d-stateManagement/user/user_management.dart';
import '../functions/add_event_dialogs.dart';
import '../functions/add_event_logic.dart';

class AddEventScreen extends StatefulWidget {
  final Group group;

  const AddEventScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen>
    with AddEventLogic<AddEventScreen>, AddEventDialogs
    implements EventFormLogic, EventDialogs {
  bool _initialized = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      injectDependencies(
        groupMgmt: context.read<GroupManagement>(),
        userMgmt: context.read<UserManagement>(),
        notifMgmt: context.read<NotificationManagement>(),
      );
      _initialized = true;
      _initializeLogic();
    }
  }

  Future<void> _initializeLogic() async {
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.event)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EventForm(
                logic: this,
                dialogs: this,
                onSubmit: () {}, // not used in add flow
                isEditing: false,
              ),
            ),
    );
  }
}
