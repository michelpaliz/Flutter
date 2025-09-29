// lib/c-frontend/b-calendar-section/screens/profile/profile_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:hexora/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:hexora/b-backend/api/blobUploader/blob_uploader.dart';
import 'package:hexora/b-backend/api/config/api_constants.dart';
import 'package:hexora/c-frontend/utils/user_avatar.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
import 'package:hexora/e-drawer-style-menu/main_scaffold.dart';
import 'package:hexora/f-themes/palette/app_colors.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<UserManagement>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _usernameCtrl.text = user.userName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final auth = context.read<AuthProvider>();
      final token = auth.lastToken;
      final userMgmt = context.read<UserManagement>();
      final user = userMgmt.user;

      if (token == null || user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.notAuthenticatedOrUserMissing)),
        );
        return;
      }

      final result = await uploadImageToAzure(
        scope: 'users',
        file: File(picked.path),
        accessToken: token,
      );

      final commitResp = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/users/me/photo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'blobName': result.blobName}),
      );

      if (!mounted) return;

      if (commitResp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${loc.failedToSavePhoto}: ${commitResp.statusCode}')),
        );
        return;
      }

      final updatedUserJson =
          jsonDecode(commitResp.body) as Map<String, dynamic>;
      final updated = user.copyWith(
        photoUrl: updatedUserJson['photoUrl'] ?? result.photoUrl,
        photoBlobName: updatedUserJson['photoBlobName'] ?? result.blobName,
      );

      userMgmt.updateCurrentUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.photoUpdated)),
      );
      setState(() {}); // refresh avatar
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.failedToUploadImage}: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final loc = AppLocalizations.of(context)!;
    final userMgmt = context.read<UserManagement>();
    final user = userMgmt.user;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final updated = user.copyWith(
        name: _nameCtrl.text.trim(),
        userName: _usernameCtrl.text.trim(),
      );
      final ok = await userMgmt.updateUser(updated);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.profileSaved)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.failedToSaveProfile)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<UserManagement>().user;
    final textColor = ThemeColors.getTextColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        ThemeColors.getCardBackgroundColor(context).withOpacity(0.95);

    if (user == null) {
      // Keep a minimal fallback, but still use MainScaffold to avoid back button.
      return MainScaffold(
        showAppBar: false,
        body: Center(child: Text(loc.noUserLoaded)),
      );
    }

    return MainScaffold(
      showAppBar:
          false, // ← matches AgendaScreen: no back button, uses drawer shell
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: ProfileHeader(
                title: loc.profile,
                subtitle: user.email,
                // If you prefer a greeting, flip to: '${loc.hi} ${user.name}'
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  UserAvatar(
                    user: user,
                    fetchReadSas: (_) async =>
                        null, // public avatars: no SAS needed
                    radius: 48,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _changePhoto,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppDarkColors.primary
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Info card section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _LabeledField(
                      label: loc.displayName,
                      controller: _nameCtrl,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: loc.username,
                      controller: _usernameCtrl,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: loc.email,
                      controller: TextEditingController(text: user.email),
                      textColor: textColor,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Save button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveProfile,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? loc.saving : loc.save),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (_saving) {
                        return (isDark
                                ? AppDarkColors.secondary
                                : AppColors.secondary)
                            .withOpacity(0.6);
                      }
                      return isDark ? AppDarkColors.primary : AppColors.primary;
                    }),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const ProfileHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVar = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(color: onSurfaceVar)),
        ],
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color textColor;
  final bool enabled;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.textColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: ThemeColors.getLighterInputFillColor(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: TextStyle(color: textColor),
    );
  }
}
