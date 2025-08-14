import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

// Import your stations lists
import 'package:seconed_depi/metro_project/data/stations.dart';
import 'package:seconed_depi/metro_project/data/data.dart';
import 'package:seconed_depi/metro_project/screens/MetroLinePage.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final streetController = TextEditingController();
  var enableShowRegion = false.obs;
  var nearestStationName = "".obs;
  var nearestStationDistance = "".obs;

  final List<Station> cairoStations = [
    ...line1Stations,
    ...line2Stations,
    ...lineThreeOldStations,
    ...lineThreeNewStations,
  ];


  Station? nearestStationname;
  Future<void> showRegionFromInput() async {
    String address = streetController.text.trim();

    if (address.isEmpty) {
      print("Please enter an address.");
      return;
    }

    double? userLat;
    double? userLng;

    try {
      if (kIsWeb) {
        // Web: use OpenStreetMap Nominatim API
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address + ", Egypt")}&format=json&limit=1'
        );
        final response = await http.get(url, headers: {
          'User-Agent': 'MetroApp/1.0 (your@email.com)'
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            userLat = double.parse(data[0]['lat']);
            userLng = double.parse(data[0]['lon']);
          } else {
            Get.snackbar("Error","Address not found.");
            return;
          }
        } else {
          print("Error fetching location from API.");
          return;
        }
      } else {
        // Mobile: use geocoding package
        final locations = await geocoding.locationFromAddress("$address, Egypt");
        if (locations.isNotEmpty) {
          userLat = locations.first.latitude;
          userLng = locations.first.longitude;
        } else {
          Get.snackbar("Error","Address not found.");
          return;
        }
      }

      // === Find nearest station ===
      Station? nearestStation;
      double minDistance = double.infinity;

      for (var station in cairoStations) {
        if (station.lat == null || station.long == null) continue;

        double distance = Geolocator.distanceBetween(
          userLat!, userLng!, station.lat!, station.long!,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestStation = station;
        }
      }

      if (nearestStation != null) {
        Get.snackbar("","Nearest station: ${nearestStation.name}");
        print("Lat: ${nearestStation.lat}, Lng: ${nearestStation.long}");
        Get.snackbar("","Distance: ${minDistance.toStringAsFixed(2)} meters");
        nearestStationname = nearestStation;
      } else {
        Get.snackbar("","No stations found.");
      }
    } catch (e) {
      Get.snackbar("Error","Can't finding location: $e");
    }
  }

  @override
  void dispose() {
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Choose your location")),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (text) {
                enableShowRegion.value = text.trim().isNotEmpty;
              },
              controller: streetController,
              decoration: InputDecoration(
                hintText: 'Enter the destination you want to go.',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
                  () => ElevatedButton(
                onPressed: enableShowRegion.value
                    ? () {
                  FocusScope.of(context).unfocus();
                  showRegionFromInput();
                }
                    : null,
                child: const Text('Show nearest station'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nearestStationname != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MetroLinePage(
                        preSelectedDestination: nearestStationname!,
                      ),
                    ),
                  );
                } else {
                  Get.snackbar("Error", "Please find nearest station first");
                }
              },
              child: const Text('Go to Metro Line Page'),
            ),
            SizedBox(height: 20.h),
            Obx(
                  () => nearestStationName.value.isNotEmpty
                  ? Text(
                "Nearest station: ${nearestStationName.value}\nDistance: ${nearestStationDistance.value}",
                style: TextStyle(fontSize: 16.sp),
              )
                  : const SizedBox.shrink(),
            ),

          ],
        ),
      ),
    );
  }
}
