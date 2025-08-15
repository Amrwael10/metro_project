import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:seconed_depi/metro_project/data/data.dart';
import 'package:seconed_depi/metro_project/managers/AssetsManager.dart';
import 'package:seconed_depi/metro_project/managers/ColorsManager.dart';
import 'package:seconed_depi/metro_project/managers/RoutesManager.dart';
import 'package:seconed_depi/metro_project/screens/DetailsPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/Algo.dart';
import '../data/stations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final streetController = TextEditingController();
  var enableShowRegion = false;
  var nearestStationName = "".obs;
  final startController = TextEditingController();
  final endController = TextEditingController();
  var enable1 = false;
  var enable2 = false;
  final BasicOutputMessages = <String>[].obs;
  final ExtraOutputMessages = <String>[].obs;
  // final a5rtextbutton = "".obs;
  final startStationLink = "".obs;
  final endStationLink = "".obs;
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
      final locations = await geocoding.locationFromAddress(
        "${streetController.text}, Egypt",
      );
      if (locations.isNotEmpty) {
        userLat = locations.first.latitude;
        userLng = locations.first.longitude;
      } else {
        Get.snackbar("Error", "Address with this name is not found.");
        return;
      }

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
          nearestStationName.value = station.EnglishName;
        }
      }

      if (nearestStationName.isNotEmpty) {
        // print('nearest destination is : $nearestStationName');
        endController.text = nearestStationName.value;
      }
    } catch (e) {
      Get.snackbar("Error", "Can't find your location: $e");
    }
  }

  String _createGoogleMapsUrl(String stationName) {
    return "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$stationName Metro Station Cairo')}";
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
    final pos = await geocoding.locationFromAddress(
      "${streetController.text}, Egypt",
    );
    final url = Uri.parse('geo:0,0?q=$pos');
    launchUrl(url);
  }

  // metro stations
  final stations = [...line1, ...line2, ...line_three_old, ...list_three_new];

  Future<Station?> getNearestStation(
    Position userPos,
    List<Station> stations,
  ) async {
    Station? nearest;
    double shortestDistance = double.infinity;

    for (var station in stations) {
      double distance = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        station.lat,
        station.long,
      );

      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearest = station;
      }
    }
    return nearest;
  }

  void getBasicData() {
    final metroGraph = MetroGraph();
    final graph = metroGraph.buildMetroGraph();

    final shortestPath = metroGraph.findShortestPath(
      graph,
      startController.text.trim().toLowerCase(),
      endController.text.trim().toLowerCase(),
    );

    if (startController.text == endController.text) {
      Get.snackbar('Oops', 'your destination can not be your Starting station');
      return;
    }

    // basic data
    final stopCount = shortestPath.length - 1;
    final time = stopCount * 2;
    var ticketPrice = 8;
    if (stopCount > 23) {
      ticketPrice = 20;
    } else if (stopCount > 16 && stopCount <= 23) {
      ticketPrice = 15;
    } else if (stopCount >= 10 && stopCount <= 16) {
      ticketPrice = 10;
    }

    final info = [
      "🚉 Number of stations: $stopCount",
      "💰 Ticket price: $ticketPrice EGP",
      if (time < 60)
        "⏱️ Estimated time: $time mins"
      else
        "⏱️ Estimated time: ${time ~/ 60} hour(s) and ${time % 60} mins",
    ];
    BasicOutputMessages.assignAll([...info]);
  }

  String? _computeDirection(String start, String end) {
    final linesMap = <String, List<String>>{
      "Line 1": line1,
      "Line 2": line2,
      "Line 3 (Old)": line_three_old,
      "Line 3 (New)": list_three_new,
    };

    for (final entry in linesMap.entries) {
      final original = entry.value;
      final lower = original.map((s) => s.toLowerCase()).toList();

      final si = lower.indexOf(start);
      final ei = lower.indexOf(end);

      if (si != -1 && ei != -1) {
        return (si < ei) ? original.last : original.first;
      }
    }

    return null;
  }

  void getExtraData() {
    final metroGraph = MetroGraph();
    final graph = metroGraph.buildMetroGraph();

    final startRaw = startController.text.trim();
    final endRaw = endController.text.trim();

    final start = startRaw.toLowerCase();
    final end = endRaw.toLowerCase();

    if (start == end) {
      Get.snackbar('Oops', 'Your destination cannot be your starting station');
      return;
    }

    final shortestPath = metroGraph.findShortestPath(graph, start, end);
    final routeDetails = metroGraph.routeWithTransfers(shortestPath);

    String? direction = _computeDirection(start, end);

    direction ??= shortestPath.isNotEmpty ? shortestPath.last : 'Unknown';
    Get.to(
      () => const DetailsPage(),
      arguments: {'stations': routeDetails, 'direction': direction},
    );
  }

  Future<Position> _determinePosition() async {
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
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    startController.dispose();
    endController.dispose();
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsManager.background),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => nearestStationName.value.isNotEmpty
                      ? Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              children: [
                                Icon(Icons.train, color: Colors.red),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    "Nearest Station: ${nearestStationName.value}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),

                SizedBox(height: 16.h),
                _buildDropdownSection(),
                SizedBox(height: 16.h),
                _buildActionButtons(),
                SizedBox(height: 20.h),
                _buildBasicInfo(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: ColorsManager.gray,
                  ),
                  icon: Icon(Icons.map, color: ColorsManager.black),
                  label: Text(
                    "View Map",
                    style: TextStyle(color: ColorsManager.black),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesManager.map);
                  },
                ),
                SizedBox(height: 20.h),
                _buildStreetSearch(),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: ColorsManager.black,
                  ),
                  icon: Icon(
                    Icons.location_searching,
                    color: ColorsManager.gray,
                  ),
                  label: Text(
                    "Show Nearest Station to Destination",
                    style: TextStyle(color: ColorsManager.gray),
                  ),
                  onPressed: () async {
                    if (!enableShowRegion) {
                      Get.snackbar("Error", "Please enter a location");
                      return;
                    }
                    await showRegionFromInput();
                    endController.text = nearestStationName.value;
                    enable2 = true;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Card(
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start station dropdown
            DropdownMenu<String>(
              menuHeight: MediaQuery.of(context).size.width,
              onSelected: (a) {
                enable1 = a.isNotNullOrEmpty;
                if (a != null) {
                  startStationLink.value =
                      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$a station Cairo Metro')}";
                } else {
                  startStationLink.value = "";
                }
              },
              controller: startController,
              hintText: 'Select Start Station',
              width: double.infinity,
              enableSearch: true,
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: [
                for (var station in stations)
                  DropdownMenuEntry(value: station, label: station),
              ],
            ),
            Obx(() {
              if (startStationLink.value.isEmpty) return SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    if (startStationLink.value.isEmpty) return;

                    try {
                      final url = Uri.parse(startStationLink.value);
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Could not open maps: ${e.toString()}',
                      );
                    }
                  },
                  child: Text(
                    "View Start Station on Map",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              );
            }),
            SizedBox(height: 12.h),

            DropdownMenu<String>(
              menuHeight: MediaQuery.of(context).size.width,
              onSelected: (a) {
                enable1 = a.isNotNullOrEmpty;
                if (a != null) {
                  startStationLink.value = _createGoogleMapsUrl(a);
                } else {
                  startStationLink.value = "";
                }
              },
              controller: endController,
              hintText: 'Select Destination',
              width: double.infinity,
              enableSearch: true,
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: [
                for (var station in stations)
                  DropdownMenuEntry(value: station, label: station),
              ],
            ),
            Obx(() {
              if (endStationLink.value.isEmpty) return SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    if (endStationLink.value.isEmpty) return;

                    try {
                      final url = Uri.parse(endStationLink.value);
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Could not open maps: ${e.toString()}',
                      );
                    }
                  },
                  child: Text(
                    "View Destination Station on Map",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.my_location, color: ColorsManager.gray),
            label: Text(
              "Nearest From Location",
              style: TextStyle(color: ColorsManager.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.red,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              try {
                Position pos = await _determinePosition();
                Station? nearest = await getNearestStation(
                  pos,
                  stationsCoordinates,
                );
                startController.text = nearest!.EnglishName;
                enable1 = true;
              } catch (e) {
                Get.snackbar('Error', "Some error happened");
              }
            },
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.data_usage, color: ColorsManager.black),
            label: Text(
              "Basic Data",
              style: TextStyle(color: ColorsManager.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.gray,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              var both = (enable1 && enable2) || (enable1 && enableShowRegion);
              both ? getBasicData() : null;
            },
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.info_outline, color: ColorsManager.gray),
            label: Text(
              "More Data",
              style: TextStyle(color: ColorsManager.gray),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.black,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              var both = (enable1 && enable2) || (enable1 && enableShowRegion);
              both ? getExtraData() : null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Obx(() {
      return BasicOutputMessages.isEmpty
          ? SizedBox.shrink()
          : Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    Divider(),
                    ...BasicOutputMessages.map(
                      (msg) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Text(msg, style: TextStyle(fontSize: 16.sp)),
                      ),
                    ).toList(),
                  ],
                ),
              ),
            );
    });
  }

  Widget _buildStreetSearch() {
    return TextField(
      onChanged: (a) => enableShowRegion = a.isNotEmpty,
      controller: streetController,
      decoration: InputDecoration(
        hintText: 'Enter destination location',
        prefixIcon: Icon(Icons.place),
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.map),
      ),
    );
  }
}
