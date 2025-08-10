import 'dart:convert';
import 'dart:io';

import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_rotues.dart';
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
  bool _refreshingAvatar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userManagement = Provider.of<UserManagement>(context);
    _currentUser = _userManagement.user;

    // Try to refresh a fresh SAS URL if we only have the blobName
    _refreshProfileImageIfNeeded();
  }

  Future<void> _refreshProfileImageIfNeeded() async {
    if (_refreshingAvatar) return;
    if (_currentUser == null) return;

    final blobName = _currentUser!.photoBlobName;
    final hasBlob = (blobName != null && blobName.isNotEmpty);
    final hasViewUrl =
        (_currentUser!.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty);

    if (!hasBlob || hasViewUrl) return;

    try {
      _refreshingAvatar = true;
      final auth = context.read<AuthProvider>();
      final accessToken = auth.lastToken;
      if (accessToken == null) return;

      final resp = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/blob/read-sas?blobName=${Uri.encodeComponent(blobName)}'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (resp.statusCode == 200) {
        final viewUrl =
            (jsonDecode(resp.body) as Map<String, dynamic>)['url'] as String;
        if (!mounted) return;
        setState(() {
          _currentUser = _currentUser!.copyWith(photoUrl: viewUrl);
        });
        _userManagement.setCurrentUser(_currentUser!);
      } else {
        debugPrint(
            '⚠️ Failed to refresh read SAS: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing avatar: $e');
    } finally {
      _refreshingAvatar = false;
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    _selectedImage = picked;
    await _uploadProfileImageToBackend(File(picked.path));
  }

  Future<void> _uploadProfileImageToBackend(File file) async {
    try {
      final auth = context.read<AuthProvider>();
      final accessToken = auth.lastToken;
      if (accessToken == null || _currentUser == null) return;

      const mimeType = 'image/jpeg';

      // 1) Get upload SAS
      final sasResp = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/blob/upload-sas'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mimeType': mimeType}),
      );
      if (sasResp.statusCode != 200) {
        throw Exception('Failed to get SAS: ${sasResp.body}');
      }
      final sasData = jsonDecode(sasResp.body) as Map<String, dynamic>;
      final uploadUrl = sasData['uploadUrl'] as String;
      final blobName = sasData['blobName'] as String;

      // 2) Upload bytes directly to Azure
      final bytes = await file.readAsBytes();
      final putResp = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'x-ms-blob-type': 'BlockBlob',
          'Content-Type': mimeType,
        },
        body: bytes,
      );
      if (putResp.statusCode != 201 && putResp.statusCode != 200) {
        throw Exception('Upload failed: ${putResp.statusCode} ${putResp.body}');
      }

      // 3) Get a short-lived READ SAS to display
      final readResp = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/blob/read-sas?blobName=${Uri.encodeComponent(blobName)}'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (readResp.statusCode != 200) {
        throw Exception('Failed to get read SAS: ${readResp.body}');
      }
      final viewUrl =
          (jsonDecode(readResp.body) as Map<String, dynamic>)['url'] as String;

      // 4) Persist both on backend (photoUrl is temporary; blobName is permanent)
      final updateResp = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/${_currentUser!.id}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'photoUrl': viewUrl,
          'photoBlobName': blobName,
        }),
      );
      if (updateResp.statusCode != 200) {
        debugPrint(
            '⚠️ User update warning: ${updateResp.statusCode} ${updateResp.body}');
      }

      // 5) Update local state
      if (!mounted) return;
      setState(() {
        _currentUser = _currentUser?.copyWith(
          photoUrl: viewUrl,
          photoBlobName: blobName,
        );
      });
      _userManagement.setCurrentUser(_currentUser!);
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      if (!mounted) return;
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

    final hasPhoto = (_currentUser?.photoUrl?.isNotEmpty ?? false);

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
              backgroundImage: hasPhoto
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
            style: TextStyle(color: emailTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
