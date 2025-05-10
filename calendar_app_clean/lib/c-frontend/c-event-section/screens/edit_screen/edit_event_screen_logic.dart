part of 'edit_event_screen.dart';

class _EditEventScreenState extends State<EditEventScreen> {
  // Logic variables
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late Event _event;
  List<User> _users = [];
  User? _selectedUser;
  late Group _group;
  late bool _isRepetitive;
  bool? isAllDay = false;
  late RecurrenceRule? _recurrenceRule;
  late Color _selectedEventColor;
  late List<Color> _colorList;
  late String _informativeText;
  String? _currentUserName;
  late List<String> _recipients;
  late List<UpdateInfo> _updateInfo;

  // Services
  final UserService _userService = UserService();
  late EventService _eventService;
  late UserManagement _userManagement;
  late GroupManagement _groupManagement;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  late TextEditingController _locationController;

  final double _toggleWidth = 50.0;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _titleController = TextEditingController(text: _event.title);
    _noteController = TextEditingController(text: _event.note);
    _descriptionController =
        TextEditingController(text: _event.description ?? '');
    _locationController =
        TextEditingController(text: _event.localization ?? '');
    _recurrenceRule = _event.recurrenceRule;
    _isRepetitive = _event.recurrenceRule != null;
    _colorList = ColorManager.eventColors;
    _selectedEventColor = _colorList[_event.eventColorIndex];
    _eventService = EventService();
    _recipients = _event.recipients;
    _informativeText = _event.updateHistory.first.userId;
    _updateInfo = _event.updateHistory;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userManagement = Provider.of<UserManagement>(context);
    _groupManagement = Provider.of<GroupManagement>(context);
    _event = ModalRoute.of(context)!.settings.arguments as Event;
    _noteController.text = _event.note ?? '';
    _selectedStartDate = _event.startDate;
    _selectedEndDate = _event.endDate;
    _descriptionController.text = _event.description!;
    _locationController.text = _event.localization!;
    _recurrenceRule = _event.recurrenceRule;
    _isRepetitive = _event.recurrenceRule != null;
    _group = _groupManagement.currentGroup!;
    _currentUserName = _userManagement.user?.name;
    fetchUserData(context, _group, _userService, _event.recipients, _users,
        (user) {
      setState(() {
        _selectedUser = user;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.event),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventColorDropdown(
              selectedColor: _selectedEventColor,
              colorList: _colorList,
              onColorSelected: (color) =>
                  setState(() => _selectedEventColor = color),
            ),
            TitleInput(controller: _titleController),
            const SizedBox(height: 10),
            DatePickerRow(
              selectedStartDate: _selectedStartDate,
              selectedEndDate: _selectedEndDate,
              onDateSelected: (isStart, newDate) {
                setState(() {
                  if (isStart) {
                    _selectedStartDate = newDate;
                  } else {
                    _selectedEndDate = newDate;
                  }
                });
              },
              selectDateFn: (ctx, isStart) => selectDate(
                  ctx, isStart, _selectedStartDate, _selectedEndDate),
            ),
            const SizedBox(height: 10),
            LocationInput(controller: _locationController),
            UserDropdown(
              users: _users,
              selectedUser: _selectedUser,
              onUserSelected: (user) => setState(() => _selectedUser = user),
            ),
            const SizedBox(height: 10),
            DescriptionInput(controller: _descriptionController),
            NoteInput(controller: _noteController),
            const SizedBox(height: 20),
            RepetitionToggle(
              isRepetitive: _isRepetitive,
              toggleWidth: _toggleWidth,
              startDate: _selectedStartDate,
              endDate: _selectedEndDate,
              initialRule: _recurrenceRule,
              onToggleChanged: (repetitive, rule) {
                setState(() {
                  _isRepetitive = repetitive;
                  _recurrenceRule = rule;
                });
              },
            ),
            const SizedBox(height: 25),
            SaveButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  saveEditedEvent(
                    context: context,
                    eventService: _eventService,
                    updatedData: _buildUpdatedEvent(),
                    eventList: _group.calendar.events,
                    group: _group,
                    groupManagement: _groupManagement,
                    currentUserName: _currentUserName,
                    startDateChanged: _event.startDate != _selectedStartDate,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Event _buildUpdatedEvent() {
    String extractedLocation =
        _locationController.text.replaceAll(RegExp(r'[┤├]'), '');
    return Event(
      id: _event.id,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      title: _titleController.text,
      groupId: _event.groupId,
      description: _descriptionController.text,
      note: _noteController.text,
      localization: extractedLocation,
      recurrenceRule: _recurrenceRule,
      eventColorIndex: ColorManager().getColorIndex(_selectedEventColor),
      recipients: _recipients,
      updateHistory: _updateInfo,
      ownerId: _event.ownerId,
    );
  }
}
