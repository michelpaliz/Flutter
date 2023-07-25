import 'package:flutter/material.dart';
import 'my_drawer_header.dart';
import 'my_drawer_list.dart';

class MyDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyHeaderDrawer(),
              MyDrawerList(context),
            ],
          ),
        ),
      ),
    );
  }
  
}


