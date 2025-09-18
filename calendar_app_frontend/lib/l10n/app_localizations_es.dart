// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get groups => 'Grupos';

  @override
  String get calendar => 'Calendario';

  @override
  String get settings => 'Configuración';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get groupData => 'Datos del grupo';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get language => 'es';

  @override
  String get changeView => 'Cambiar vista';

  @override
  String welcomeGroupView(Object username) {
    return 'Bienvenido $username, aquí puedes ver la lista de grupos de los que formas parte.';
  }

  @override
  String get zeroNotifications => 'No hay notificaciones disponibles';

  @override
  String get goToCalendar => 'Ir al calendario';

  @override
  String groupName(int maxChar) {
    return 'Nombre del grupo (máximo $maxChar caracteres)';
  }

  @override
  String groupDescription(int maxChar) {
    return 'Descripción del grupo (máximo $maxChar caracteres)';
  }

  @override
  String get addPplGroup => 'Añadir personas a tu grupo';

  @override
  String get addUser => 'Añadir usuario';

  @override
  String get addEvent => 'Añadir evento';

  @override
  String get administrator => 'Administrador';

  @override
  String get coAdministrator => 'Co-Administrador';

  @override
  String get member => 'Miembro';

  @override
  String get saveGroup => 'Guardar grupo';

  @override
  String get addImageGroup => 'Añadir imagen para el grupo';

  @override
  String get removeEvent =>
      '¿Estás seguro de que quieres eliminar este evento?';

  @override
  String get removeGroup => '¿Estás seguro de que quieres eliminar este grupo?';

  @override
  String get removeCalendar =>
      '¿Estás seguro de que quieres eliminar este calendario?';

  @override
  String get groupCreated => '¡Grupo creado con éxito!';

  @override
  String get failedToCreateGroup => 'Error al crear el grupo';

  @override
  String get eventCreated => 'El evento ha sido creado';

  @override
  String get eventEdited => 'El evento ha sido editado';

  @override
  String get eventAddedGroup => 'El evento ha sido añadido al grupo';

  @override
  String get event => 'Evento';

  @override
  String get chooseEventColor => 'Elige el color del evento:';

  @override
  String get errorEventNote => '¡La nota del evento no puede estar vacía!';

  @override
  String get name => 'Nombre';

  @override
  String get userName => 'Nombre de usuario';

  @override
  String get currentPassword => 'Introduce tu contraseña actual';

  @override
  String get newPassword => 'Actualiza tu contraseña actual';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get password => 'Contraseña';

  @override
  String get register => 'Registrarse';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get userNameHint =>
      'Introduce tu nombre de usuario (p.ej., john_doe123)';

  @override
  String get nameHint => 'Introduce tu nombre';

  @override
  String get emailHint => 'Introduce tu correo electrónico';

  @override
  String get passwordHint => 'Introduce tu contraseña';

  @override
  String get confirmPasswordHint => 'Introduce tu contraseña de nuevo';

  @override
  String get logoutMessage => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get passwordNotMatch =>
      'La nueva contraseña y la confirmación no coinciden.';

  @override
  String get userNameTaken => 'El nombre de usuario ya está en uso';

  @override
  String get weakPassword => 'Contraseña débil';

  @override
  String get emailTaken => 'El correo electrónico ya está en uso';

  @override
  String get invalidEmail =>
      'Esta dirección de correo electrónico no es válida';

  @override
  String get registrationError => 'Error de registro';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get wrongCredentials => 'Credenciales incorrectas';

  @override
  String get authError => 'Error de autenticación';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get notRegistered =>
      '¿No estás registrado? No te preocupes, regístrate aquí.';

  @override
  String get alreadyRegistered => '¿Ya estás registrado? Inicia sesión aquí.';

  @override
  String title(Object maxChar) {
    return 'Título (máximo $maxChar caracteres)';
  }

  @override
  String description(int maxChar) {
    return 'Descripción (máximo $maxChar caracteres)';
  }

  @override
  String note(int maxChar) {
    return 'Nota (máximo $maxChar caracteres)';
  }

  @override
  String get location => 'Ubicación';

  @override
  String get repetitionEvent => 'Fecha de inicio duplicada';

  @override
  String get repetitionEventInfo =>
      'Ya existe un evento con la misma hora y día de inicio.';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get repetitionDetails => 'Detalles de repetición';

  @override
  String dailyRepetitionInf(int concurrenceDay) {
    return 'Este evento se repetirá cada $concurrenceDay día';
  }

  @override
  String get every => 'Cada:';

  @override
  String get dailys => 'diario(s)';

  @override
  String get weeklys => 'semanal(es)';

  @override
  String get monthlies => 'mensual(es)';

  @override
  String get yearlys => 'año(s)';

  @override
  String get untilDate => 'Hasta la fecha:';

  @override
  String untilDateSelected(String untilDate) {
    return 'Hasta la fecha: $untilDate';
  }

  @override
  String get notSelected => 'No seleccionado';

  @override
  String get utilDateNotSelected => 'Hasta la fecha: No seleccionado';

  @override
  String get specifyRepeatInterval =>
      'Por favor, especifica el intervalo de repetición';

  @override
  String get selectOneDayAtLeast =>
      'Por favor, selecciona al menos un día de la semana.';

  @override
  String get datesMustBeSame =>
      'Las fechas de inicio y fin deben ser el mismo día para que el evento se repita.';

  @override
  String get startDate => 'Fecha de inicio:';

  @override
  String get endDate => 'Fecha de fin:';

  @override
  String get noDaysSelected => 'No hay días seleccionados';

  @override
  String get selectRepetition => 'Seleccionar repetición';

  @override
  String get selectDay => 'Seleccionar día:';

  @override
  String dayRepetitionInf(int concurrenceWeeks) {
    return 'Este evento se repetirá cada $concurrenceWeeks día.';
  }

  @override
  String weeklyRepetitionInf(
      int concurrenceWeeks,
      String customDaysOfWeeksString,
      String lastDay,
      Object customDaysOfWeekString) {
    return 'Este evento se repetirá cada $concurrenceWeeks semana(s) el $customDaysOfWeekString, y $lastDay';
  }

  @override
  String weeklyRepetitionInf1(int repeatInterval, String selectedDayNames) {
    return 'Este evento se repetirá cada $repeatInterval semana(s) en \$$selectedDayNames';
  }

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mié';

  @override
  String get thu => 'Jue';

  @override
  String get fri => 'Vie';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String errorSelectedDays(String selectedDays) {
    return 'El día del evento $selectedDays debe coincidir con uno de los días seleccionados.';
  }

  @override
  String textFieldGroupName(int TITLE_MAX_LENGHT) {
    return 'Introduce el nombre del grupo (Límite: $TITLE_MAX_LENGHT caracteres)';
  }

  @override
  String textFieldDescription(int DESCRIPTION_MAX_LENGHT) {
    return 'Introduce la descripción del grupo (Límite: $DESCRIPTION_MAX_LENGHT caracteres)';
  }

  @override
  String monthlyRepetitionInf(
      String selectedDay, int repeatInterval, Object selectDay) {
    return 'Este evento se repetirá el día $selectDay de cada $repeatInterval mes(es)';
  }

  @override
  String yearlyRepetitionInf(
      String selectedDay, int repeatInterval, Object selectDay) {
    return 'Este evento se repetirá el día $selectDay de cada $repeatInterval año(s)';
  }

  @override
  String get editGroup => 'Editar';

  @override
  String get remove => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmation => 'Confirmación';

  @override
  String get removeConfirmation => 'Confirmar eliminación';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get permissionDeniedInf =>
      'No eres administrador para eliminar este elemento.';

  @override
  String get leaveGroup => 'Salir del grupo';

  @override
  String permissionDeniedRole(Object role) {
    return 'Actualmente eres $role de este grupo.';
  }

  @override
  String get putGroupImage => 'Poner una imagen para el grupo';

  @override
  String get close => 'Cerrar';

  @override
  String get addNewUser => 'Añadir un nuevo usuario a tu grupo';

  @override
  String get cannotRemoveYourself => 'No puedes eliminarte del grupo';

  @override
  String get requiredTextFields =>
      'El nombre y la descripción del grupo son obligatorios.';

  @override
  String get groupNameRequired => 'El nombre del grupo no puede estar vacío';

  @override
  String get groupEdited => '¡Grupo editado con éxito!';

  @override
  String get failedToEditGroup =>
      'Error al editar el grupo. Por favor, inténtalo de nuevo';

  @override
  String get searchPerson => 'Buscar por nombre de usuario';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirmRemovalMessage =>
      '¿Estás seguro de que quieres eliminar este grupo?';

  @override
  String get confirmRemoval => 'Confirmar eliminación';

  @override
  String get groupDeletedSuccessfully => '¡Grupo eliminado con éxito!';

  @override
  String get noGroupsAvailable => 'NO SE ENCONTRARON GRUPOS';

  @override
  String get monday => 'lunes';

  @override
  String get tuesday => 'martes';

  @override
  String get wednesday => 'miércoles';

  @override
  String get thursday => 'jueves';

  @override
  String get friday => 'viernes';

  @override
  String get saturday => 'sábado';

  @override
  String get sunday => 'domingo';

  @override
  String get save => 'Guardar Edición';

  @override
  String get groupNameText => 'Nombre del grupo';

  @override
  String get groupOwner => 'Propietario del grupo';

  @override
  String get enableRepetitiveEvents => 'Habilitar eventos repetitivos';

  @override
  String get passwordChangedSuccessfully => 'Contraseña cambiada con éxito';

  @override
  String get currentPasswordIncorrect =>
      'La contraseña actual es incorrecta. Por favor, inténtalo de nuevo.';

  @override
  String get newPasswordConfirmationError =>
      'La nueva contraseña y la confirmación no coinciden.';

  @override
  String get changedPasswordError =>
      'Error al cambiar la contraseña. Por favor, inténtalo de nuevo';

  @override
  String get passwordContainsUnwantedChar =>
      'La contraseña contiene caracteres no deseados.';

  @override
  String get changeUsername => 'Cambiar tu nombre de usuario';

  @override
  String get successChangingUsername =>
      '¡Nombre de usuario actualizado con éxito!';

  @override
  String get usernameAlreadyTaken =>
      'El nombre de usuario ya está en uso. Elige otro.';

  @override
  String get errorUnwantedCharactersUsername =>
      'Caracteres inválidos en el nombre de usuario. Usa solo caracteres alfanuméricos y guiones bajos.';

  @override
  String get errorChangingUsername =>
      'Error al cambiar el nombre de usuario. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get errorChangingPassword =>
      'Error al cambiar la contraseña. Por favor, inténtalo de nuevo.';

  @override
  String get errorUsernameLength =>
      'El nombre de usuario debe tener entre 6 y 10 caracteres';

  @override
  String formatDate(Object date) {
    return '$date';
  }

  @override
  String get forgotPassword => 'Recupera tu contraseña aquí.';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get userNameRequired => 'El nombre de usuario es obligatorio';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio';

  @override
  String get passwordLength =>
      'La contraseña debe tener un máximo de 6 caracteres';

  @override
  String get groupNotCreated => 'Error al crear el grupo, inténtalo de nuevo';

  @override
  String get questionDeleteGroup =>
      '¿Estás seguro de que quieres eliminar este grupo?';

  @override
  String get errorEventCreation =>
      'Se produjo un error al crear el evento, inténtalo más tarde';

  @override
  String get eventEditFailed =>
      'Se produjo un error al editar el evento, inténtalo más tarde';

  @override
  String get noEventsFoundForDate =>
      'No se encontraron eventos para esta fecha, inténtalo más tarde.';

  @override
  String get confirmDelete =>
      '¿Estás seguro de que quieres eliminar este evento?';

  @override
  String get confirmDeleteDescription => 'Eliminar evento.';

  @override
  String get groupNameLabel => 'Nombre del grupo';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get refresh => 'Actualizando pantalla...';

  @override
  String get accepted => 'Aceptado';

  @override
  String get pending => 'Pendiente';

  @override
  String get notAccepted => 'No aceptado';

  @override
  String get newUsers => 'Nuevos';

  @override
  String get expired => 'Expirado';

  @override
  String get userNotSignedIn => 'El usuario no esta logeado.';

  @override
  String get createdOn => 'Creado en';

  @override
  String get userCount => 'Contador';

  @override
  String get timeJustNow => 'Justo ahora';

  @override
  String timeMinutesAgo(Object minutes) {
    return 'hace $minutes minutos';
  }

  @override
  String timeHoursAgo(Object hours) {
    return 'hace $hours horas';
  }

  @override
  String timeDaysAgo(Object days) {
    return 'hace $days días';
  }

  @override
  String get timeLast30Days => 'Últimos 30 días';

  @override
  String get groupRecent => 'Reciente';

  @override
  String get groupLast7Days => 'Últimos 7 días';

  @override
  String get groupLast30Days => 'Últimos 30 días';

  @override
  String get groupOlder => 'Antiguos';

  @override
  String get notificationGroupCreationTitle => '¡Felicidades!';

  @override
  String notificationGroupCreationMessage(Object groupName) {
    return 'Has creado el grupo: $groupName';
  }

  @override
  String get notificationJoinedGroupTitle => 'Bienvenido al grupo';

  @override
  String notificationJoinedGroupMessage(Object groupName) {
    return 'Te has unido al grupo: $groupName';
  }

  @override
  String get notificationInvitationTitle => 'Invitación al grupo';

  @override
  String notificationInvitationMessage(Object groupName) {
    return 'Has sido invitado a unirte al grupo: $groupName';
  }

  @override
  String get notificationInvitationDeniedTitle => 'Invitación rechazada';

  @override
  String notificationInvitationDeniedMessage(
      Object groupName, Object userName) {
    return '$userName rechazó la invitación para unirse a $groupName';
  }

  @override
  String get notificationUserAcceptedTitle => 'Usuario se ha unido';

  @override
  String notificationUserAcceptedMessage(Object groupName, Object userName) {
    return '$userName ha aceptado la invitación para unirse a $groupName';
  }

  @override
  String get notificationGroupEditedTitle => 'Grupo actualizado';

  @override
  String notificationGroupEditedMessage(Object groupName) {
    return 'Has actualizado el grupo: $groupName';
  }

  @override
  String get notificationGroupDeletedTitle => 'Grupo eliminado';

  @override
  String notificationGroupDeletedMessage(Object groupName) {
    return 'Has eliminado el grupo: $groupName';
  }

  @override
  String get notificationUserRemovedTitle => 'Usuario eliminado';

  @override
  String notificationUserRemovedMessage(Object adminName, Object groupName) {
    return 'Has sido eliminado del grupo $groupName por $adminName';
  }

  @override
  String get notificationAdminUserRemovedTitle => 'Usuario eliminado';

  @override
  String notificationAdminUserRemovedMessage(
      Object groupName, Object userName) {
    return '$userName fue eliminado del grupo $groupName';
  }

  @override
  String get notificationUserLeftTitle => 'Usuario salió del grupo';

  @override
  String notificationUserLeftMessage(Object groupName, Object userName) {
    return '$userName ha salido del grupo: $groupName';
  }

  @override
  String get notificationGroupUpdateTitle => 'Grupo actualizado';

  @override
  String notificationGroupUpdateMessage(Object editorName, Object groupName) {
    return '$editorName actualizó el grupo: $groupName';
  }

  @override
  String get notificationGroupDeletedAllTitle => 'Grupo eliminado';

  @override
  String notificationGroupDeletedAllMessage(Object groupName) {
    return 'El grupo \"$groupName\" ha sido eliminado por el propietario.';
  }

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get editEvent => 'Editar Evento';

  @override
  String eventDayNotIncludedWarning(String day) {
    return 'Advertencia: El evento comienza el $day, pero este día no está seleccionado en el patrón de repetición.';
  }

  @override
  String get removeRecurrence => 'Remove Recurrence';

  @override
  String get removeRecurrenceConfirm =>
      '¿Deseas eliminar la repetición de este evento?';

  @override
  String get reminderLabel => 'Recordatorio';

  @override
  String get reminderHelper => 'Elige cuándo deseas ser recordado';

  @override
  String get reminderOptionAtTime => 'A la hora del evento';

  @override
  String get reminderOption5min => '5 minutos antes';

  @override
  String get reminderOption10min => '10 minutos antes';

  @override
  String get reminderOption30min => '30 minutos antes';

  @override
  String get reminderOption1hour => '1 hora antes';

  @override
  String get reminderOption2hours => '2 horas antes';

  @override
  String get reminderOption1day => '1 día antes';

  @override
  String get reminderOption2days => '2 días antes';

  @override
  String get reminderOption3days => '3 días antes';

  @override
  String get saveChangesMessage => 'Guardando cambios...';

  @override
  String get createEventMessage => 'Creando evento...';

  @override
  String get dialogSelectUsersTitle => 'Selecciona usuarios para este evento';

  @override
  String get dialogClose => 'Cerrar';

  @override
  String get dialogShowUsers => 'Seleccionar usuarios';

  @override
  String get repeatEventLabel => 'Repetir evento:';

  @override
  String get repeatYes => 'Sí';

  @override
  String get repeatNo => 'No';

  @override
  String get notificationEventReminderTitle => 'Recordatorio de evento';

  @override
  String notificationEventReminderMessage(Object eventTitle) {
    return 'Recordatorio: \"$eventTitle\" comienza pronto.';
  }

  @override
  String get userDropdownSelect => 'Seleccionar usuarios';

  @override
  String get noUsersSelected => 'Ningún usuario seleccionado.';

  @override
  String get noUserRolesAvailable =>
      'Ningun rol seleccionado para los usuarios';

  @override
  String get userExpandableCardTitle => 'Seleccionar usuarios';

  @override
  String get eventDetailsTitle => 'Detalles del evento';

  @override
  String get eventTitleHint => 'Título';

  @override
  String get eventStartDateHint => 'Fecha de inicio';

  @override
  String get eventEndDateHint => 'Fecha de fin';

  @override
  String get eventLocationHint => 'Ubicación';

  @override
  String get eventDescriptionHint => 'Descripción';

  @override
  String get eventNoteHint => 'Nota';

  @override
  String get eventRecurrenceHint => 'Regla de repetición';

  @override
  String get notificationEventCreatedTitle => 'Evento creado';

  @override
  String notificationEventCreatedMessage(String eventTitle) {
    return 'Se ha creado un evento \"$eventTitle\".';
  }

  @override
  String get notificationEventUpdatedTitle => 'Evento actualizado';

  @override
  String notificationEventUpdatedMessage(String eventTitle) {
    return 'El evento \"$eventTitle\" ha sido actualizado.';
  }

  @override
  String get notificationEventDeletedTitle => 'Evento eliminado';

  @override
  String notificationEventDeletedMessage(String eventTitle) {
    return 'El evento \"$eventTitle\" ha sido eliminado.';
  }

  @override
  String get notificationRecurrenceAddedTitle => 'Evento recurrente';

  @override
  String notificationRecurrenceAddedMessage(String title) {
    return 'El evento \"$title\" ahora se repite.';
  }

  @override
  String get notificationEventMarkedDoneTitle => 'Evento completado';

  @override
  String notificationEventMarkedDoneMessage(
      String eventTitle, String userName) {
    return 'El evento \"$eventTitle\" fue marcado como completado por $userName.';
  }

  @override
  String get notificationEventReopenedTitle => 'Evento reabierto';

  @override
  String notificationEventReopenedMessage(String eventTitle, String userName) {
    return 'El evento \"$eventTitle\" fue reabierto por $userName.';
  }

  @override
  String get notificationEventStartedTitle => 'Evento Iniciado';

  @override
  String notificationEventStartedMessage(String eventTitle) {
    return 'El evento \"$eventTitle\" acaba de comenzar.';
  }

  @override
  String notificationEventReminderBodyWithTime(
      String eventTitle, String eventTime) {
    return 'Recordatorio: \"$eventTitle\" comienza a las $eventTime.';
  }

  @override
  String get notificationEventReminderManual => 'Notificación de prueba manual';

  @override
  String get categoryGroup => 'Grupo';

  @override
  String get categoryUser => 'Usuario';

  @override
  String get categorySystem => 'Sistema';

  @override
  String get categoryOther => 'Otro';

  @override
  String get passwordRecoveryTitle => 'Recuperación de contraseña';

  @override
  String get passwordRecoveryInstruction =>
      'Introduce tu correo electrónico o nombre de usuario para iniciar la recuperación de contraseña:';

  @override
  String get emailOrUsername => 'Correo electrónico o nombre de usuario';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get passwordRecoveryEmptyField =>
      'Por favor, introduce tu correo electrónico o nombre de usuario.';

  @override
  String get passwordRecoverySuccess =>
      'Se ha recibido una solicitud para restablecer la contraseña. Contacta con soporte o revisa la configuración de tu cuenta.';

  @override
  String get endDateMustBeAfterStartDate =>
      'La fecha de finalización debe ser posterior a la fecha de inicio';

  @override
  String get pleaseSelectAtLeastOneUser =>
      'Por favor, selecciona al menos un usuario';

  @override
  String get groupMembers => 'Miembros del grupo';

  @override
  String get noInvitedUsersToDisplay =>
      'No hay usuarios invitados para mostrar.';

  @override
  String userRemovedSuccessfully(String userName) {
    return 'Usuario $userName eliminado correctamente.';
  }

  @override
  String failedToRemoveUser(String userName) {
    return 'No se pudo eliminar al usuario $userName.';
  }

  @override
  String get groupDescriptionLabel => 'Descripción del grupo';

  @override
  String get agenda => 'Agenda';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get noItems => 'Nada próximo';

  @override
  String get home => 'Inicio';

  @override
  String get profile => 'Perfil';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get email => 'Correo electrónico';

  @override
  String get saving => 'Guardando...';

  @override
  String get photoUpdated => 'Foto actualizada';

  @override
  String get failedToSavePhoto => 'No se pudo guardar la foto';

  @override
  String get failedToUploadImage => 'No se pudo subir la imagen';

  @override
  String get profileSaved => 'Perfil guardado';

  @override
  String get failedToSaveProfile => 'No se pudo guardar el perfil';

  @override
  String get notAuthenticatedOrUserMissing =>
      'No autenticado o falta el usuario';

  @override
  String get noUserLoaded => 'No se ha cargado ningún usuario';

  @override
  String get motivationSectionTitle => 'Frase del día';

  @override
  String get groupSectionTitle => 'Grupos';

  @override
  String get clearAllTooltip => 'Borrar todas las notificaciones';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get clearAllConfirmTitle => '¿Borrar todo?';

  @override
  String get clearAllConfirmMessage =>
      '¿Quieres eliminar todas las notificaciones? Esta acción no se puede deshacer.';

  @override
  String get clearedAllSuccess => 'Se borraron todas las notificaciones';

  @override
  String get all => 'Todos';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get termsAndPrivacy =>
      'Al registrarte, aceptas nuestros Términos y la Política de Privacidad';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get welcomeTitle => '¡Bienvenido!';

  @override
  String get welcomeSubtitle =>
      'Crea una cuenta para comenzar a usar nuestra aplicación.';

  @override
  String get passwordWeak => 'Débil';

  @override
  String get passwordMedium => 'Media';

  @override
  String get passwordStrong => 'Fuerte';

  @override
  String get terms => 'Términos';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsAndPrivacyPrefix => 'Al registrarte, aceptas nuestros ';

  @override
  String get andSeparator => ' y ';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get loginWelcomeTitle => '¡Bienvenido de nuevo!';

  @override
  String get loginWelcomeSubtitle =>
      'Introduce tus credenciales para continuar.';

  @override
  String get forgotPasswordSubtitle =>
      'Introduce tu correo y te enviaremos un enlace de restablecimiento.';

  @override
  String get sendResetLink => 'Enviar enlace de restablecimiento';

  @override
  String get resetLinkSent => '¡Enlace de restablecimiento enviado!';

  @override
  String get noUpcomingHint => 'Prueba con otra categoría o amplía el rango.';

  @override
  String get hi => 'Hola';

  @override
  String get completed => 'Completados';

  @override
  String get showFourteenDays => '14 días';

  @override
  String get showThirtyDays => '30 días';

  @override
  String get meetings => 'Reuniones';

  @override
  String get tasks => 'Tareas';

  @override
  String get deadlines => 'Plazos';

  @override
  String get personal => 'Personal';

  @override
  String get statusDone => 'Hecho';

  @override
  String get statusCompleted => 'Completado';

  @override
  String get statusInProgress => 'En progreso';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusCancelled => 'Cancelado';

  @override
  String get statusOverdue => 'Atrasado';

  @override
  String get statusFinished => 'Finalizado';

  @override
  String completedSummary(Object done, Object total, Object percent) {
    return '$done de $total completados ($percent%)';
  }

  @override
  String get notifyMe => 'Notificarme';

  @override
  String get notifyMeOnSubtitle => 'Recibirás un recordatorio de este evento';

  @override
  String get notifyMeOffSubtitle => 'No se enviará ningún recordatorio';

  @override
  String get noInvitableUsers => 'No hay usuarios disponibles para invitar';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get noClientsYet => 'Aún no hay clientes';

  @override
  String get addYourFirstClient => 'Añade tu primer cliente a este grupo.';

  @override
  String get addClient => 'Añadir cliente';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get noServicesYet => 'Aún no hay servicios';

  @override
  String get createServicesSubtitle =>
      'Crea servicios que puedes asignar a las reservas.';

  @override
  String get addService => 'Añadir servicio';

  @override
  String get noDefaultDuration => 'Sin duración predeterminada';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get editClient => 'Editar cliente';

  @override
  String get createClient => 'Crear cliente';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameIsRequired => 'El nombre es obligatorio';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get saveClient => 'Guardar cliente';

  @override
  String failedWithReason(String reason) {
    return 'Error: $reason';
  }

  @override
  String get editService => 'Editar servicio';

  @override
  String get createService => 'Crear servicio';

  @override
  String get defaultMinutesLabel => 'Minutos predeterminados';

  @override
  String get defaultMinutesHint => 'p. ej., 45';

  @override
  String get colorLabel => 'Color';

  @override
  String get saveService => 'Guardar servicio';

  @override
  String get screenServicesClientsTitle => 'Servicios y clientes';

  @override
  String get tabClients => 'Clientes';

  @override
  String get tabServices => 'Servicios';

  @override
  String get clientsSectionTitle => 'Clientes de este grupo';

  @override
  String get servicesSectionTitle => 'Servicios de este grupo';

  @override
  String get activeClientsSection => 'Clientes activos';

  @override
  String get inactiveClientsSection => 'Clientes inactivos';

  @override
  String get activeServicesSection => 'Servicios activos';

  @override
  String get inactiveServicesSection => 'Servicios inactivos';

  @override
  String clientCreatedWithName(String name) {
    return 'Cliente creado: $name';
  }

  @override
  String serviceCreatedWithName(String name) {
    return 'Servicio creado: $name';
  }

  @override
  String clientUpdatedWithName(String name) {
    return 'Cliente actualizado: $name';
  }

  @override
  String serviceUpdatedWithName(String name) {
    return 'Servicio actualizado: $name';
  }

  @override
  String nClients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# clientes',
      one: '# cliente',
    );
    return '$_temp0';
  }

  @override
  String nServices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# servicios',
      one: '# servicio',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get sectionOverview => 'Resumen';

  @override
  String get sectionUpcoming => 'Próximos';

  @override
  String get sectionManage => 'Administrar';

  @override
  String get sectionStatus => 'Estado';

  @override
  String createdOnDay(String date) {
    return 'Creado el $date';
  }

  @override
  String get membersTitle => 'Miembros';

  @override
  String membersSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# en total',
      one: '# en total',
    );
    return '$_temp0';
  }

  @override
  String get servicesClientsTitle => 'Servicios y clientes';

  @override
  String get servicesClientsSubtitle => 'Crea y administra servicios/clientes';

  @override
  String get noCalendarWarning =>
      'Este grupo aún no tiene un calendario vinculado.';

  @override
  String get sectionFilters => 'Filtros';

  @override
  String get noMembersTitle => 'Sin miembros';

  @override
  String get noMembersMatchFilters =>
      'Ningún miembro coincide con estos filtros.';

  @override
  String get tryAdjustingFilters => 'Prueba ajustando los filtros de arriba.';

  @override
  String get statusAccepted => 'Aceptado';

  @override
  String get statusNotAccepted => 'No aceptado';

  @override
  String errorLoadingUser(String error) {
    return 'Error al cargar el usuario: $error';
  }

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get message => 'Mensaje';

  @override
  String get changeRole => 'Cambiar rol';

  @override
  String get removeFromGroup => 'Eliminar del grupo';

  @override
  String get roleOwner => 'Propietario';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleMember => 'Miembro';

  @override
  String get details => 'Detalles';

  @override
  String get edit => 'Editar';

  @override
  String get addToContacts => 'Agregar a contactos';

  @override
  String get share => 'Compartir';

  @override
  String get copiedToClipboard => '¡Copiado!';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get team => 'Equipo';

  @override
  String get teams => 'Equipos';

  @override
  String get calendars => 'Calendarios';

  @override
  String teamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# equipos',
      one: '# equipo',
    );
    return '$_temp0';
  }

  @override
  String calendarsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# calendarios',
      one: '# calendario',
    );
    return '$_temp0';
  }

  @override
  String notificationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# notificaciones',
      one: '# notificación',
    );
    return '$_temp0';
  }

  @override
  String get clearAllConfirm =>
      '¿Estás seguro de que deseas eliminar todas las notificaciones?';

  @override
  String get clearedAllNotifications =>
      'Todas las notificaciones han sido eliminadas.';

  @override
  String get error => 'Error';
}
