
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source){
    appointments = source;
  }

  // Method to sort appointments by startTime
  sortAppointmentsByStartTime() {
    appointments?.sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}
