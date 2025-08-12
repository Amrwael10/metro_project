import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:geocoding/geocoding.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: (){
                  getlocation();
                },
                child: Text('show location'))
          ],
        ),
      ),
    );
  }

  void getlocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Get.snackbar('Error' , 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Get.snackbar('Error' , 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Get.snackbar(
          'Error',
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    print('${position.latitude} : ${position.longitude} : ${position.accuracy}');

    //show map
    //search by position
    final url = Uri.parse('geo:0,0?q=${position.latitude},${position.longitude}');

    // search by name
    // final url = Uri.parse('geo:0,0?q=cairo+stadium+egypt');
    launchUrl(url);


    // show address
    // final place = await placemarkFromCoordinates(position.latitude, position.longitude);
    // print('${place.first.name} : ${place.first.locality}');

  }




  // exceptions => environments
  void test(){
    try {
      final names = ['amr' , 'ali' , 'ahmed'];
      for(int i = 0 ; i < 4 ; i++){
        print(names[i]);
      }
    } catch (e) {
      print(e);
    }
  }

}
