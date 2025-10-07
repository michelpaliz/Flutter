// lib/b-backend/api/blob/blob_uploader.dart
import 'dart:convert';
import 'dart:io';

import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:http/http.dart' as http;

class UploadResult {
  final String photoUrl; // URL to display in UI
  final String blobName; // Store in DB as photoBlobName
  UploadResult({required this.photoUrl, required this.blobName});
}

/// scope: 'users' | 'groups'
/// resourceId: required when scope == 'groups' (the groupId)
Future<UploadResult> uploadImageToAzure({
  required String scope, // 'users' | 'groups'
  String? resourceId, // groupId when scope == 'groups'
  required File file,
  required String accessToken,
  String mimeType = 'image/jpeg',
  bool avatarsArePublic = ApiConstants.avatarsArePublic,
}) async {
  if (scope == 'groups' && (resourceId == null || resourceId.isEmpty)) {
    throw ArgumentError(
        'resourceId (groupId) is required when scope == "groups"');
  }

  // --- 1) Get upload SAS ---
  final String sasEndpoint = (scope == 'users')
      ? '${ApiConstants.baseUrl}/blob/users/me/upload-sas'
      : '${ApiConstants.baseUrl}/blob/groups/$resourceId/upload-sas';

  final sasResp = await http.post(
    Uri.parse(sasEndpoint),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'mimeType': mimeType,
      'strategy': 'versioned',
    }),
  );
  if (sasResp.statusCode != 200) {
    throw Exception(
        'Failed to get upload SAS: ${sasResp.statusCode} ${sasResp.body}');
  }
  final sasData = jsonDecode(sasResp.body) as Map<String, dynamic>;
  final uploadUrl = sasData['uploadUrl'] as String;
  final blobName = sasData['blobName'] as String;

  // --- 2) Upload to Azure ---
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
    throw Exception(
        'Azure upload failed: ${putResp.statusCode} ${putResp.body}');
  }

  // --- 3) Get display URL ---
  String viewUrl;
  if (avatarsArePublic) {
    // ✅ Use blobUrl from backend if provided
    final fromBackend = sasData['blobUrl'] as String?;
    if (fromBackend != null && fromBackend.isNotEmpty) {
      viewUrl = fromBackend;
    } else {
      // Fallback if backend didn't send it (unlikely)
      viewUrl = '${ApiConstants.cdnBaseUrl}/$blobName';
    }
  } else {
    final String readEndpoint = (scope == 'users')
        ? '${ApiConstants.baseUrl}/blob/users/me/read-sas?blobName=${Uri.encodeComponent(blobName)}'
        : '${ApiConstants.baseUrl}/blob/groups/$resourceId/read-sas?blobName=${Uri.encodeComponent(blobName)}';

    final readResp = await http.get(
      Uri.parse(readEndpoint),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (readResp.statusCode != 200) {
      throw Exception(
          'Failed to get read-SAS: ${readResp.statusCode} ${readResp.body}');
    }
    final readData = jsonDecode(readResp.body) as Map<String, dynamic>;
    viewUrl = (readData['url'] as String?) ?? '';
    if (viewUrl.isEmpty) {
      throw Exception('Read-SAS response missing URL');
    }
  }

  return UploadResult(photoUrl: viewUrl, blobName: blobName);
}
