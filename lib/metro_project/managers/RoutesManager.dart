import 'package:flutter/material.dart';
import 'package:seconed_depi/metro_project/screens/MetroLinePage.dart';
import 'package:seconed_depi/metro_project/screens/MapPage.dart';

import '../screens/DetailsPage.dart';

class RoutesManager {
  static const String map = "/map";
  static const String home = "/home";
  static const String details = "/details";



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
      case details:
        return MaterialPageRoute(
          builder: (context) => DetailsPage(),
        );

    }
    return null;
  }
}