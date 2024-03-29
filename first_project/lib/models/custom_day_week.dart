class CustomDayOfWeek {
  final String name;
  final int order;

  CustomDayOfWeek(this.name, this.order);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomDayOfWeek &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          order == other.order;

  @override
  int get hashCode => name.hashCode ^ order.hashCode;

  @override
  String toString() {
    return name;
  }

  factory CustomDayOfWeek.fromString(String dayString) {
    switch (dayString.toLowerCase()) {
      case 'monday':
        return customDaysOfWeek[0];
      case 'tuesday':
        return customDaysOfWeek[1];
      case 'wednesday':
        return customDaysOfWeek[2];
      case 'thursday':
        return customDaysOfWeek[3];
      case 'friday':
        return customDaysOfWeek[4];
      case 'saturday':
        return customDaysOfWeek[5];
      case 'sunday':
        return customDaysOfWeek[6];
      default:
        if (dayString.length == 2) {
          // Check for two-letter abbreviations
          switch (dayString.toLowerCase()) {
            case 'mo':
              return customDaysOfWeek[0];
            case 'tu':
              return customDaysOfWeek[1];
            case 'we':
              return customDaysOfWeek[2];
            case 'th':
              return customDaysOfWeek[3];
            case 'fr':
              return customDaysOfWeek[4];
            case 'sa':
              return customDaysOfWeek[5];
            case 'su':
              return customDaysOfWeek[6];
            default:
              throw ArgumentError('Invalid dayString: $dayString');
          }
        }
        throw ArgumentError('Invalid dayString: $dayString');
    }
  }

  static String getPattern(String dayString) {
    switch (dayString.toLowerCase()) {
      case 'monday':
        return 'MO';
      case 'tuesday':
        return 'TU';
      case 'wednesday':
        return 'WE';
      case 'thursday':
        return 'TH';
      case 'friday':
        return 'FR';
      case 'saturday':
        return 'SA';
      case 'sunday':
        return 'SU';
      default:
        throw ArgumentError('Invalid dayString: $dayString');
    }
  }

// Define a mapping from abbreviations to DateTime objects
  static Map<String, int> abbreviationToDateTime = {
    'MO': DateTime.monday,
    'TU': DateTime.tuesday,
    'WE': DateTime.wednesday,
    'TH': DateTime.thursday,
    'FR': DateTime.friday,
    'SA': DateTime.saturday,
    'SU': DateTime.sunday,
  };
}

final customDaysOfWeek = [
  CustomDayOfWeek('Monday', 1),
  CustomDayOfWeek('Tuesday', 2),
  CustomDayOfWeek('Wednesday', 3),
  CustomDayOfWeek('Thursday', 4),
  CustomDayOfWeek('Friday', 5),
  CustomDayOfWeek('Saturday', 6),
  CustomDayOfWeek('Sunday', 7),
];
