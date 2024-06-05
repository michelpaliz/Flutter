import 'dart:convert';

import 'package:first_project/models/event.dart';
import 'package:http/http.dart' as http;

class EventService {
  final String baseUrl = 'http://192.168.1.16:3000/api/events';

  Event? _event; // Update with your server URL

  get event => _event;

  Future<bool> createEvent(Event eventData) async {
    try {
      print('Creating event with data: ${eventData.toMap()}');

      final response = await http.post(
        Uri.parse('$baseUrl'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(eventData.toMap()),
      );

      if (response.statusCode == 201) {
        final createdEventData = Event.fromJson(jsonDecode(response.body));
        print('Event created successfully: $createdEventData');
        _event = createdEventData; // Store the created event
        return true;
      } else {
        print('Failed to create event: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error creating event: $error');
      throw Exception('An unexpected error occurred while creating the event.');
    }
  }

  Future<Event> getEventById(String eventId) async {
    print('Getting event with id: $eventId');

    final response = await http.get(Uri.parse('$baseUrl/$eventId'));

    if (response.statusCode == 200) {
      print('Event retrieved successfully: ${response.body}');
      return Event.fromJson(jsonDecode(response.body)); // Use fromJson() here
    } else {
      throw Exception('Failed to get event');
    }
  }

  Future<Event> updateEvent(String eventId, Event eventData) async {
    print('Updating event with id: $eventId');

    final response = await http.put(
      Uri.parse('$baseUrl/$eventId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(eventData.toMap()), // Use toMap() here
    );

    if (response.statusCode == 200) {
      print('Event updated successfully: ${response.body}');
      return Event.fromJson(jsonDecode(response.body)); // Use fromJson() here
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    print('Deleting event with id: $eventId');

    final response = await http.delete(Uri.parse('$baseUrl/$eventId'));

    if (response.statusCode == 200) {
      print('Event deleted successfully');
    } else {
      throw Exception('Failed to delete event');
    }
  }
}
