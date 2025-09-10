// edit_event_screen.dart
import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/category/category_services.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/edit_screen/functions/edit/edit_event_logic.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/form/event_form.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/repetition_dialog/dialog/repetition_dialog.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends EditEventLogic<EditEventScreen>
    implements EventDialogs {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeLogic();
      _isInitialized = true;
    }
  }

  Future<void> _initializeLogic() async {
    await initLogic(
      event: widget.event,
      gm: context.read<GroupManagement>(),
      um: context.read<UserManagement>(),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    disposeLogic();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EventForm(
                logic: this,
                onSubmit: () =>
                    saveEditedEvent(context.read<EventDataManager>()),
                isEditing: true,
                ownerUserId: context.read<UserManagement>().user!.id,
                dialogs: this, // enables repetition dialog in edit mode
                categoryApi: categoryApi,
              ),
            ),
    );
  }

  // Not used by EventForm, but required by the interface.
  @override
  Widget buildRepetitionDialog(BuildContext context) {
    throw UnimplementedError(
      'buildRepetitionDialog is not used in EditEventScreen.',
    );
  }

  @override
  void showErrorDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.event),
        content: Text(AppLocalizations.of(context)!.errorEventCreation),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Future<List<Object?>?> showRepetitionDialog(
    // 👈 typed
    BuildContext context, {
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
    LegacyRecurrenceRule? initialRule,
  }) {
    return showDialog<List<Object?>?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (context) => RepetitionDialog(
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
        initialRecurrenceRule: initialRule,
      ),
    );
  }
}
