class User {
  String _id;
  String _name;
  final String _email;
  String? _photoUrl;
  String _userName;
  List<String> _eventsIds;
  List<String> _groupIds;
  List<String>? _calendarsIds;
  List<String>? _notificationsIds;

  User({
    required String id,
    required String name,
    required String email,
    required String userName,
    required List<String> events,
    required List<String> groupIds,
    String? photoUrl,
    List<String>? sharedCalendars,
    List<String>? notifications,
  })  : _id = id,
        _name = name,
        _email = email,
        _userName = userName,
        _eventsIds = events,
        _groupIds = groupIds,
        _photoUrl = photoUrl,
        _calendarsIds = sharedCalendars,
        _notificationsIds = notifications;

  // Getters & Setters
  String get id => _id;
  String get name => _name;
  set name(String name) => _name = name;

  String get email => _email;

  List<String> get events => _eventsIds;
  set events(List<String> events) => _eventsIds = events;

  List<String> get groupIds => _groupIds;
  set groupIds(List<String> groupIds) => _groupIds = groupIds;

  String? get photoUrl => _photoUrl;
  set photoUrl(String? photoUrl) => _photoUrl = photoUrl;

  List<String>? get sharedCalendars => _calendarsIds;
  set sharedCalendars(List<String>? sharedCalendars) =>
      _calendarsIds = sharedCalendars;

  List<String>? get notifications => _notificationsIds;
  set notifications(List<String>? notifications) =>
      _notificationsIds = notifications;

  String get userName => _userName;
  set userName(String userName) => _userName = userName;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'userName': _userName,
      'email': _email,
      'photoUrl': _photoUrl,
      'events': _eventsIds,
      'groupIds': _groupIds,
      'sharedCalendars': _calendarsIds,
      'notifications': _notificationsIds,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userName: json['userName'] as String,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      groupIds: (json['groupIds'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
      photoUrl: json['photoUrl'] as String?,
      sharedCalendars: (json['sharedCalendars'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList(),
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((n) => n.toString())
          .toList(),
    );
  }

  // ✅ Add copyWith
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? userName,
    List<String>? events,
    List<String>? groupIds,
    List<String>? sharedCalendars,
    List<String>? notifications,
  }) {
    return User(
      id: id ?? _id,
      name: name ?? _name,
      email: email ?? _email,
      userName: userName ?? _userName,
      photoUrl: photoUrl ?? _photoUrl,
      events: events ?? _eventsIds,
      groupIds: groupIds ?? _groupIds,
      sharedCalendars: sharedCalendars ?? _calendarsIds,
      notifications: notifications ?? _notificationsIds,
    );
  }

  // ✅ Add empty factory
  factory User.empty() {
    return User(
      id: '',
      name: '',
      email: '',
      userName: '',
      photoUrl: '',
      events: [],
      groupIds: [],
      sharedCalendars: [],
      notifications: [],
    );
  }
}
