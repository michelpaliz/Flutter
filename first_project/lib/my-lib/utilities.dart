import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import the http package
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Utilities {

  /** Load the costume fonts */
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

  /** Get the address suggestions for the search bar*/
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

  /** Show the image using the URL from firebase storage */
  static ImageProvider buildProfileImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('assets/images/default_profile.png');
    }
  }

  /** Select and generate a URL image for the image returns the URL of the image */
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

  static String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }
}
