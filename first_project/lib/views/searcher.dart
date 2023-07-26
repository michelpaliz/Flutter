import 'package:flutter/material.dart';

class Searcher extends StatefulWidget {
  const Searcher({Key? key}) : super(key: key);

  @override
  State<Searcher> createState() => _SearcherState();
}

class _SearcherState extends State<Searcher> {
  List<String> searchResults = []; // List to store search results

  void searchUser(String username) {
    // Replace this function with your actual search logic to find users based on the username
    // For now, I'm using a dummy search result
    List<String> dummyResults = ['User 1', 'User 2', 'User 3', 'User 4'];
    setState(() {
      searchResults = dummyResults;
    });
  }

  void addUser(String user) {
    // Implement the logic to add the user to your desired data structure
    // For this example, I'm just printing the username to the console
    print('Add user: $user');
  }

  void removeUser(String user) {
    // Implement the logic to remove the user from your desired data structure
    // For this example, I'm just printing the username to the console
    print('Remove user: $user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Search'),
      ),
      body: Column(
        children: [
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
