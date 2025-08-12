// lib/b-backend/api/blob/blob_uploader.dart
import 'dart:convert';
import 'dart:io';

import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:http/http.dart' as http;

class UploadResult {
  final String photoUrl; // what you show in UI
  final String blobName; // save to photoBlobName in DB
  UploadResult({required this.photoUrl, required this.blobName});
}

/// scope: 'users' or 'groups'
/// resourceId: groupId when scope == 'groups'; ignored for users
/// avatarsArePublic: if true, we build URL from CDN; else we request read-SAS
Future<UploadResult> uploadImageToAzure({
  required String scope, // 'users' | 'groups'
  String? resourceId, // groupId when scope == 'groups'
  required File file,
  required String accessToken,
  String mimeType = 'image/jpeg',
  bool avatarsArePublic = ApiConstants.avatarsArePublic,
}) async {
  // 1) get upload SAS
  final String endpoint = (scope == 'users')
      ? '${ApiConstants.baseUrl}/blob/users/me/upload-sas'
      : '${ApiConstants.baseUrl}/blob/groups/$resourceId/upload-sas';

  final sasResp = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'mimeType': mimeType,
      'strategy': 'versioned', // avoids CDN cache issues
    }),
  );
  if (sasResp.statusCode != 200) {
    throw Exception(
        'Failed to get upload SAS: ${sasResp.statusCode} ${sasResp.body}');
  }
  final sasData = jsonDecode(sasResp.body) as Map<String, dynamic>;
  final uploadUrl = sasData['uploadUrl'] as String;
  final blobName = sasData['blobName'] as String;

  // 2) PUT bytes to Azure
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

  // 3) Get display URL
  String viewUrl;
  if (avatarsArePublic) {
    viewUrl = '${ApiConstants.cdnBaseUrl}/$blobName';
  } else {
    final readResp = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}/blob/read-sas?blobName=${Uri.encodeComponent(blobName)}'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (readResp.statusCode != 200) {
      throw Exception(
          'Failed to get read-SAS: ${readResp.statusCode} ${readResp.body}');
    }
    viewUrl =
        (jsonDecode(readResp.body) as Map<String, dynamic>)['url'] as String;
  }

  return UploadResult(photoUrl: viewUrl, blobName: blobName);
}
