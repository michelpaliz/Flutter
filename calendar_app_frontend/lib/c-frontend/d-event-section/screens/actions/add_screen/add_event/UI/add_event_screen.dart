// add_event_screen.dart
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/category/category_services.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/add_event/functions/helper/add_event_helpers.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/form/event_form.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/repetition_dialog/dialog/repetition_dialog.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../d-stateManagement/user/user_management.dart';
import '../functions/add_event_dialogs.dart';
import '../functions/logic/add_event_logic.dart';

class AddEventScreen extends StatefulWidget {
  final Group group;

  const AddEventScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends AddEventLogic<AddEventScreen>
    with AddEventDialogs
    implements EventDialogs {
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

      // Optional now that validation is reactive; harmless to keep.
      titleController.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e, s) {
      debugPrint('AddEventScreen init failed: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load data, try again.')),
        );
      }
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

    // inside _AddEventScreenState.build(...)
    final categoryApi = CategoryApi(
      baseUrl: ApiConstants.baseUrl, // ✅ single source of truth
      headersProvider: () async {
        final auth = context.read<AuthProvider>();
        final token = await auth.getToken(); // returns null if not logged in
        return {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(loc.event)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EventForm(
                logic: this,
                dialogs: this,
                onSubmit: () async {
                  final ok = await withLoadingDialog<bool>(
                    context,
                    () => addEvent(context), // ✅ call method on this state
                    message: AppLocalizations.of(context)!.createEventMessage,
                  );
                  if (ok == true && context.mounted) {
                    Navigator.pop(context, true);
                  } else {
                    showErrorDialog(
                        context); // ✅ this state implements EventDialogs
                  }
                },
                categoryApi: categoryApi,
                ownerUserId: context.read<UserManagement>().user!.id,
                isEditing: false,
              ),
            ),
    );
  }

  @override
  Widget buildRepetitionDialog(BuildContext context) {
    return RepetitionDialog(
      selectedStartDate: selectedStartDate,
      selectedEndDate: selectedEndDate,
      initialRecurrenceRule: recurrenceRule,
    );
  }
}
