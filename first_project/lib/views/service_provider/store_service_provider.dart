import 'package:flutter/material.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';

class StoreServiceProvider extends InheritedWidget {
  final StoreService storeService;

  StoreServiceProvider({
    required this.storeService,
    required Widget child,
  }) : super(child: child);

  static StoreServiceProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<StoreServiceProvider>();
    if (provider == null) {
      throw ('StoreServiceProvider was not found in the widget tree.');
    }
    return provider;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
