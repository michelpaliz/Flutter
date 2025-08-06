// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get groups => 'Groups';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Log out';

  @override
  String get groupData => 'Group Data';

  @override
  String get notifications => 'Notifications';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get language => 'en';

  @override
  String get changeView => 'Change the view';

  @override
  String welcomeGroupView(Object username) {
    return 'Welcome $username here you can see the list of groups that you are part of.';
  }

  @override
  String get zeroNotifications => 'No notifications available';

  @override
  String get goToCalendar => 'Go to the calendar';

  @override
  String groupName(int maxChar) {
    return 'Group name (max $maxChar characters)  ';
  }

  @override
  String groupDescription(int maxChar) {
    return 'Group description (max $maxChar characters)  ';
  }

  @override
  String get addPplGroup => 'Add people to your group';

  @override
  String get addUser => 'Add user';

  @override
  String get addEvent => 'Add event';

  @override
  String get administrator => 'Administrator';

  @override
  String get coAdministrator => 'Co-Administrator';

  @override
  String get member => 'Member';

  @override
  String get saveGroup => 'Save the group';

  @override
  String get addImageGroup => 'Add image for the group';

  @override
  String get removeEvent => 'Are you sure you want to remove this event ?';

  @override
  String get removeGroup => 'Are you sure you want to remove this group ?';

  @override
  String get removeCalendar =>
      'Are you sure you want to remove this calendar ?';

  @override
  String get groupCreated => 'Group created successfully!';

  @override
  String get failedToCreateGroup => 'Failed to create the group';

  @override
  String get eventCreated => 'The event has been created';

  @override
  String get eventEdited => 'The event has been edited';

  @override
  String get eventAddedGroup => 'The event has been added to the group';

  @override
  String get event => 'Event';

  @override
  String get chooseEventColor => 'Choose the color of the event:';

  @override
  String get errorEventNote => 'Event note cannot be empty!';

  @override
  String get name => 'Name';

  @override
  String get userName => 'User name';

  @override
  String get currentPassword => 'Insert your current password';

  @override
  String get newPassword => 'Update your current password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get password => 'Password';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get userNameHint => 'Enter your username (e.g., john_doe123)';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get emailHint => 'Introduce your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordHint => 'Enter your password again';

  @override
  String get logoutMessage => 'Are you sure you want to log out ?';

  @override
  String get passwordNotMatch =>
      'New password and confirmation password do not match.';

  @override
  String get userNameTaken => 'The user name is already taken';

  @override
  String get weakPassword => 'Weak Password';

  @override
  String get emailTaken => 'The email is already taken';

  @override
  String get invalidEmail => 'This is an invalid email address';

  @override
  String get registrationError => 'Registration error';

  @override
  String get userNotFound => 'User not found';

  @override
  String get wrongCredentials => 'Wrong credentials';

  @override
  String get authError => 'Authentication error';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notRegistered =>
      'Not registered yet?, Don\'t worry register here.';

  @override
  String get alreadyRegistered => 'Already registered?, Login here.';

  @override
  String title(Object maxChar) {
    return 'Title (max $maxChar characters)  ';
  }

  @override
  String description(int maxChar) {
    return 'Description (max $maxChar characters)  ';
  }

  @override
  String note(int maxChar) {
    return 'Note (max $maxChar characters)  ';
  }

  @override
  String get location => 'Location';

  @override
  String get repetitionEvent => 'Duplicate Start Date\'';

  @override
  String get repetitionEventInfo =>
      'An event with the same start hour and day already exists.';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get repetitionDetails => 'Repetition details';

  @override
  String dailyRepetitionInf(int concurrenceDay) {
    return 'This event will repeat every $concurrenceDay day';
  }

  @override
  String get every => 'Every:';

  @override
  String get dailys => 'daily(s)';

  @override
  String get weeklys => 'weekly(s)';

  @override
  String get monthlies => 'monthly(s)';

  @override
  String get yearlys => 'year(s)';

  @override
  String get untilDate => 'Until Date: ';

  @override
  String untilDateSelected(String untilDate) {
    return 'Until Date: $untilDate ';
  }

  @override
  String get notSelected => 'Not Selected';

  @override
  String get utilDateNotSelected => 'Until Date: Not Selected';

  @override
  String get specifyRepeatInterval => 'Please specify repeat interval';

  @override
  String get selectOneDayAtLeast =>
      'Please select at least one day of the week.';

  @override
  String get datesMustBeSame =>
      'Start and end dates must be the same day for the event to repeat';

  @override
  String get startDate => 'Start Date: ';

  @override
  String get endDate => 'End Date: ';

  @override
  String get noDaysSelected => 'No Days Selected';

  @override
  String get selectRepetition => 'Select repetition';

  @override
  String get selectDay => 'Select Day: ';

  @override
  String dayRepetitionInf(int concurrenceWeeks) {
    return 'This event will repeat every $concurrenceWeeks day.';
  }

  @override
  String weeklyRepetitionInf(
      int concurrenceWeeks,
      String customDaysOfWeeksString,
      String lastDay,
      Object customDaysOfWeekString) {
    return 'This event will repeat every $concurrenceWeeks week(s) on $customDaysOfWeekString, and $lastDay ';
  }

  @override
  String weeklyRepetitionInf1(int repeatInterval, String selectedDayNames) {
    return 'This event will repeat every $repeatInterval week(s) on \$$selectedDayNames';
  }

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String errorSelectedDays(String selectedDays) {
    return 'The day of the event is $selectedDays should coincide with one of the selected day/s.';
  }

  @override
  String textFieldGroupName(int TITLE_MAX_LENGHT) {
    return 'Enter group name (Limit: $TITLE_MAX_LENGHT characters) ';
  }

  @override
  String textFieldDescription(int DESCRIPTION_MAX_LENGHT) {
    return 'Enter group description (Limit: $DESCRIPTION_MAX_LENGHT characters)';
  }

  @override
  String monthlyRepetitionInf(
      String selectedDay, int repeatInterval, Object selectDay) {
    return 'This event will repeat on the $selectDay day every $repeatInterval month(s) ';
  }

  @override
  String yearlyRepetitionInf(
      String selectedDay, int repeatInterval, Object selectDay) {
    return 'This event will repeat on the $selectDay day every $repeatInterval year(s) ';
  }

  @override
  String get editGroup => 'Edit Group';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get removeConfirmation => 'Confirm to remove';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionDeniedInf =>
      'You are not an administrator to remove this item.';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String permissionDeniedRole(Object role) {
    return 'You are currently a $role of this group.';
  }

  @override
  String get putGroupImage => 'Put an image for the group';

  @override
  String get close => 'close';

  @override
  String get addNewUser => 'Add a new user to your group';

  @override
  String get cannotRemoveYourself =>
      'You cannot remove yourself from the group';

  @override
  String get requiredTextFields => 'Group name and description are required.';

  @override
  String get groupNameRequired => 'Group name cannot be empty';

  @override
  String get groupEdited => 'Group edited successfully!';

  @override
  String get failedToEditGroup => 'Failed to edit the group. Please try again';

  @override
  String get searchPerson => 'Search by user name';

  @override
  String get delete => 'Delete';

  @override
  String get confirmRemovalMessage =>
      'Are you sure you want to delete this group?';

  @override
  String get confirmRemoval => 'Confirm Removal';

  @override
  String get groupDeletedSuccessfully => 'Group deleted successfully!';

  @override
  String get noGroupsAvailable => 'NO GROUP/S FOUND/S';

  @override
  String get monday => 'monday';

  @override
  String get tuesday => 'tuesday';

  @override
  String get wednesday => 'wednesday';

  @override
  String get thursday => 'thursday';

  @override
  String get friday => 'friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'sunday';

  @override
  String get save => 'Save changes';

  @override
  String get groupNameText => 'Group name';

  @override
  String get groupOwner => 'Group owner';

  @override
  String get enableRepetitiveEvents => 'Enable repetitive events';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get currentPasswordIncorrect =>
      'Current password is incorrect. Please try again.';

  @override
  String get newPasswordConfirmationError =>
      'New password and confirmation password do not match.';

  @override
  String get changedPasswordError =>
      'Failed to change password. Please try again';

  @override
  String get passwordContainsUnwantedChar =>
      'Password contains unwanted characters.';

  @override
  String get changeUsername => 'Change your username';

  @override
  String get successChangingUsername => 'Username updated successfully!';

  @override
  String get usernameAlreadyTaken =>
      'Username is already taken. Choose a different one.';

  @override
  String get errorUnwantedCharactersUsername =>
      'Invalid characters in the username. Please use only alphanumeric characters and underscores.';

  @override
  String get errorChangingUsername =>
      'Error changing username. Please try again later.';

  @override
  String get errorChangingPassword =>
      'Failed to change password. Please try again.';

  @override
  String get errorUsernameLength =>
      'Error Username should be between 6 char and 10 char ';

  @override
  String formatDate(Object date) {
    return '$date';
  }

  @override
  String get forgotPassword => 'Recover here your password.';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get userNameRequired => 'User name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordLength => 'Password maximum length is 6 characters';

  @override
  String get groupNotCreated =>
      'There was an error creating the group, try again';

  @override
  String get questionDeleteGroup =>
      'Are you sure you want to delete this group?';

  @override
  String get errorEventCreation =>
      'Error occurred while creating the event, try again later';

  @override
  String get eventEditFailed =>
      'Error occurred while editing the event, try again later';

  @override
  String get noEventsFoundForDate =>
      'Events not found for this date, try again later.';

  @override
  String get confirmDelete => 'Are you sure you want to remove this event ?';

  @override
  String get confirmDeleteDescription => 'Remove event.';

  @override
  String get groupNameLabel => 'Group Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get refresh => 'Refreshing screen ...';

  @override
  String get accepted => 'Accepted';

  @override
  String get pending => 'Pending';

  @override
  String get notAccepted => 'NotAccepted';

  @override
  String get newUsers => 'New';

  @override
  String get expired => 'Expired';

  @override
  String get userNotSignedIn => 'User is not signed in.';

  @override
  String get createdOn => 'Created On';

  @override
  String get userCount => 'User Count';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String timeHoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String timeDaysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get timeLast30Days => 'Last 30 days';

  @override
  String get groupRecent => 'Recent';

  @override
  String get groupLast7Days => 'Last 7 days';

  @override
  String get groupLast30Days => 'Last 30 days';

  @override
  String get groupOlder => 'Older';

  @override
  String get notificationGroupCreationTitle => 'Congratulations!';

  @override
  String notificationGroupCreationMessage(Object groupName) {
    return 'You created the group: $groupName';
  }

  @override
  String get notificationJoinedGroupTitle => 'Welcome to the Group';

  @override
  String notificationJoinedGroupMessage(Object groupName) {
    return 'You have joined the group: $groupName';
  }

  @override
  String get notificationInvitationTitle => 'Group Invitation';

  @override
  String notificationInvitationMessage(Object groupName) {
    return 'You have been invited to join the group: $groupName';
  }

  @override
  String get notificationInvitationDeniedTitle => 'Invitation Declined';

  @override
  String notificationInvitationDeniedMessage(
      Object groupName, Object userName) {
    return '$userName declined the invitation to join $groupName';
  }

  @override
  String get notificationUserAcceptedTitle => 'User Joined';

  @override
  String notificationUserAcceptedMessage(Object groupName, Object userName) {
    return '$userName has accepted the invitation to join $groupName';
  }

  @override
  String get notificationGroupEditedTitle => 'Group Updated';

  @override
  String notificationGroupEditedMessage(Object groupName) {
    return 'You updated the group: $groupName';
  }

  @override
  String get notificationGroupDeletedTitle => 'Group Deleted';

  @override
  String notificationGroupDeletedMessage(Object groupName) {
    return 'You have deleted the group: $groupName';
  }

  @override
  String get notificationUserRemovedTitle => 'User Removed';

  @override
  String notificationUserRemovedMessage(Object adminName, Object groupName) {
    return 'You have been removed from $groupName by $adminName';
  }

  @override
  String get notificationAdminUserRemovedTitle => 'User Removed';

  @override
  String notificationAdminUserRemovedMessage(
      Object groupName, Object userName) {
    return '$userName was removed from $groupName';
  }

  @override
  String get notificationUserLeftTitle => 'User Left';

  @override
  String notificationUserLeftMessage(Object groupName, Object userName) {
    return '$userName has left the group: $groupName';
  }

  @override
  String get notificationGroupUpdateTitle => 'Group Updated';

  @override
  String notificationGroupUpdateMessage(Object editorName, Object groupName) {
    return '$editorName updated the group: $groupName';
  }

  @override
  String get notificationGroupDeletedAllTitle => 'Group Deleted';

  @override
  String notificationGroupDeletedAllMessage(Object groupName) {
    return 'The group \"$groupName\" has been deleted by the owner.';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get editEvent => 'Edit Event';

  @override
  String eventDayNotIncludedWarning(String day) {
    return 'Warning: The event starts on $day, but this day is not selected in the recurrence pattern.';
  }

  @override
  String get removeRecurrence => 'Remove Recurrence';

  @override
  String get removeRecurrenceConfirm =>
      'Are you sure you want to remove the recurrence rule?';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get reminderHelper => 'Choose when to be reminded';

  @override
  String get reminderOptionAtTime => 'At time of event';

  @override
  String get reminderOption5min => '5 minutes before';

  @override
  String get reminderOption10min => '10 minutes before';

  @override
  String get reminderOption30min => '30 minutes before';

  @override
  String get reminderOption1hour => '1 hour before';

  @override
  String get reminderOption2hours => '2 hours before';

  @override
  String get reminderOption1day => '1 day before';

  @override
  String get reminderOption2days => '2 days before';

  @override
  String get reminderOption3days => '3 days before';

  @override
  String get saveChangesMessage => 'Saving changes...';

  @override
  String get createEventMessage => 'Creating event...';

  @override
  String get dialogSelectUsersTitle => 'Select users for this event';

  @override
  String get dialogClose => 'Close';

  @override
  String get dialogShowUsers => 'Show User Selection';

  @override
  String get repeatEventLabel => 'Repeat Event:';

  @override
  String get repeatYes => 'Yes';

  @override
  String get repeatNo => 'No';

  @override
  String get notificationEventReminderTitle => 'Event Reminder';

  @override
  String notificationEventReminderMessage(Object eventTitle) {
    return 'Reminder: \"$eventTitle\" is coming up soon.';
  }

  @override
  String get userDropdownSelect => 'Select Users';

  @override
  String get noUsersSelected => 'No users selected.';

  @override
  String get noUserRolesAvailable => 'No user roles available';

  @override
  String get userExpandableCardTitle => 'Select Users';

  @override
  String get eventDetailsTitle => 'Event Details';

  @override
  String get eventTitleHint => 'Title';

  @override
  String get eventStartDateHint => 'Start Date';

  @override
  String get eventEndDateHint => 'End Date';

  @override
  String get eventLocationHint => 'Localization';

  @override
  String get eventDescriptionHint => 'Description';

  @override
  String get eventNoteHint => 'Note';

  @override
  String get eventRecurrenceHint => 'Recurrence Rule';

  @override
  String get notificationEventCreatedTitle => 'Event Created';

  @override
  String notificationEventCreatedMessage(String eventTitle) {
    return 'An event \"$eventTitle\" has been created.';
  }

  @override
  String get notificationEventUpdatedTitle => 'Event Updated';

  @override
  String notificationEventUpdatedMessage(String eventTitle) {
    return 'The event \"$eventTitle\" has been updated.';
  }

  @override
  String get notificationEventDeletedTitle => 'Event Deleted';

  @override
  String notificationEventDeletedMessage(String eventTitle) {
    return 'The event \"$eventTitle\" has been removed.';
  }

  @override
  String get notificationRecurrenceAddedTitle => 'Recurring Event';

  @override
  String notificationRecurrenceAddedMessage(String title) {
    return 'The event \"$title\" is now recurring.';
  }

  @override
  String get notificationEventMarkedDoneTitle => 'Event Completed';

  @override
  String notificationEventMarkedDoneMessage(
      String eventTitle, String userName) {
    return 'The event \"$eventTitle\" was marked as completed by $userName.';
  }

  @override
  String get notificationEventReopenedTitle => 'Event Reopened';

  @override
  String notificationEventReopenedMessage(String eventTitle, String userName) {
    return 'The event \"$eventTitle\" was reopened by $userName.';
  }

  @override
  String get notificationEventStartedTitle => 'Event Started';

  @override
  String notificationEventStartedMessage(String eventTitle) {
    return 'The event \"$eventTitle\" has just started.';
  }

  @override
  String notificationEventReminderBodyWithTime(
      String eventTitle, String eventTime) {
    return '“$eventTitle” starts at $eventTime';
  }

  @override
  String get notificationEventReminderManual => 'Manual Test Notification';

  @override
  String get categoryGroup => 'Group';

  @override
  String get categoryUser => 'User';

  @override
  String get categorySystem => 'System';

  @override
  String get categoryOther => 'Other';

  @override
  String get passwordRecoveryTitle => 'Password Recovery';

  @override
  String get passwordRecoveryInstruction =>
      'Enter your account email or username to start password recovery:';

  @override
  String get emailOrUsername => 'Email or Username';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordRecoveryEmptyField =>
      'Please enter your email or username.';

  @override
  String get passwordRecoverySuccess =>
      'A password reset request has been noted. Please contact support or check your account settings.';

  @override
  String get endDateMustBeAfterStartDate =>
      'End date must be after the start date';

  @override
  String get pleaseSelectAtLeastOneUser => 'Please select at least one user';
}
