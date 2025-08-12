import 'dart:convert';
import 'dart:io';

import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/blobUploader/blob_uploader.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:calendar_app_frontend/c-frontend/g-common/user_avatar.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  XFile? _selectedImage;
  User? _currentUser = User.empty();
  late UserManagement _userManagement;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userManagement = Provider.of<UserManagement>(context);
    _currentUser = _userManagement.user;
  }

  /// Fetch a read SAS URL for a given blob name (used only when avatarsArePublic == false)
  Future<String?> _fetchReadSas(String blobName) async {
    final auth = context.read<AuthProvider>();
    final accessToken = auth.lastToken;
    if (accessToken == null) return null;

    final resp = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}/blob/read-sas?blobName=${Uri.encodeComponent(blobName)}'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (resp.statusCode != 200) {
      debugPrint('⚠️ Failed to get read SAS: ${resp.statusCode} ${resp.body}');
      return null;
    }
    return (jsonDecode(resp.body) as Map<String, dynamic>)['url'] as String;
  }

  /// Pick an image and start upload
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    _selectedImage = picked;
    await _uploadProfileImageToBackend(File(picked.path));
  }

  /// Upload using the shared helper + PATCH the user
  Future<void> _uploadProfileImageToBackend(File file) async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthProvider>();
      final accessToken = auth.lastToken;
      if (accessToken == null || _currentUser == null) return;

      // 1) Upload to Azure (shared helper handles SAS + PUT + view URL)
      final result = await uploadImageToAzure(
        scope: 'users',
        file: file,
        accessToken: accessToken,
        // mimeType defaults to image/jpeg; uses 'versioned' filenames
      );

      // 2) Persist to backend
      final updateResp = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/users/${_currentUser!.id}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'photoUrl': result.photoUrl,
          'photoBlobName': result.blobName,
        }),
      );
      if (updateResp.statusCode != 200) {
        debugPrint(
            '⚠️ User update warning: ${updateResp.statusCode} ${updateResp.body}');
      }

      // 3) Update UI immediately
      if (!mounted) return;
      setState(() {
        _currentUser = _currentUser?.copyWith(
          photoUrl: result.photoUrl,
          photoBlobName: result.blobName,
        );
      });
      _userManagement.setCurrentUser(_currentUser!);
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final headerBackgroundColor =
        ThemeColors.getCardBackgroundColor(context).withOpacity(0.95);
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
            child: (_currentUser != null)
                ? UserAvatar(
                    user: _currentUser!,
                    // If avatarsArePublic == true, UserAvatar will just use the public URL in user.photoUrl.
                    // If false, it will call this to fetch a short-lived SAS.
                    fetchReadSas: _fetchReadSas,
                    radius: 30,
                  )
                : const CircleAvatar(radius: 30, child: Icon(Icons.person)),
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
            style: TextStyle(color: emailTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
