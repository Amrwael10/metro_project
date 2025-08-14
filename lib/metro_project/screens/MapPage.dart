import 'package:flutter/material.dart';
import 'package:seconed_depi/metro_project/managers/AssetsManager.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Expanded(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(AssetsManager.map)),
          ),
        ),
      ),
    );
  }
}
