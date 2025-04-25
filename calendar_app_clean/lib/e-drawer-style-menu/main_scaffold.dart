import 'package:flutter/material.dart';

import 'my_drawer.dart';

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? fab;

  const MainScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: MyDrawer(), // 👈 Reuse your existing drawer
      body: body,
      floatingActionButton: fab,
    );
  }
}
