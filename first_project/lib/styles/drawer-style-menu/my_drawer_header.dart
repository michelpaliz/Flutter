import 'dart:io';
import 'package:first_project/provider/provider_management.dart';
import 'package:first_project/lib/utilities.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../services/auth/implements/auth_service.dart';
import '../../services/firestore_database/implements/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  AuthService _authService = new AuthService.firebase();
  late FirestoreService _storeService;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the inherited widget in the didChangeDependencies method.
    final providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize the _storeService using the providerManagement.
    _storeService = FirestoreService.firebase(providerManagement);
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
            child: CircleAvatar(
              radius: 30, // Adjust the size as needed
              backgroundImage:
                  Utilities.buildProfileImage(_currentUser?.photoUrl),
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
