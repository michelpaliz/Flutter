import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';

abstract class BaseEventLogic<T extends StatefulWidget> extends State<T> {
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  // Public reactive validity
  final ValueNotifier<bool> canSubmit = ValueNotifier<bool>(false);

  // UI state
  late Color _selectedEventColor;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  bool _isDisposed = false; // 👈 guard flag

  // Recurrence
  LegacyRecurrenceRule? _recurrenceRule;
  bool _isRepetitive = false;

  // Misc UI
  final double _toggleWidth = 50.0;
  int _reminderMinutes = 10;

  // Users
  @protected
  List<User> _users = [];
  @protected
  List<User> _selectedUsers = [];

  // ── Category state ──  // NEW
  String? _categoryId; // NEW
  String? _subcategoryId; // NEW

  // ───── Lifecycle ─────
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    initializeBaseDefaults(); // NEW: ensure lates are set
    _attachFormListeners();
    recomputeValidity();
  }

  @mustCallSuper
  @override
  void dispose() {
    _isDisposed = true; // 👈 mark first so any late calls bail out
    _detachFormListeners();
    canSubmit.dispose();

    // Keep the deferred disposal (safe for child teardown order)
    final title = _titleController;
    final desc = _descriptionController;
    final note = _noteController;
    final loc = _locationController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If something (hot reload / double-dispose) already disposed one of them,
      // swallow silently — TextEditingController.dispose() is idempotent in practice.
      try {
        title.dispose();
      } catch (_) {}
      try {
        desc.dispose();
      } catch (_) {}
      try {
        note.dispose();
      } catch (_) {}
      try {
        loc.dispose();
      } catch (_) {}
    });

    super.dispose();
  }



  // ───── Initialization ─────
  @mustCallSuper
  void initializeBaseDefaults() {
    _selectedEventColor = ColorManager.eventColors.last;
    _selectedStartDate = DateTime.now();
    _selectedEndDate = _selectedStartDate.add(const Duration(hours: 1));
    _recurrenceRule = null;
    _isRepetitive = false;
    _users = [];
    _selectedUsers = [];
    _categoryId = null; // NEW
    _subcategoryId = null; // NEW
    recomputeValidity();
  }

  void _attachFormListeners() {
    _titleController.addListener(recomputeValidity);
    _locationController.addListener(recomputeValidity);
    _descriptionController.addListener(recomputeValidity);
    _noteController.addListener(recomputeValidity);
  }

  void _detachFormListeners() {
    // NEW
    _titleController.removeListener(recomputeValidity);
    _locationController.removeListener(recomputeValidity);
    _descriptionController.removeListener(recomputeValidity);
    _noteController.removeListener(recomputeValidity);
  }

  // ───── Controller access ─────
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get noteController => _noteController;
  TextEditingController get locationController => _locationController;

  // ───── State access ─────
  int? get selectedEventColor => _selectedEventColor.value;
  List<int> get colorList =>
      ColorManager.eventColors.map((c) => c.value).toList();

  DateTime get selectedStartDate => _selectedStartDate;
  DateTime get selectedEndDate => _selectedEndDate;

  LegacyRecurrenceRule? get recurrenceRule => _recurrenceRule;
  bool get isRepetitive => _isRepetitive;

  double get toggleWidth => _toggleWidth;

  List<User> get users => _users;
  List<User> get selectedUsers => _selectedUsers;

  // Category getters  // NEW
  String? get categoryId => _categoryId; // NEW
  String? get subcategoryId => _subcategoryId; // NEW

  // ───── Mutators ─────
  void setSelectedColor(int colorValue) {
    _selectedEventColor = Color(colorValue);
    if (mounted) setState(() {});
    recomputeValidity();
  }

  void toggleRepetition(bool value, LegacyRecurrenceRule? rule) {
    _isRepetitive = value;
    _recurrenceRule = value ? rule : null;
    if (mounted) setState(() {});
    recomputeValidity();
  }

  void setRecurrenceRule(LegacyRecurrenceRule? rule) {
    _recurrenceRule = rule;
    _isRepetitive = rule != null ? true : _isRepetitive;
    if (mounted) setState(() {});
    recomputeValidity();
  }

  void setSelectedUsers(List<User> users) {
    _selectedUsers = users;
    if (mounted) setState(() {});
    recomputeValidity();
  }

  // Category setters  // NEW
  set categoryId(String? v) {
    // NEW
    _categoryId = v;
    if (mounted) setState(() {});
    recomputeValidity();
  }

  set subcategoryId(String? v) {
    // NEW
    _subcategoryId = v;
    if (mounted) setState(() {});
    recomputeValidity();
  }

  void setStartDate(DateTime dt) => setState(() {
        _selectedStartDate = dt;
        if (_selectedEndDate.isBefore(dt)) {
          _selectedEndDate = dt.add(const Duration(hours: 1));
        }
        recomputeValidity();
      });

  void setEndDate(DateTime dt) => setState(() {
        _selectedEndDate = dt;
        recomputeValidity();
      });

  Future<void> selectDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? _selectedStartDate : _selectedEndDate,
        ),
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        isStart ? setStartDate(combined) : setEndDate(combined);
      }
    }
  }

  void disposeBaseControllers() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _locationController.dispose();
  }

  /// Implemented by subclasses (Add flow)
  Future<bool> addEvent(BuildContext context);

  void setReminderMinutes(int minutes) {
    _reminderMinutes = minutes;
    recomputeValidity();
  }

  int get reminderMinutes => _reminderMinutes;

  // ───── Validation ─────
  // @protected
  // bool isFormValid() {
  //   final titleOk = titleController.text.trim().isNotEmpty;
  //   final datesOk = selectedStartDate.isBefore(selectedEndDate) ||
  //       selectedStartDate.isAtSameMomentAs(selectedEndDate);

  //   // If you want to make category mandatory, uncomment:
  //   // final categoryOk = _categoryId != null;
  //   // return titleOk && datesOk && categoryOk;

  //   return titleOk && datesOk;
  // }

  // @protected
  // @mustCallSuper
  // void recomputeValidity() {
  //   canSubmit.value = isFormValid();
  // }

  @protected
  bool isFormValid() {
    // 👉 If we’re tearing down, do NOT touch controllers.
    if (_isDisposed) return false;

    final titleOk = _titleController.text.trim().isNotEmpty;
    final datesOk = _selectedStartDate.isBefore(_selectedEndDate) ||
        _selectedStartDate.isAtSameMomentAs(_selectedEndDate);

    return titleOk && datesOk;
  }

  @protected
  @mustCallSuper
  void recomputeValidity() {
    if (_isDisposed) return; // 👈 bail if tearing down
    canSubmit.value = isFormValid();
  }

  bool canSubmitNow() => isFormValid();
}
