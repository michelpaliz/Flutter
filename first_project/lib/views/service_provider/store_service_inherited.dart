import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:flutter/material.dart';

class StoreServiceInherited extends InheritedWidget {
  final StoreService storeService;

  StoreServiceInherited({
    required this.storeService,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static StoreServiceInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StoreServiceInherited>()!;
  }
}
