import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GroupImageSection extends StatelessWidget {
  final String imageURL;
  final XFile? selectedImage;
  final VoidCallback onPickImage;

  const GroupImageSection({
    required this.imageURL,
    required this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPickImage,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: selectedImage != null ? Colors.transparent : null,
          backgroundImage: imageURL.isNotEmpty
              ? CachedNetworkImageProvider(imageURL) as ImageProvider<Object>?
              : selectedImage != null
                  ? FileImage(File(selectedImage!.path))
                  : null,
          child: imageURL.isEmpty && selectedImage == null
              ? const Icon(Icons.add_a_photo, size: 50, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
