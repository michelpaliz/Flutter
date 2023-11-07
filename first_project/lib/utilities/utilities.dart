import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import the http package
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Utilities {
  static Future<List<String>> getAddressSuggestions(String pattern) async {
    final baseUrl = Uri.parse('https://nominatim.openstreetmap.org/search');
    final queryParameters = {
      'format': 'json',
      'q': pattern,
    };

    final response =
        await http.get(baseUrl.replace(queryParameters: queryParameters));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final suggestions =
          data.map((item) => item['display_name'] as String).toList();
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Appointment _getCalendarDataSource(
      String,
      id,
      String title,
      DateTime startDate,
      DateTime endDate,
      int colorIndex,
      RecurrenceRule? recurrenceRule) {
    late Appointment appointment;

    // Iterate through each event
    // Check if the event has a recurrence rule
    if (recurrenceRule != null) {
      // Generate recurring appointments based on the recurrence rule
      final appointments = _generateRecurringAppointment(
          title, startDate, endDate, colorIndex, recurrenceRule);
      appointment = (appointments);
    } else {
      // If the event doesn't have a recurrence rule, add it as a single appointment
      appointment = (Appointment(
        id: id, // Assign a unique ID here
        startTime: startDate,
        endTime: endDate,
        subject: title,
        color: ColorManager().getColor(colorIndex),
      ));
    }

    return appointment;
  }

  Appointment _generateRecurringAppointment(String title, DateTime startDate,
      DateTime endDate, int colorIndex, RecurrenceRule recurrenceRule) {
    late final Appointment recurringAppointment;

    // Get the start date and end date from the event
    final startDateFetched = startDate;
    final endDateFetched = endDate;

    // Get the recurrence rule details
    final recurrenceRuleFetched = recurrenceRule;
    final repeatInterval = recurrenceRuleFetched.repeatInterval ??
        1; // Provide a default value of 1 if null
    final untilDate = recurrenceRuleFetched.untilDate;

    // Generate recurring appointments until the specified end date (if provided)
    DateTime currentStartDate = startDateFetched;
    while (untilDate == null || currentStartDate.isBefore(untilDate)) {
      recurringAppointment = (Appointment(
        startTime: currentStartDate,
        endTime: endDateFetched,
        subject: title,
        color: ColorManager().getColor(colorIndex),
      ));
      currentStartDate = currentStartDate.add(Duration(days: repeatInterval));
    }

    return recurringAppointment;
  }

  /*** This function shows the image URL from my FirebaseStorage returns a Widget */
  static Widget widgetbuildProfileImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl:
          imageUrl.isNotEmpty ? imageUrl : 'assets/images/default_profile.png',
      imageBuilder: (context, imageProvider) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  static ImageProvider buildProfileImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('assets/images/default_profile.png');
    }
  }

  static Future<String> pickAndUploadImageGroup(
      String groupID, XFile? imageFile) async {
    if (imageFile == null) {
      throw 'No image file selected'; // Handle the case where no image is selected
    }

    try {
      // Reference to the Firebase Storage bucket where you want to upload the image
      final storageReference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('group_images/${groupID}.jpg');

      // Upload the image to Firebase Storage using the provided XFile
      await storageReference.putFile(File(imageFile.path));

      // Get the download URL of the uploaded image
      final imageUrl = await storageReference.getDownloadURL();

      return imageUrl; // Return the image URL
    } catch (e) {
      print('Error uploading image: $e');
      throw 'Image upload failed'; // Throw an exception in case of an error
    }
  }
}
