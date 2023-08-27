import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth/implements/auth_service.dart';
import '../../services/firestore/implements/firestore_service.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  AuthService authService = new AuthService.firebase();
  StoreService storeService = StoreService.firebase();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    AuthService.firebase()
        .getCurrentUserAsCustomeModel()
        .then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            width: 80, // Adjust this value to control the container's width
            height: 80, // Adjust this value to control the container's height
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/default_profile.png', // Replace with your image path
                ),
                fit: BoxFit.cover, // Set the fit mode for the image
              ),
            ),
          ),
          SizedBox(height: 5), // Add spacing between image and name
          Text(
            currentUser?.name ?? 'Guest',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 5), // Add spacing between name and email
          Text(
            currentUser?.email ?? '',
            style:
                TextStyle(color: Color.fromARGB(255, 2, 31, 72), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
