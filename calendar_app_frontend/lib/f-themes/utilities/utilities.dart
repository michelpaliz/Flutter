import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Utilities {
  /** Load custom fonts */
  static Future<void> loadCustomFonts() async {
    final fontLoader = FontLoader('bagel')
      ..addFont(rootBundle.load('assets/fonts/bagel_fat_one.ttf'));

    final fontLoader2 = FontLoader('lato')
      ..addFont(rootBundle.load('assets/fonts/lato.ttf'));

    final fontLoader3 = FontLoader('righteous')
      ..addFont(rootBundle.load('assets/fonts/righteous.ttf'));

    await fontLoader.load();
    await fontLoader2.load();
    await fontLoader3.load();
  }

  /** Get address suggestions for the search bar */
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

  /** Build a profile image widget */
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

  /** Build profile image for CircleAvatar */
  static ImageProvider buildProfileImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('assets/images/default_profile.png');
    }
  }

  static Widget buildProfileImageWidget(String url) {
    return CircleAvatar(
      backgroundImage: NetworkImage(url),
      radius: 20,
    );
  }

  static String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  static Future<Locale> getUserLocale() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      if (position.latitude >= -56.0 &&
          position.latitude <= 11.0 &&
          position.longitude >= -77.8 &&
          position.longitude <= -34.8) {
        // User is in South America
        return Locale('es');
      } else {
        return Locale('en');
      }
    } catch (e) {
      print("Error getting user location: $e");
      return Locale('en');
    }
  }

  /** Generate random ID */
  static String generateRandomId(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  static String getMonthDate(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  /** 
   * 📅 Format a DateTime into a string like "Apr 29, 2025" 
   */
  static String formatDate(DateTime date) {
    return "${getMonthAbbreviation(date.month)} ${date.day}, ${date.year}";
  }

  static String getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
