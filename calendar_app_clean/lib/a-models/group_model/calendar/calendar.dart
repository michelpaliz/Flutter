class Calendar {
  String _id;
  String _name;
  List<String> _eventIds;

  Calendar(this._id, this._name, {List<String>? eventIds})
      : _eventIds = eventIds ?? [];

  String get id => _id;
  String get name => _name;
  set name(String name) => _name = name;

  List<String> get eventIds => _eventIds;
  set eventIds(List<String> ids) => _eventIds = ids;

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': _name,
      'eventIds': _eventIds,
    };
  }

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      json['_id'] ?? json['id'] ?? '',
      json['name'],
      eventIds: List<String>.from(json['eventIds'] ?? []),
    );
  }

  static Calendar defaultCalendar() {
    return Calendar('default_calendar_id', 'Default Calendar Name');
  }

  @override
  String toString() {
    return 'Calendar{id: $_id, name: $_name, eventIds: $_eventIds}';
  }
}
