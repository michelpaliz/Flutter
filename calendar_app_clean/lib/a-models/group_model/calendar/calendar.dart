import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';

class Calendar {
  String _id;
  String _name;
  List<Event> _events;

  Calendar(this._id, this._name, {List<Event>? events})
      : _events = events ?? [];

  String get id => _id;

  String get name => _name;
  set name(String name) {
    _name = name;
  }

  List<Event> get events => _events;
  set events(List<Event> events) {
    _events = events;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id, // Use Mongo's preferred field if needed
      'name': _name,
      'events': _events.map((event) => event.toMap()).toList(),
    };
  }

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      json['_id'] ?? json['id'] ?? '', // ✅ supports both cases
      json['name'],
      events: (json['events'] as List<dynamic>?)
          ?.map((eventJson) => Event.fromJson(eventJson))
          .toList(),
    );
  }

  static Calendar defaultCalendar() {
    return Calendar(
      'default_calendar_id',
      'Default Calendar Name',
      events: [],
    );
  }

  @override
  String toString() {
    return 'Calendar{id: $_id, name: $_name, events: $_events}';
  }
}
