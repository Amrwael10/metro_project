import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:seconed_depi/locations/map_page.dart';

class SecondPage extends StatelessWidget {
  SecondPage({super.key});

  final cont1 = TextEditingController();
  final cont2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: cont1,
              decoration: InputDecoration(
                hintText: 'address 1',
                suffixIcon: IconButton(onPressed: () async {
                  final address = await Get.to(Map());
                  cont1.text = address;
                }, icon: Icon(Icons.map))
              ),
            ),
            TextField(
              controller: cont2,
              decoration: InputDecoration(
                  hintText: 'address 2',
                  suffixIcon: IconButton(onPressed: () async {
                    final address = await Get.to(Map());
                    cont2.text = address;
                  }, icon: Icon(Icons.map))
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final locations = await locationFromAddress("Gronausestraat 710, Enschede");
                  print('${locations.first.latitude} : ${locations.first.longitude}');

                  final locations2 = await locationFromAddress("Gronausestraat 710, Enschede");
                  print('${locations2.first.latitude} : ${locations2.first.longitude}');

                  final distance =  Geolocator.distanceBetween(locations.first.latitude, locations.first.longitude, locations2.first.latitude, locations2.first.longitude);
                  print('distance = ${distance/1000}');
                } on PlatformException catch(e){
                  Get.snackbar('Error','can not get your location');
                }
                catch (e) {
                  Get.snackbar('Error','general error');
                }
              },
              child: Text('Show'),
            ),
          ],
        ),
      ),
    );
  }
}
