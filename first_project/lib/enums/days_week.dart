enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

// Define a static map within the enum class
extension DayOfWeekExtension on DayOfWeek {
  static final Map<DayOfWeek, String> _dayNames = {
    DayOfWeek.sunday: 'Sunday',
    DayOfWeek.monday: 'Monday',
    DayOfWeek.tuesday: 'Tuesday',
    DayOfWeek.wednesday: 'Wednesday',
    DayOfWeek.thursday: 'Thursday',
    DayOfWeek.friday: 'Friday',
    DayOfWeek.saturday: 'Saturday',
  };

  String get displayName => _dayNames[this] ?? '';
}
