import 'package:flutter/material.dart';
import 'package:seconed_depi/metro_project/managers/AssetsManager.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ترانس
        elevation: 0,
        title: const Text(
          "Metro Map",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Zoomable map
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsManager.map),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Faint gradient overlay for top readability
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
