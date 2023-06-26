
class Group {
  final String id;
  final String groupName;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles

  Group({
    required this.id,
    required this.groupName,
    required this.ownerId,
    required this.userRoles,
  });
}
