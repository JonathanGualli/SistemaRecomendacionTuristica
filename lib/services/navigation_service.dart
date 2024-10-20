import 'package:flutter/material.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigationService instance = NavigationService();

  Future<void> navigateToReplacementName(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<void> navigatePushName(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
