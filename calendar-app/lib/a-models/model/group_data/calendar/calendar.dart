import 'package:first_project/a-models/model/group_data/event-appointment/event/event.dart';

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
      'id': _id,
      'name': _name,
      'events': _events.map((event) => event.toMap()).toList(),
    };
  }

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      json['id'],
      json['name'],
      events: (json['events'] as List<dynamic>?)
          ?.map((eventJson) => Event.fromJson(eventJson))
          .toList(),
    );
  }

  static createDefaultCalendar() {
    return Calendar(
      'default_calendar_id', // Default ID
      'Default Calendar Name', // Default Name
      events: [], // Default empty list of events
    );
  }

  @override
  String toString() {
    return 'Calendar{id: $_id, name: $_name, events: $_events}';
  }
}
