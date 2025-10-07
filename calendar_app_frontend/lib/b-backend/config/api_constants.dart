// lib/utilities/constants/api_constants.dart

// How it works now
// If avatarsArePublic = true, it skips the extra /read-sas request and builds the URL directly from your CDN.
// If avatarsArePublic = false, it requests a read-SAS for private blobs.
// You can flip the flag anytime without touching the rest of your code.

class ApiConstants {
  static const String baseUrl = 'https://fastezcode.com/api'; // Backend API

  /// Base URL for public blob access via CDN
  static const String cdnBaseUrl = 'https://cdn.fastezcode.com/profile-images';

  /// If true, avatars are public and served from CDN;
  /// if false, must fetch short-lived read-SAS from API.
  static const bool avatarsArePublic = true;
}
