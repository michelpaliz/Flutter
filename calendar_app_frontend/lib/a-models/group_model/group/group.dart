import 'package:hexora/a-models/group_model/calendar/calendar.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';

class Group {
  // Core
  final String id;
  String name;
  final String ownerId;
  final Map<String, String> userRoles; // username -> role
  List<String> userIds;
  DateTime createdTime;
  String description;

  // Images (match backend defaults: nullable)
  String? photoUrl; // public/CDN url (if AVATARS_PUBLIC) – may be null
  String? photoBlobName; // blob path
  String? computedPhotoUrl; // backend virtual; may be present

  // Invites
  Map<String, UserInviteStatus>? invitedUsers;

  // Calendar linkage (no embedded calendar doc)
  String? defaultCalendarId; // set by backend
  Calendar? defaultCalendar; // optional snapshot from GET /groups/:id

  Group({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.userRoles,
    required this.userIds,
    required this.createdTime,
    required this.description,
    this.photoUrl,
    this.photoBlobName,
    this.computedPhotoUrl,
    this.invitedUsers,
    this.defaultCalendarId,
    this.defaultCalendar,
  });

  // ---------- JSON ----------
  factory Group.fromJson(Map<String, dynamic> json) {
    final userIds = (json['userIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    // invitedUsers: username -> UserInviteStatus
    final invitedUsersJson =
        (json['invitedUsers'] as Map<String, dynamic>?) ?? {};
    final invitedUsers = invitedUsersJson.map(
      (k, v) => MapEntry(k, UserInviteStatus.fromJson(v)),
    );

    // optional calendar snapshot
    Calendar? defaultCal;
    if (json['defaultCalendar'] != null &&
        json['defaultCalendar'] is Map<String, dynamic>) {
      defaultCal = Calendar.fromJson(json['defaultCalendar']);
    }

    return Group(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      userRoles: Map<String, String>.from(json['userRoles'] ?? {}),
      userIds: userIds,
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'].toString())
          : DateTime.now(),
      description: (json['description'] ?? '').toString(),
      photoUrl: json['photoUrl']?.toString(),
      photoBlobName: json['photoBlobName']?.toString(),
      computedPhotoUrl: json['computedPhotoUrl']?.toString(),
      invitedUsers: invitedUsers,
      defaultCalendarId: json['defaultCalendarId']?.toString(),
      defaultCalendar: defaultCal,
    );
  }

  /// For updates (match backend whitelist: name, description, photoBlobName,
  /// photoUrl (legacy), userRoles, userIds, invitedUsers)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (photoBlobName != null) 'photoBlobName': photoBlobName,
      'userRoles': userRoles,
      'userIds': userIds,
      if (invitedUsers != null)
        'invitedUsers': invitedUsers!.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
    };
  }

  /// For creation (no calendar fields; backend creates calendar & sets defaultCalendarId)
  Map<String, dynamic> toJsonForCreation() {
    return {
      'name': name,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'userIds': userIds,
      'description': description,
      // createdTime is optional on backend, but safe to send if you want:
      'createdTime': createdTime.toIso8601String(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (photoBlobName != null) 'photoBlobName': photoBlobName,
      if (invitedUsers != null)
        'invitedUsers': invitedUsers!.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
    };
  }

  // ---------- Copy ----------
  Group copyWith({
    String? id,
    String? name,
    String? ownerId,
    Map<String, String>? userRoles,
    List<String>? userIds,
    DateTime? createdTime,
    String? description,
    String? photoUrl,
    String? photoBlobName,
    String? computedPhotoUrl,
    Map<String, UserInviteStatus>? invitedUsers,
    String? defaultCalendarId,
    Calendar? defaultCalendar,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      userRoles: userRoles ?? Map<String, String>.from(this.userRoles),
      userIds: userIds ?? List<String>.from(this.userIds),
      createdTime: createdTime ?? this.createdTime,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      photoBlobName: photoBlobName ?? this.photoBlobName,
      computedPhotoUrl: computedPhotoUrl ?? this.computedPhotoUrl,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      defaultCalendarId: defaultCalendarId ?? this.defaultCalendarId,
      defaultCalendar: defaultCalendar ?? this.defaultCalendar,
    );
  }

  // ---------- Helpers ----------
  bool isEqual(Group other) {
    final calEqual =
        (defaultCalendar == null && other.defaultCalendar == null) ||
            (defaultCalendar != null &&
                other.defaultCalendar != null &&
                defaultCalendar!.toJson().toString() ==
                    other.defaultCalendar!.toJson().toString());

    return id == other.id &&
        name == other.name &&
        ownerId == other.ownerId &&
        userRoles.toString() == other.userRoles.toString() &&
        _listEq(userIds, other.userIds) &&
        createdTime == other.createdTime &&
        description == other.description &&
        photoUrl == other.photoUrl &&
        photoBlobName == other.photoBlobName &&
        computedPhotoUrl == other.computedPhotoUrl &&
        defaultCalendarId == other.defaultCalendarId &&
        calEqual &&
        _invitesEq(invitedUsers, other.invitedUsers);
  }

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _invitesEq(
    Map<String, UserInviteStatus>? m1,
    Map<String, UserInviteStatus>? m2,
  ) {
    if (m1 == null && m2 == null) return true;
    if (m1 == null || m2 == null) return false;
    if (m1.length != m2.length) return false;
    for (final k in m1.keys) {
      if (!m2.containsKey(k) || !m1[k]!.isEqual(m2[k]!)) return false;
    }
    return true;
  }

  // ---------- Defaults ----------
  static Group createDefaultGroup() {
    return Group(
      id: 'default_id',
      name: 'Default Group Name',
      ownerId: 'default_owner_id',
      userRoles: const {},
      userIds: const [],
      createdTime: DateTime.now(),
      description: 'Default Description',
      photoUrl: null,
      photoBlobName: null,
      computedPhotoUrl: null,
      invitedUsers: {},
      defaultCalendarId: null,
      defaultCalendar: null,
    );
  }

  @override
  String toString() {
    return 'Group{id: $id, name: $name, ownerId: $ownerId, userRoles: $userRoles, '
        'userIds: $userIds, createdTime: $createdTime, description: $description, '
        'photoUrl: $photoUrl, photoBlobName: $photoBlobName, computedPhotoUrl: $computedPhotoUrl, '
        'defaultCalendarId: $defaultCalendarId, defaultCalendar: $defaultCalendar, '
        'invitedUsers: $invitedUsers}';
  }
}

extension GroupCalendarX on Group {
  /// Primary way to get the calendar id for this group.
  String? get calendarId =>
      (defaultCalendarId != null && defaultCalendarId!.isNotEmpty)
          ? defaultCalendarId
          : defaultCalendar?.id;

  bool get hasCalendar => calendarId != null;
}
