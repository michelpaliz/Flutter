class UserInviteStatus {
  String id;
  bool? invitationAnswer;
  String role;
  DateTime sendingDate;
  String informationStatus;
  int attempts;
  String status;

  UserInviteStatus({
    required this.id,
    required this.invitationAnswer,
    required this.role,
    required this.sendingDate,
    required this.informationStatus,
    required this.attempts,
    required this.status,
  });

  factory UserInviteStatus.fromJson(Map<String, dynamic> json) {
    return UserInviteStatus(
      id: json['id'],
      invitationAnswer: json['invitationAnswer'],
      role: json['role'],
      sendingDate: DateTime.parse(json['sendingDate']),
      informationStatus:
          json['informationStatus'] ?? 'Pending', // fallback just in case
      attempts: json['attempts'] ?? 1,
      status: json['status'] ?? 'Unresolved',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitationAnswer': invitationAnswer,
      'role': role,
      'sendingDate': sendingDate.toIso8601String(),
      'informationStatus': informationStatus,
      'attempts': attempts,
      'status': status,
    };
  }

  UserInviteStatus copy() {
    return UserInviteStatus(
      id: id,
      invitationAnswer: invitationAnswer,
      role: role,
      sendingDate: DateTime.fromMillisecondsSinceEpoch(
          sendingDate.millisecondsSinceEpoch),
      informationStatus: informationStatus,
      attempts: attempts,
      status: status,
    );
  }

  bool isEqual(UserInviteStatus other) {
    return id == other.id &&
        invitationAnswer == other.invitationAnswer &&
        role == other.role &&
        sendingDate == other.sendingDate &&
        informationStatus == other.informationStatus &&
        attempts == other.attempts &&
        status == other.status;
  }

  @override
  String toString() {
    return 'UserInviteStatus{id: $id, invitationAnswer: $invitationAnswer, role: $role, sendingDate: $sendingDate, informationStatus: $informationStatus, attempts: $attempts, status: $status}';
  }
}
