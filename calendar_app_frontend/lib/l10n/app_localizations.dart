import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @groupData.
  ///
  /// In en, this message translates to:
  /// **'Group Data'**
  String get groupData;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// The current language
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get language;

  /// Change View
  ///
  /// In en, this message translates to:
  /// **'Change the view'**
  String get changeView;

  /// No description provided for @welcomeGroupView.
  ///
  /// In en, this message translates to:
  /// **'Welcome {username} here you can see the list of groups that you are part of.'**
  String welcomeGroupView(Object username);

  /// No description provided for @zeroNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications available'**
  String get zeroNotifications;

  /// No description provided for @goToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Go to the calendar'**
  String get goToCalendar;

  /// Note form
  ///
  /// In en, this message translates to:
  /// **'Group name (max {maxChar} characters)  '**
  String groupName(int maxChar);

  /// Note form
  ///
  /// In en, this message translates to:
  /// **'Group description (max {maxChar} characters)  '**
  String groupDescription(int maxChar);

  /// No description provided for @addPplGroup.
  ///
  /// In en, this message translates to:
  /// **'Add people to your group'**
  String get addPplGroup;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @coAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Co-Administrator'**
  String get coAdministrator;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @saveGroup.
  ///
  /// In en, this message translates to:
  /// **'Save the group'**
  String get saveGroup;

  /// No description provided for @addImageGroup.
  ///
  /// In en, this message translates to:
  /// **'Add image for the group'**
  String get addImageGroup;

  /// No description provided for @removeEvent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this event ?'**
  String get removeEvent;

  /// No description provided for @removeGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this group ?'**
  String get removeGroup;

  /// No description provided for @removeCalendar.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this calendar ?'**
  String get removeCalendar;

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created successfully!'**
  String get groupCreated;

  /// No description provided for @failedToCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create the group'**
  String get failedToCreateGroup;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'The event has been created'**
  String get eventCreated;

  /// No description provided for @eventEdited.
  ///
  /// In en, this message translates to:
  /// **'The event has been edited'**
  String get eventEdited;

  /// No description provided for @eventAddedGroup.
  ///
  /// In en, this message translates to:
  /// **'The event has been added to the group'**
  String get eventAddedGroup;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @chooseEventColor.
  ///
  /// In en, this message translates to:
  /// **'Choose the color of the event:'**
  String get chooseEventColor;

  /// No description provided for @errorEventNote.
  ///
  /// In en, this message translates to:
  /// **'Event note cannot be empty!'**
  String get errorEventNote;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get userName;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Insert your current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your current password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @userNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username (e.g., john_doe123)'**
  String get userNameHint;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Introduce your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password again'**
  String get confirmPasswordHint;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out ?'**
  String get logoutMessage;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation password do not match.'**
  String get passwordNotMatch;

  /// No description provided for @userNameTaken.
  ///
  /// In en, this message translates to:
  /// **'The user name is already taken'**
  String get userNameTaken;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak Password'**
  String get weakPassword;

  /// No description provided for @emailTaken.
  ///
  /// In en, this message translates to:
  /// **'The email is already taken'**
  String get emailTaken;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This is an invalid email address'**
  String get invalidEmail;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials'**
  String get wrongCredentials;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered yet?, Don\'t worry register here.'**
  String get notRegistered;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered?, Login here.'**
  String get alreadyRegistered;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title (max {maxChar} characters)  '**
  String title(Object maxChar);

  /// Description form
  ///
  /// In en, this message translates to:
  /// **'Description (max {maxChar} characters)  '**
  String description(int maxChar);

  /// Note form
  ///
  /// In en, this message translates to:
  /// **'Note (max {maxChar} characters)  '**
  String note(int maxChar);

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @repetitionEvent.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Start Date\''**
  String get repetitionEvent;

  /// No description provided for @repetitionEventInfo.
  ///
  /// In en, this message translates to:
  /// **'An event with the same start hour and day already exists.'**
  String get repetitionEventInfo;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @repetitionDetails.
  ///
  /// In en, this message translates to:
  /// **'Repetition details'**
  String get repetitionDetails;

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'This event will repeat every {concurrenceDay} day'**
  String dailyRepetitionInf(int concurrenceDay);

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every:'**
  String get every;

  /// No description provided for @dailys.
  ///
  /// In en, this message translates to:
  /// **'daily(s)'**
  String get dailys;

  /// No description provided for @weeklys.
  ///
  /// In en, this message translates to:
  /// **'weekly(s)'**
  String get weeklys;

  /// No description provided for @monthlies.
  ///
  /// In en, this message translates to:
  /// **'monthly(s)'**
  String get monthlies;

  /// No description provided for @yearlys.
  ///
  /// In en, this message translates to:
  /// **'year(s)'**
  String get yearlys;

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'Until Date: '**
  String get untilDate;

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'Until Date: {untilDate} '**
  String untilDateSelected(String untilDate);

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get notSelected;

  /// No description provided for @utilDateNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Until Date: Not Selected'**
  String get utilDateNotSelected;

  /// No description provided for @specifyRepeatInterval.
  ///
  /// In en, this message translates to:
  /// **'Please specify repeat interval'**
  String get specifyRepeatInterval;

  /// No description provided for @selectOneDayAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day of the week.'**
  String get selectOneDayAtLeast;

  /// No description provided for @datesMustBeSame.
  ///
  /// In en, this message translates to:
  /// **'Start and end dates must be the same day for the event to repeat'**
  String get datesMustBeSame;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date: '**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date: '**
  String get endDate;

  /// No description provided for @noDaysSelected.
  ///
  /// In en, this message translates to:
  /// **'No Days Selected'**
  String get noDaysSelected;

  /// No description provided for @selectRepetition.
  ///
  /// In en, this message translates to:
  /// **'Select repetition'**
  String get selectRepetition;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day: '**
  String get selectDay;

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'This event will repeat every {concurrenceWeeks} day.'**
  String dayRepetitionInf(int concurrenceWeeks);

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'This event will repeat every {concurrenceWeeks} week(s) on {customDaysOfWeekString}, and {lastDay} '**
  String weeklyRepetitionInf(
      int concurrenceWeeks,
      String customDaysOfWeeksString,
      String lastDay,
      Object customDaysOfWeekString);

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'This event will repeat every {repeatInterval} week(s) on \${selectedDayNames}'**
  String weeklyRepetitionInf1(int repeatInterval, String selectedDayNames);

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'The day of the event is {selectedDays} should coincide with one of the selected day/s.'**
  String errorSelectedDays(String selectedDays);

  /// Textfield for the group name
  ///
  /// In en, this message translates to:
  /// **'Enter group name (Limit: {TITLE_MAX_LENGHT} characters) '**
  String textFieldGroupName(int TITLE_MAX_LENGHT);

  /// Textfield for the group description
  ///
  /// In en, this message translates to:
  /// **'Enter group description (Limit: {DESCRIPTION_MAX_LENGHT} characters)'**
  String textFieldDescription(int DESCRIPTION_MAX_LENGHT);

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'This event will repeat on the {selectDay} day every {repeatInterval} month(s) '**
  String monthlyRepetitionInf(
      String selectedDay, int repeatInterval, Object selectDay);

  /// Concurrence for the event
  ///
  /// In en, this message translates to:
  /// **'This event will repeat on the {selectDay} day every {repeatInterval} year(s) '**
  String yearlyRepetitionInf(
      String selectedDay, int repeatInterval, Object selectDay);

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @removeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm to remove'**
  String get removeConfirmation;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedInf.
  ///
  /// In en, this message translates to:
  /// **'You are not an administrator to remove this item.'**
  String get permissionDeniedInf;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// No description provided for @permissionDeniedRole.
  ///
  /// In en, this message translates to:
  /// **'You are currently a {role} of this group.'**
  String permissionDeniedRole(Object role);

  /// No description provided for @putGroupImage.
  ///
  /// In en, this message translates to:
  /// **'Put an image for the group'**
  String get putGroupImage;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get close;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add a new user to your group'**
  String get addNewUser;

  /// No description provided for @cannotRemoveYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove yourself from the group'**
  String get cannotRemoveYourself;

  /// No description provided for @requiredTextFields.
  ///
  /// In en, this message translates to:
  /// **'Group name and description are required.'**
  String get requiredTextFields;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Group name cannot be empty'**
  String get groupNameRequired;

  /// No description provided for @groupEdited.
  ///
  /// In en, this message translates to:
  /// **'Group edited successfully!'**
  String get groupEdited;

  /// No description provided for @failedToEditGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to edit the group. Please try again'**
  String get failedToEditGroup;

  /// No description provided for @searchPerson.
  ///
  /// In en, this message translates to:
  /// **'Search by user name'**
  String get searchPerson;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmRemovalMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this group?'**
  String get confirmRemovalMessage;

  /// No description provided for @confirmRemoval.
  ///
  /// In en, this message translates to:
  /// **'Confirm Removal'**
  String get confirmRemoval;

  /// No description provided for @groupDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Group deleted successfully!'**
  String get groupDeletedSuccessfully;

  /// No description provided for @noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'NO GROUP/S FOUND/S'**
  String get noGroupsAvailable;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'sunday'**
  String get sunday;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save;

  /// No description provided for @groupNameText.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameText;

  /// No description provided for @groupOwner.
  ///
  /// In en, this message translates to:
  /// **'Group owner'**
  String get groupOwner;

  /// No description provided for @enableRepetitiveEvents.
  ///
  /// In en, this message translates to:
  /// **'Enable repetitive events'**
  String get enableRepetitiveEvents;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect. Please try again.'**
  String get currentPasswordIncorrect;

  /// No description provided for @newPasswordConfirmationError.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation password do not match.'**
  String get newPasswordConfirmationError;

  /// No description provided for @changedPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password. Please try again'**
  String get changedPasswordError;

  /// No description provided for @passwordContainsUnwantedChar.
  ///
  /// In en, this message translates to:
  /// **'Password contains unwanted characters.'**
  String get passwordContainsUnwantedChar;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change your username'**
  String get changeUsername;

  /// No description provided for @successChangingUsername.
  ///
  /// In en, this message translates to:
  /// **'Username updated successfully!'**
  String get successChangingUsername;

  /// No description provided for @usernameAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken. Choose a different one.'**
  String get usernameAlreadyTaken;

  /// No description provided for @errorUnwantedCharactersUsername.
  ///
  /// In en, this message translates to:
  /// **'Invalid characters in the username. Please use only alphanumeric characters and underscores.'**
  String get errorUnwantedCharactersUsername;

  /// No description provided for @errorChangingUsername.
  ///
  /// In en, this message translates to:
  /// **'Error changing username. Please try again later.'**
  String get errorChangingUsername;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password. Please try again.'**
  String get errorChangingPassword;

  /// No description provided for @errorUsernameLength.
  ///
  /// In en, this message translates to:
  /// **'Error Username should be between 6 char and 10 char '**
  String get errorUsernameLength;

  /// No description provided for @formatDate.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String formatDate(Object date);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Recover here your password.'**
  String get forgotPassword;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @userNameRequired.
  ///
  /// In en, this message translates to:
  /// **'User name is required'**
  String get userNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password maximum length is 6 characters'**
  String get passwordLength;

  /// No description provided for @groupNotCreated.
  ///
  /// In en, this message translates to:
  /// **'There was an error creating the group, try again'**
  String get groupNotCreated;

  /// No description provided for @questionDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this group?'**
  String get questionDeleteGroup;

  /// No description provided for @errorEventCreation.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while creating the event, try again later'**
  String get errorEventCreation;

  /// No description provided for @eventEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while editing the event, try again later'**
  String get eventEditFailed;

  /// No description provided for @noEventsFoundForDate.
  ///
  /// In en, this message translates to:
  /// **'Events not found for this date, try again later.'**
  String get noEventsFoundForDate;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this event ?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove event.'**
  String get confirmDeleteDescription;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refreshing screen ...'**
  String get refresh;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @notAccepted.
  ///
  /// In en, this message translates to:
  /// **'NotAccepted'**
  String get notAccepted;

  /// No description provided for @newUsers.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newUsers;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Error shown when a user action requires being signed in
  ///
  /// In en, this message translates to:
  /// **'User is not signed in.'**
  String get userNotSignedIn;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get createdOn;

  /// No description provided for @userCount.
  ///
  /// In en, this message translates to:
  /// **'User Count'**
  String get userCount;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String timeMinutesAgo(Object minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String timeHoursAgo(Object hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String timeDaysAgo(Object days);

  /// No description provided for @timeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get timeLast30Days;

  /// No description provided for @groupRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get groupRecent;

  /// No description provided for @groupLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get groupLast7Days;

  /// No description provided for @groupLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get groupLast30Days;

  /// No description provided for @groupOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get groupOlder;

  /// No description provided for @notificationGroupCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get notificationGroupCreationTitle;

  /// No description provided for @notificationGroupCreationMessage.
  ///
  /// In en, this message translates to:
  /// **'You created the group: {groupName}'**
  String notificationGroupCreationMessage(Object groupName);

  /// No description provided for @notificationJoinedGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Group'**
  String get notificationJoinedGroupTitle;

  /// No description provided for @notificationJoinedGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'You have joined the group: {groupName}'**
  String notificationJoinedGroupMessage(Object groupName);

  /// No description provided for @notificationInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Invitation'**
  String get notificationInvitationTitle;

  /// No description provided for @notificationInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to join the group: {groupName}'**
  String notificationInvitationMessage(Object groupName);

  /// No description provided for @notificationInvitationDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Declined'**
  String get notificationInvitationDeniedTitle;

  /// No description provided for @notificationInvitationDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'{userName} declined the invitation to join {groupName}'**
  String notificationInvitationDeniedMessage(Object groupName, Object userName);

  /// No description provided for @notificationUserAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'User Joined'**
  String get notificationUserAcceptedTitle;

  /// No description provided for @notificationUserAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'{userName} has accepted the invitation to join {groupName}'**
  String notificationUserAcceptedMessage(Object groupName, Object userName);

  /// No description provided for @notificationGroupEditedTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Updated'**
  String get notificationGroupEditedTitle;

  /// No description provided for @notificationGroupEditedMessage.
  ///
  /// In en, this message translates to:
  /// **'You updated the group: {groupName}'**
  String notificationGroupEditedMessage(Object groupName);

  /// No description provided for @notificationGroupDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Deleted'**
  String get notificationGroupDeletedTitle;

  /// No description provided for @notificationGroupDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have deleted the group: {groupName}'**
  String notificationGroupDeletedMessage(Object groupName);

  /// No description provided for @notificationUserRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'User Removed'**
  String get notificationUserRemovedTitle;

  /// No description provided for @notificationUserRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been removed from {groupName} by {adminName}'**
  String notificationUserRemovedMessage(Object adminName, Object groupName);

  /// No description provided for @notificationAdminUserRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'User Removed'**
  String get notificationAdminUserRemovedTitle;

  /// No description provided for @notificationAdminUserRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'{userName} was removed from {groupName}'**
  String notificationAdminUserRemovedMessage(Object groupName, Object userName);

  /// No description provided for @notificationUserLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'User Left'**
  String get notificationUserLeftTitle;

  /// No description provided for @notificationUserLeftMessage.
  ///
  /// In en, this message translates to:
  /// **'{userName} has left the group: {groupName}'**
  String notificationUserLeftMessage(Object groupName, Object userName);

  /// No description provided for @notificationGroupUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Updated'**
  String get notificationGroupUpdateTitle;

  /// No description provided for @notificationGroupUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'{editorName} updated the group: {groupName}'**
  String notificationGroupUpdateMessage(Object editorName, Object groupName);

  /// No description provided for @notificationGroupDeletedAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Deleted'**
  String get notificationGroupDeletedAllTitle;

  /// No description provided for @notificationGroupDeletedAllMessage.
  ///
  /// In en, this message translates to:
  /// **'The group \"{groupName}\" has been deleted by the owner.'**
  String notificationGroupDeletedAllMessage(Object groupName);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// Shown as a warning when a user selects weekly recurrence days that do not include the event's start day
  ///
  /// In en, this message translates to:
  /// **'Warning: The event starts on {day}, but this day is not selected in the recurrence pattern.'**
  String eventDayNotIncludedWarning(String day);

  /// No description provided for @removeRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Remove Recurrence'**
  String get removeRecurrence;

  /// No description provided for @removeRecurrenceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the recurrence rule?'**
  String get removeRecurrenceConfirm;

  /// No description provided for @reminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderLabel;

  /// No description provided for @reminderHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose when to be reminded'**
  String get reminderHelper;

  /// No description provided for @reminderOptionAtTime.
  ///
  /// In en, this message translates to:
  /// **'At time of event'**
  String get reminderOptionAtTime;

  /// No description provided for @reminderOption5min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes before'**
  String get reminderOption5min;

  /// No description provided for @reminderOption10min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes before'**
  String get reminderOption10min;

  /// No description provided for @reminderOption30min.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get reminderOption30min;

  /// No description provided for @reminderOption1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminderOption1hour;

  /// No description provided for @reminderOption2hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours before'**
  String get reminderOption2hours;

  /// No description provided for @reminderOption1day.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderOption1day;

  /// No description provided for @reminderOption2days.
  ///
  /// In en, this message translates to:
  /// **'2 days before'**
  String get reminderOption2days;

  /// No description provided for @reminderOption3days.
  ///
  /// In en, this message translates to:
  /// **'3 days before'**
  String get reminderOption3days;

  /// No description provided for @saveChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get saveChangesMessage;

  /// No description provided for @createEventMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating event...'**
  String get createEventMessage;

  /// No description provided for @dialogSelectUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Select users for this event'**
  String get dialogSelectUsersTitle;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @dialogShowUsers.
  ///
  /// In en, this message translates to:
  /// **'Show User Selection'**
  String get dialogShowUsers;

  /// No description provided for @repeatEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat Event:'**
  String get repeatEventLabel;

  /// No description provided for @repeatYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get repeatYes;

  /// No description provided for @repeatNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get repeatNo;

  /// No description provided for @notificationEventReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Reminder'**
  String get notificationEventReminderTitle;

  /// No description provided for @notificationEventReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Reminder: \"{eventTitle}\" is coming up soon.'**
  String notificationEventReminderMessage(Object eventTitle);

  /// No description provided for @userDropdownSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Users'**
  String get userDropdownSelect;

  /// No description provided for @noUsersSelected.
  ///
  /// In en, this message translates to:
  /// **'No users selected.'**
  String get noUsersSelected;

  /// No description provided for @userExpandableCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Users'**
  String get userExpandableCardTitle;

  /// No description provided for @eventDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetailsTitle;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitleHint;

  /// No description provided for @eventStartDateHint.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get eventStartDateHint;

  /// No description provided for @eventEndDateHint.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get eventEndDateHint;

  /// No description provided for @eventLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get eventLocationHint;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescriptionHint;

  /// No description provided for @eventNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get eventNoteHint;

  /// No description provided for @eventRecurrenceHint.
  ///
  /// In en, this message translates to:
  /// **'Recurrence Rule'**
  String get eventRecurrenceHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
