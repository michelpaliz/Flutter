import 'package:flutter/material.dart';

class RouteLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('Pushed route: ${route.settings.name}');
    if (previousRoute != null) {
      print('Previous route: ${previousRoute.settings.name}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('Popped route: ${route.settings.name}');
    if (previousRoute != null) {
      print('Previous route: ${previousRoute.settings.name}');
    }
  }
}
