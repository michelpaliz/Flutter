import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../services/auth/implements/auth_service.dart';
import '../../services/firestore/implements/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  AuthService _authService = new AuthService.firebase();
  StoreService _storeService = StoreService.firebase();
  User? _currentUser;
  // Define a variable to store the selected image.
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    _currentUser = _authService.costumeUser;
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      try {
        // Reference to the Firebase Storage bucket where you want to upload the image
        final storageReference = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profile_images/${_currentUser!.id}.jpg');

        // Upload the image to Firebase Storage
        await storageReference.putFile(File(pickedImage.path));

        // Get the download URL of the uploaded image
        final imageUrl = await storageReference.getDownloadURL();

        // Update the user's profile picture URL in your AuthService
        _currentUser?.photoUrl = imageUrl;

        // Update the user's profile information in your StoreService
        _storeService.updateUser(_currentUser!);

        // Update the UI with the new image
        setState(() {
          _selectedImage = pickedImage;
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage, // Call the _pickImage function when tapped
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 100, // Set the maximum width
                maxHeight: 100, // Set the maximum height
              ),
              child: Image.network(
                (_currentUser?.photoUrl != null &&
                        _currentUser?.photoUrl.isNotEmpty)
                    ? _currentUser?.photoUrl
                    : 'https://firebasestorage.googleapis.com/v0/b/firstapp-75986.appspot.com/o/default_profile.png?alt=media&token=7c68d367-0c2a-4f87-b0b0-bef21199e2a0&_gl=1*1d4t8ef*_ga*MjEyNjIzODA4i4xNjc0MTQxMjc2*_ga_CW55HF8NVT*MTY5ODQyOTE2My4yMTkuMS.4LjAuMA..',
                errorBuilder: (context, error, stackTrace) {
                  // Provide a default image when the network image fails to load
                  return Image.asset(
                      'assets/images/default_profile.png'); // Replace with your default image asset
                },
              ),
            ),
          ),
          SizedBox(height: 5), // Add spacing between image and name
          Text(
            _currentUser?.name ?? 'Guest',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 5), // Add spacing between name and email
          Text(
            _currentUser?.email ?? '',
            style:
                TextStyle(color: Color.fromARGB(255, 2, 31, 72), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
