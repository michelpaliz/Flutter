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
        throw ArgumentError('Invalid dayString: $dayString');
    }
  }
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
