/// Returns true if the user can edit or delete events.
bool canEdit(String userRole) {
  return userRole == 'Administrator' || userRole == 'Co-Administrator';
}