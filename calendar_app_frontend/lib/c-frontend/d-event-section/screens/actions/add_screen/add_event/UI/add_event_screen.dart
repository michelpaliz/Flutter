// add_event_screen.dart
import 'package:hexora/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart'; // ⬅️ needed for the hook signature
import 'package:hexora/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:hexora/b-backend/api/category/category_services.dart';
import 'package:hexora/b-backend/api/config/api_constants.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/add_event/functions/helper/add_event_helpers.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/form/event_dialogs.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/form/event_form_route.dart';
import 'package:hexora/c-frontend/d-event-section/screens/repetition_dialog/dialog/repetition_dialog.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../d-stateManagement/user/user_management.dart';
import '../functions/addEvent/add_event_dialogs.dart';
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

      // (Optional) keep reactive title validity update
      titleController.addListener(() {
        if (mounted) setState(() {});
      });

      // 🔗 Wire the repetition dialog hook so forms can open it
      onShowRepetitionDialog = (
        BuildContext _, {
        required DateTime selectedStartDate,
        required DateTime selectedEndDate,
        LegacyRecurrenceRule? initialRule,
      }) {
        return showRepetitionDialog(
          context,
          selectedStartDate: selectedStartDate,
          selectedEndDate: selectedEndDate,
          initialRule: initialRule,
        );
      };
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

    // single source of truth for CategoryApi
    final categoryApi = CategoryApi(
      baseUrl: ApiConstants.baseUrl,
      headersProvider: () async {
        final auth = context.read<AuthProvider>();
        final token = await auth.getToken();
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
              child: EventFormRouter(
                logic: this,
                onSubmit: () async {
                  final ok = await withLoadingDialog<bool>(
                    context,
                    () => addEvent(context),
                    message: AppLocalizations.of(context)!.createEventMessage,
                  );
                  if (ok == true && context.mounted) {
                    Navigator.pop(context, true);
                  } else {
                    showErrorDialog(context);
                  }
                },
                ownerUserId: context.read<UserManagement>().user!.id,
                isEditing: false,
                categoryApi: categoryApi,
                dialogs: this,
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
