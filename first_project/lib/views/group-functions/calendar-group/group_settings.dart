import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupSettings extends StatefulWidget {
  final Group group;

  const GroupSettings({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  late bool _repetitiveEvents;
  late FirestoreService _storeService;
  late User groupOwner;
  late Group group;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the inherited widget in the didChangeDependencies method.
    final providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize the _storeService using the providerManagement.
    _storeService = FirestoreService.firebase(providerManagement);

    _initializeData();
  }

  Future<void> _initializeData() async {
    Group updatedGroup = await _getUpdatedGroup();
    setState(() {
      group = updatedGroup;
      _repetitiveEvents = group.repetitiveEvents;
    });
  }

  Future<Group> _getUpdatedGroup() async {
    Group? updatedGroup = await _storeService.getGroupFromId(widget.group.id);
    if (updatedGroup != null) {
      groupOwner = await _storeService.getOwnerFromGroup(updatedGroup);
    }
    return updatedGroup!;
  }

  Future<void> _updateGroup(Group groupUpdated) async {
    try {
      await _storeService.updateGroup(groupUpdated);

      // Fetch the updated group from Firestore
      Group? updatedGroup = await _storeService.getGroupFromId(groupUpdated.id);

      // Trigger a rebuild of the UI after the update is complete
      setState(() {
        // Update _repetitiveEvents and other UI-related variables if needed
        group = updatedGroup!;
        _repetitiveEvents = group.repetitiveEvents;
      });
    } catch (e) {
      print("Error updating group: $e");
      // Handle the error appropriately, e.g., show a snackbar or alert to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Settings'),
      ),
      body: FutureBuilder<Group?>(
        future: _getUpdatedGroup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading screen while fetching data.
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: Text(
                    'No data available')); // Handle the case when there's no data.
          } else {
            Group group = snapshot.data!;
            User owner = groupOwner; // Assuming owner is a property of Group
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: Text('Group Name'),
                  subtitle: Text(group.groupName),
                ),
                ListTile(
                  title: Text('Group Owner'),
                  subtitle: Text(owner.name), // Use the 'owner' object here
                ),
                ListTile(
                  title: Text('Repetitive Events'),
                  trailing: Switch(
                    value: group.repetitiveEvents,
                    onChanged: (value) {
                      setState(() {
                        _repetitiveEvents = value;
                        group = group.copyWith(repetitiveEvents: value);
                        _updateGroup(group);
                      });
                    },
                    activeColor: Colors
                        .blue, // Customize the color when switch is active
                    inactiveThumbColor: Colors
                        .grey, // Customize the color when switch is inactive
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Users'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        group.users.map((user) => Text(user.name)).toList(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
