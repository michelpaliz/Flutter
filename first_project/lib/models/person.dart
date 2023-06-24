import 'package:first_project/models/event.dart';

class Person {
  String _name;
  final String _email;
  List<Event>? _events;

  Person(this._name, this._email, this._events);

  get name => _name;
  set name(name) {
    _name = name;
  }

  get email => _email;

  get events => _events;
  set events(events) {
    _events = events;
  }

  Map<String, dynamic> toMap() {
    return {'name': _name, 'email': _email, 'events': _events};
  }
}
