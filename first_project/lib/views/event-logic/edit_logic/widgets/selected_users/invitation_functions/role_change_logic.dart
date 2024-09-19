import 'package:first_project/models/userInvitationStatus.dart';

class RoleChangeLogic {
  static bool shouldUpdateInvitation(UserInviteStatus? userInviteStatus) {
    // Logic to check if the invitation needs an update
    return userInviteStatus != null && userInviteStatus.invitationAnswer == false;
  }

  static void updateInvitationStatus(
    String userName,
    Map<String, UserInviteStatus> usersInvitations,
    Map<String, UserInviteStatus> usersInvitationAtFirst,
  ) {
    if (usersInvitations.containsKey(userName)) {
      // Create a copy of the original UserInviteStatus object
      UserInviteStatus originalStatus = usersInvitations[userName]!;
      UserInviteStatus updatedStatus = UserInviteStatus(
        id: originalStatus.id,
        role: originalStatus.role,
        attempts: originalStatus.attempts + 1,
        sendingDate: DateTime.now(),
        invitationAnswer: null, // Reset to pending
      );

      // Update the secondary map or state with the modified copy
      usersInvitationAtFirst[userName] = updatedStatus;
    }
  }
}
