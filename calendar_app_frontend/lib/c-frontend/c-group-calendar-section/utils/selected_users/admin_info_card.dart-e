import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:flutter/material.dart';

class AdminInfoCard extends StatelessWidget {
  final User? currentUser;
  const AdminInfoCard({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final url = currentUser?.photoUrl;
    final ImageProvider? provider = _safeImageProvider(url);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(
            currentUser?.userName ?? '—',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Administrator'),
          leading: CircleAvatar(
            backgroundImage: provider, // null if bad/empty URL
            child: provider == null
                ? _InitialsOrIcon(name: currentUser?.userName)
                : null,
          ),
        ),
      ),
    );
  }
}

ImageProvider? _safeImageProvider(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final u = Uri.tryParse(url);
  final looksOk = u != null && u.hasScheme && (u.host.isNotEmpty);
  return looksOk ? NetworkImage(url) : null;
}

class _InitialsOrIcon extends StatelessWidget {
  final String? name;
  const _InitialsOrIcon({this.name});
  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return initials.isNotEmpty
        ? Text(initials, style: const TextStyle(fontWeight: FontWeight.w600))
        : const Icon(Icons.groups_outlined);
  }
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) return '';
  final parts = name.trim().split(RegExp(r'\s+'));
  final a = parts[0].isNotEmpty ? parts[0][0] : '';
  final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
  return (a + b).toUpperCase();
}
