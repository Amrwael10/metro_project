import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../managers/AssetsManager.dart';

class MapController extends GetxController {
  final transformationController = TransformationController().obs;

  void resetZoom() {
    transformationController.value.value = Matrix4.identity();
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapController());

    return Scaffold(
      appBar: AppBar(title: Text("Cairo metro map"),),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Obx(
                () => InteractiveViewer(
              transformationController: controller.transformationController.value,
              minScale: 1.0,
              maxScale: 5.0,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsManager.map),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

         
          Positioned(
            bottom: 70,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.black.withOpacity(0.7),
              onPressed: controller.resetZoom,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
