import 'package:flutter/material.dart';
import 'package:seconed_depi/metro_project/screens/HomePage.dart';
import 'package:seconed_depi/metro_project/screens/MapPage.dart';

class RoutesManager {
  static const String map = "/map";
  static const String home = "/home";


  static Route? router(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      case map:
        return MaterialPageRoute(
          builder: (context) => MapPage(),
        );
    }
    return null;
  }
}