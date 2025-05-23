import 'dart:io';

import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../a-models/user_model/user.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  XFile? _selectedImage;
  User? _currentUser = User.empty(); // Assuming you have a User.empty() factory
  late UserManagement _userManagement;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userManagement = Provider.of<UserManagement>(context);
    User? user = _userManagement.user;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  // Future implementation: Upload image to your backend
  Future<void> _uploadProfileImageToBackend(File file) async {
    try {
      // TODO: Implement backend call to upload image and update user photoUrl
      // final response = await backend.uploadProfilePicture(file, _currentUser!.id);

      final simulatedDownloadUrl =
          'https://your-backend-url.com/uploads/${_currentUser!.id}.jpg';

      setState(() {
        _currentUser = _currentUser?.copyWith(photoUrl: simulatedDownloadUrl);
      });

      // Optionally update via UserManagement or call update user API
      _userManagement.setCurrentUser(_currentUser!);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });

      await _uploadProfileImageToBackend(File(pickedImage.path));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Decide colors based on theme
    final headerBackgroundColor =
        isDarkMode ? AppDarkColors.background : AppColors.background;
    final nameTextColor =
        isDarkMode ? AppDarkColors.textPrimary : AppColors.textPrimary;
    final emailTextColor =
        isDarkMode ? AppDarkColors.textSecondary : AppColors.textSecondary;

    return Container(
      color: headerBackgroundColor,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: (_currentUser?.photoUrl?.isNotEmpty ?? false)
                  ? NetworkImage(_currentUser!.photoUrl!)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _currentUser?.name ?? 'Guest',
            style: TextStyle(
              color: nameTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _currentUser?.email ?? '',
            style: TextStyle(
              color: emailTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
