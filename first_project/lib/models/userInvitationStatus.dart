class UserInviteStatus {
  String id;
  bool? accepted;
  String role;

  UserInviteStatus({
    required this.id,
    this.accepted,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accepted': accepted,
      'role': role,
    };
  }

  factory UserInviteStatus.fromJson(Map<String, dynamic> json) {
    return UserInviteStatus(
      id: json['id'],
      accepted: json['accepted'],
      role: json['role'],
    );
  }

}
