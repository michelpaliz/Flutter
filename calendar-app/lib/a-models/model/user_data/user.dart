class User {
  String _id;
  String _authID;
  String _name;
  final String _email;
  String? _photoUrl;  // Nullable
  String _userName;
  List<String> _eventsIds;
  List<String> _groupIds;
  List<String>? _calendarsIds;  // Nullable
  List<String>? _notificationsIds;  // Nullable

  User({
    required String id,
    required String authID,
    required String name,
    required String email,
    required String userName,
    required List<String> events,
    required List<String> groupIds,
    String? photoUrl,  // Nullable in constructor
    List<String>? sharedCalendars,  // Nullable in constructor
    List<String>? notifications,  // Nullable in constructor
  })  : _id = id,
        _name = name,
        _authID = authID,
        _email = email,
        _userName = userName,
        _eventsIds = events,
        _groupIds = groupIds,
        _photoUrl = photoUrl,  // Initialize nullable field
        _calendarsIds = sharedCalendars,  // Initialize nullable field
        _notificationsIds = notifications;  // Initialize nullable field

  // Getters and setters
  String get id => _id;
  String get authId => _authID;
  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String get email => _email;

  List<String> get events => _eventsIds;
  set events(List<String> events) {
    _eventsIds = events;
  }

  List<String> get groupIds => _groupIds;
  set groupIds(List<String> groupIds) {
    _groupIds = groupIds;
  }

  String? get photoUrl => _photoUrl;  // Getter for nullable field
  set photoUrl(String? photoUrl) {
    _photoUrl = photoUrl;
  }

  List<String>? get sharedCalendars => _calendarsIds;  // Nullable getter
  set sharedCalendars(List<String>? sharedCalendars) {
    _calendarsIds = sharedCalendars;
  }

  List<String>? get notifications => _notificationsIds;  // Nullable getter
  set notifications(List<String>? notifications){
    _notificationsIds = notifications;
  }

  String get userName => _userName;
  set userName(String userName) {
    _userName = userName;
  }

Map<String, dynamic> toJson() {
  return {
    'id': _id,
    'name': _name,
    'authID': _authID,
    'userName': _userName,
    'email': _email,
    'photoUrl': _photoUrl,  // Nullable field
    'events': _eventsIds,  // List of event IDs (strings), no need for toMap()
    'groupIds': _groupIds,
    'sharedCalendars': _calendarsIds,  // Nullable field, List<String>
    'notifications': _notificationsIds,  // Nullable field, List<String>
  };
}


factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    authID: json['authID'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    userName: json['userName'] as String,
    events: (json['events'] as List<dynamic>?)
        ?.map((eventId) => eventId.toString())
        .toList() ?? [],  // Default to an empty list if null
    groupIds: (json['groupIds'] as List<dynamic>?)
        ?.map((groupId) => groupId.toString())
        .toList() ?? [],  // Default to an empty list if null
    photoUrl: json['photoUrl'] as String?,  // Nullable field
    sharedCalendars: (json['sharedCalendars'] as List<dynamic>?)
        ?.map((calendarId) => calendarId.toString())
        .toList(),  // Nullable field
    notifications: (json['notifications'] as List<dynamic>?)
        ?.map((notificationId) => notificationId.toString())
        .toList(),  // Nullable field
  );
}

}

