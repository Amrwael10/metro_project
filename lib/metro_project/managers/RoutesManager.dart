import 'package:flutter/material.dart';
import 'package:seconed_depi/metro_project/screens/LocationsPage.dart';
import 'package:seconed_depi/metro_project/screens/MetroLinePage.dart';
import 'package:seconed_depi/metro_project/screens/MapPage.dart';

import '../screens/DetailsPage.dart';
import '../screens/HomePage.dart';

class RoutesManager {
  static const String map = "/map";
  static const String home = "/home";
  static const String details = "/details";
  static const String metroline = "/metroline";
  static const String locations = "/locations";


  static Route? router(RouteSettings settings) {
    switch (settings.name) {
      case metroline:
        return MaterialPageRoute(
          builder: (context) => MetroLinePage(),
        );
      case map:
        return MaterialPageRoute(
          builder: (context) => MapPage(),
        );
      case details:
        return MaterialPageRoute(
          builder: (context) => DetailsPage(),
        );
        case home:
      return MaterialPageRoute(
        builder: (context) => Homepage(),
      );
      case locations:
        return MaterialPageRoute(
          builder: (context) => Locationspage(),
        );
    }
    return null;
  }
}