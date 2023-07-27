import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class Searcher extends StatefulWidget {
  const Searcher({Key? key}) : super(key: key);

  @override
  State<Searcher> createState() => _SearcherState();
}

class _SearcherState extends State<Searcher> {
  List<String> searchResults = [];
  String groupName = '';
  List<String> selectedUsers = [];
  List<User> userInGroup = []; // List to store selected users

  void searchUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      final List<String> foundUsers =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        searchResults = foundUsers;
      });
    } catch (e) {
      print('Error searching for users: $e');
    }
  }

  void addUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with the provided username found
        final userData = querySnapshot.docs.first.data();

        final user = User.fromJson(userData);

        setState(() {
          selectedUsers.add(
              user.name); // Store the user object in the selectedUsers list
        });

        print('User added: $user');
      } else {
        // User with the provided username not found
        print('User not found for username: $username');
      }
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  void removeUser(String user) {
    // Implement the logic to remove the user from the selectedUsers list
    // For this example, we will just print the username to the console.

    setState(() {
      selectedUsers.remove(user);
    });

    print('Remove user: $user');
  }

  void creatingGroup() {
    // Implement the logic to create the group with the appropriate attributes
    // using the groupName and selectedUsers list.

    // For this example, we will just print the group name and selected users to the console.
    print('Creating group: $groupName');
    print('Selected users: $selectedUsers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Search'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => groupName = value,
              decoration: InputDecoration(
                labelText: 'Enter group name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => searchUser(value),
              decoration: InputDecoration(
                labelText: 'Search for a person',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                return ListTile(
                  title: Text(user),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => addUser(user),
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () => removeUser(user),
                        icon: Icon(Icons.remove),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                creatingGroup();
              },
              child: Text("Create Group"),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Searcher(),
  ));
}
