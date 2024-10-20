import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomAppointment extends Appointment {
  final String id;

  CustomAppointment({
    required DateTime startTime,
    required DateTime endTime,
    required String subject,
    required Color color,
    required this.id,
  }) : super(startTime: startTime, endTime: endTime, subject: subject, color: color);

    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'subject': subject,
      'color': color.value, // Store the color as an integer
    };
  }

  factory CustomAppointment.fromMap(Map<String, dynamic> json) {
    return CustomAppointment(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      subject: json['subject'],
      color: Color(json['color']),
    );
  }
}
