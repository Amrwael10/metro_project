import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:seconed_depi/metro_project/screens/MetroLinePage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/data.dart';
import '../data/stations.dart';

class Locationspage extends StatefulWidget {
   const Locationspage({super.key});

  @override
  State<Locationspage> createState() => _LocationspageState();
}

class _LocationspageState extends State<Locationspage> {
   final streetController = TextEditingController();
   var enableShowRegion = false.obs;
   var nearestStationName = "";

   final List<Station> cairoStations = [
     ...line1Stations,
     ...line2Stations,
     ...lineThreeOldStations,
     ...lineThreeNewStations,
   ];

   Future<void> showRegionFromInput() async {
     final double userLat;
     final double userLng;

     try {
         final locations = await geocoding.locationFromAddress("${streetController.text}, Egypt");
         if (locations.isNotEmpty) {
           userLat = locations.first.latitude;
           userLng = locations.first.longitude;
         } else {
           Get.snackbar("Error","Address with this name is not found.");
           return;
         }

         // === Find nearest station ===
         var minDistance = double.infinity;
         for (var station in cairoStations) {
           var distance = Geolocator.distanceBetween(
             userLat,
             userLng,
             station.lat,
             station.long,
           );

         if (distance < minDistance) {
           minDistance = distance;
           nearestStationName = station.EnglishName;
         }
       }

       if (nearestStationName.isNotEmpty) {
         print('nearest destination is : $nearestStationName');
         Get.to(MetroLinePage() , arguments: nearestStationName , transition: Transition.rightToLeftWithFade);
       }
     }

     catch (e) {
       Get.snackbar("Error","Can't find your location: $e");
     }
   }

   void DesPosition() async {
     bool serviceEnabled;
     LocationPermission permission;

     // Check if location services are enabled
     serviceEnabled = await Geolocator.isLocationServiceEnabled();
     if (!serviceEnabled) {
       throw Exception('Location services are disabled.');
     }

     // Check permission
     permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied) {
         throw Exception('Location permissions are denied.');
       }
     }

     if (permission == LocationPermission.deniedForever) {
       throw Exception('Location permissions are permanently denied.');
     }

     // Get location
     final pos = await geocoding.locationFromAddress("${streetController.text}, Egypt");
     final url = Uri.parse('geo:0,0?q=$pos');
     launchUrl(url);
   }


  @override
  void dispose() {
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("choose your location"),
      ),
      body: Column(
        children: [
          TextField(
          onChanged: (a) {
        enableShowRegion.value = a.isNotEmpty;
      },
      controller: streetController,
      decoration: InputDecoration(
        hintText: 'Enter the destination want to go.',
        filled: true,
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,),
        suffixIcon: IconButton(
          onPressed: (){
            enableShowRegion.value ? DesPosition() : null;
          },
          icon: Icon(Icons.map),
        ),
      ),
    ),
      SizedBox(height: 12.h,),
      ElevatedButton(
        onPressed: (){
          enableShowRegion.value ? showRegionFromInput(): null;
        },
        child: Text('show nearest station to your destination'),
      ),],),);
  }
}
