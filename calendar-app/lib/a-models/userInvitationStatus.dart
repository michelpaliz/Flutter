class UserInviteStatus {
  String id;
  bool? _invitationAnswer;
  String role;
  DateTime sendingDate;
  String informationStatus;
  int attempts;
  String status;

  UserInviteStatus({
    required this.id,
    bool? invitationAnswer,
    required this.role,
    required this.sendingDate,
    this.attempts = 1,
  })  : _invitationAnswer = invitationAnswer,
        informationStatus =
            _computeInformationStatus(invitationAnswer, sendingDate),
        status = _computeStatus(invitationAnswer, sendingDate);

  bool? get invitationAnswer => _invitationAnswer;

  set invitationAnswer(bool? value) {
    _invitationAnswer = value;
    informationStatus = _computeInformationStatus(value, sendingDate);
    status = _computeStatus(value, sendingDate);
  }

  static String _computeInformationStatus(
      bool? accepted, DateTime sendingDate) {
    if (accepted == true) {
      return 'Accepted';
    } else if (accepted == false) {
      return 'Not Accepted';
    } else if (DateTime.now().difference(sendingDate).inDays > 5) {
      return 'Expired';
    } else {
      return 'Pending';
    }
  }

  static String _computeStatus(bool? accepted, DateTime sendingDate) {
    if (accepted == true) {
      return 'Resolved';
    } else if (accepted == false) {
      return 'Resolved';
    } else if (DateTime.now().difference(sendingDate).inDays > 5) {
      return 'Resolved';
    } else {
      return 'Unresolved';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitationAnswer': _invitationAnswer,
      'role': role,
      'sendingDate': sendingDate.toIso8601String(),
      'informationStatus': informationStatus,
      'attempts': attempts,
      'status': status,
    };
  }

  factory UserInviteStatus.fromJson(Map<String, dynamic> json) {
    DateTime sendingDate = DateTime.parse(json['sendingDate']);
    bool? accepted = json['invitationAnswer'];
    int attempts = json['attempts'];
    return UserInviteStatus(
      id: json['id'],
      invitationAnswer: accepted,
      role: json['role'],
      sendingDate: sendingDate,
      attempts: attempts,
    );
  }

  // Method to create a deep copy of UserInviteStatus
  UserInviteStatus copy() {
    return UserInviteStatus(
      id: this.id,
      role: this.role,
      attempts: this.attempts,
      sendingDate: DateTime.fromMillisecondsSinceEpoch(
          this.sendingDate.millisecondsSinceEpoch),
      invitationAnswer: this.invitationAnswer,
    );
  }

  bool isEqual(UserInviteStatus other) {
    return id == other.id &&
        _invitationAnswer == other._invitationAnswer &&
        role == other.role &&
        sendingDate == other.sendingDate &&
        informationStatus == other.informationStatus &&
        attempts == other.attempts &&
        status == other.status;
  }

  // New method to convert a string into a UserInviteStatus object
  static UserInviteStatus fromString(String statusString) {
    switch (statusString) {
      case 'Pending':
        return UserInviteStatus(
          id: 'default_id', // Default values
          role: 'default_role',
          sendingDate: DateTime.now(),
          invitationAnswer: null,
        );
      case 'Accepted':
        return UserInviteStatus(
          id: 'default_id',
          role: 'default_role',
          sendingDate: DateTime.now(),
          invitationAnswer: true,
        );
      case 'Not Accepted':
        return UserInviteStatus(
          id: 'default_id',
          role: 'default_role',
          sendingDate: DateTime.now(),
          invitationAnswer: false,
        );
      case 'Expired':
        return UserInviteStatus(
          id: 'default_id',
          role: 'default_role',
          sendingDate: DateTime.now()
              .subtract(Duration(days: 10)), // Simulate expired date
          invitationAnswer: null,
        );
      default:
        throw ArgumentError('Unknown status: $statusString');
    }
  }

  @override
  String toString() {
    return 'UserInviteStatus{id: $id, invitationAnswer: $invitationAnswer, role: $role, sendingDate: $sendingDate, informationStatus: $informationStatus, attempts: $attempts, status: $status}';
  }
}
