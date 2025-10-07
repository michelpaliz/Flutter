import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexora/b-backend/blobUploader/blobRepository.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:image_picker/image_picker.dart';

class PhotoController extends ChangeNotifier {
  final BlobRepository _repo;
  final UserDomain _userMgmt;
  final GroupDomain _groupMgmt;

  PhotoController({
    required BlobRepository repo,
    required UserDomain userDomain,
    required GroupDomain groupDomain,
  })  : _repo = repo,
        _userMgmt = userDomain,
        _groupMgmt = groupDomain;

  bool busy = false;
  XFile? pickedImage;

  Future<void> pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      pickedImage = img;
      notifyListeners();
    }
  }

  void clear() {
    pickedImage = null;
    notifyListeners();
  }

  /// Upload avatar and update userDomain.
  Future<bool> uploadUserAvatar(BuildContext context) async {
    if (pickedImage == null) return false;
    final u = _userMgmt.user;
    if (u == null) return false;

    busy = true;
    notifyListeners();
    try {
      final committed =
          await _repo.uploadUserAvatar(file: File(pickedImage!.path));

      // Update local user model & notify
      final updated = u.copyWith(
        photoUrl: committed.photoUrl,
        // If your User model has `photoBlobName`, include it:
        // photoBlobName: committed.blobName,
      );
      _userMgmt.updateCurrentUser(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated')),
      );
      clear();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $e')),
      );
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Upload group photo and update groupDomain.
  Future<bool> uploadGroupPhoto(BuildContext context,
      {required String groupId}) async {
    if (pickedImage == null) return false;

    busy = true;
    notifyListeners();
    try {
      final committed = await _repo.uploadGroupPhoto(
        groupId: groupId,
        file: File(pickedImage!.path),
      );

      // Push to groupDomain (keeps currentGroup + list in sync)
      _groupMgmt.updateGroupPhoto(
        groupId: groupId,
        photoUrl: committed.photoUrl,
        photoBlobName: committed.blobName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group photo updated')),
      );
      clear();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update group photo: $e')),
      );
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
