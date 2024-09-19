import 'package:first_project/models/user.dart';
import 'package:flutter/material.dart';

class AnimatedUsersList extends StatelessWidget {
  final List<User> users;

  const AnimatedUsersList({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Set height for horizontal scrolling
      padding: EdgeInsets.all(16.0), // Padding for the container
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: users.isEmpty
          ? Center(
              child: Text(
                'No users selected.',
                style: TextStyle(color: Colors.black),
              ),
            )
          : Container(
              height: 150, // Height of the scrollable user list
              padding: EdgeInsets.all(16.0), // Padding for the list
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserItem(users[index]);
                },
              ),
            ),
    );
  }

  // Method to build each user item
  Widget _buildUserItem(User user) {
    return Container(
      width: 50, // Set a fixed width for each user card
      margin: EdgeInsets.symmetric(horizontal: 8.0), // Add space between each user card
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
        children: [
          CircleAvatar(
            radius: 30, // Size of the avatar (profile picture)
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : AssetImage('assets/images/default_profile.png') as ImageProvider, // Default profile picture
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(height: 8.0), // Space between the image and the name
          Text(
            user.userName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
