import 'dart:html';

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

  // Event event1 = Event(date: DateTime(2023, 6, 1), note: 'Event 1');
  // Event event2 = Event(date: DateTime(2023, 6, 15), note: 'Event 2');

  // List<Event> events = [event1, event2];

  // Person person = Person('John Doe', 'johndoe@example.com', events);

  // print(person.name);    // Output: John Doe
  // print(person.email);   // Output: johndoe@example.com
  // print(person.events);  // Output: [Instance of 'Event', Instance of 'Event']
// }
}
