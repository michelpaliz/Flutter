import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date

class GroupSettings extends StatelessWidget {
  final Group group;

  const GroupSettings({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupImage(),
            const SizedBox(height: 20),
            _buildInfoTile("Description", group.description),
            _buildInfoTile("Owner ID", group.ownerId),
            _buildInfoTile(
              "Created On",
              DateFormat.yMMMd().format(group.createdTime),
            ),
            _buildInfoTile("User Count", group.userIds.length.toString()),
            const SizedBox(height: 10),
            _buildSectionTitle("User Roles"),
            ...group.userRoles.entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text("User ID: ${entry.key}"),
                subtitle: Text("Role: ${entry.value}"),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Invited Users"),
            if (group.invitedUsers == null || group.invitedUsers!.isEmpty)
              const Text("No invited users."),
            ...group.invitedUsers!.entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text("User ID: ${entry.key}"),
                subtitle: Text("Status: ${entry.value.status}"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupImage() {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(group.photoUrl ?? ''),
        onBackgroundImageError: (_, __) => const Icon(Icons.group, size: 50),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
