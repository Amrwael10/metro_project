import 'package:dartx/dartx.dart'; // لو مش محتاجه، ممكن تشيله
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
import 'package:seconed_depi/metro_project/widgets/Logic%20Widgets/Search_widget.dart';
import 'package:seconed_depi/metro_project/widgets/UI%20widgets/Basic_Info.dart';
import 'package:seconed_depi/metro_project/widgets/UI%20widgets/Custom_Buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/Algo.dart';
import '../data/stations.dart';
import '../widgets/Logic Widgets/Drop_Down_Menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final streetController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  RxBool enable1 = false.obs;
  RxBool enable2 = false.obs;
  RxBool enableShowRegion = false.obs;

  var nearestStationName = "".obs;

  final BasicOutputMessages = <String>[].obs;
  final ExtraOutputMessages = <String>[].obs;

  // هنبعتهم للـ DropDownMenu عشان يحدثهم
  final RxString startStationLink = "".obs;
  final RxString endStationLink = "".obs;

  // قوائم لست محطات (Strings لواجهة الاختيار)
  final stations = [...line1, ...line2, ...line_three_old, ...list_three_new];

  // قوائم محطات بكائن Station لحساب أقرب محطة
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

      // ← كان فيها خطأ قبل كده (لازم .value)
      if (nearestStationName.value.isNotEmpty) {
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

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

    final pos = await geocoding.locationFromAddress(
      "${streetController.text}, Egypt",
    );
    final url = Uri.parse('geo:0,0?q=$pos');
    launchUrl(url);
  }

  Future<Station?> getNearestStation(Position userPos, List<Station> stations) async {
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

  void region(value) {
    // ← كان فيها خطأ: لازم .value
    enableShowRegion.value = value.isNotEmpty;
    print("Enable region? ${enableShowRegion.value}");
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

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

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
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
            fit: BoxFit.fitWidth,
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
                          const Icon(Icons.train, color: Colors.red),
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
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 16.h),

                DropDownMenu(
                  enable1: enable1,
                  enable2: enable2,
                  startStationLink: startStationLink,
                  endStationLink: endStationLink,
                  startController: startController,
                  endController: endController,
                  stations: cairoStations,
                  createGoogleMapsUrl: _createGoogleMapsUrl,
                ),

                SizedBox(height: 16.h),

                Buttons(
                  enable1: enable1,
                  enable2: enable2,
                  startController: startController,
                  endController: endController,
                  startStationLink: startStationLink,
                  endStationLink: endStationLink,
                  getNearestStation: getNearestStation,
                  determinePosition: _determinePosition,
                  getBasicData: getBasicData,
                  getExtraData: getExtraData,
                  enableShowRegion: enableShowRegion,
                ),

                SizedBox(height: 20.h),
                BasicInfo(Messages: BasicOutputMessages),

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

                Search(
                  controller: streetController,
                  onChanged: (value) {
                    enableShowRegion.value = value.isNotEmpty;
                    print("Enable region? ${enableShowRegion.value}");
                  },
                ),

                SizedBox(height: 20.h),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: ColorsManager.black,
                  ),
                  icon: Icon(Icons.location_searching, color: ColorsManager.gray),
                  label: Text(
                    "Show Nearest Station to Destination",
                    style: TextStyle(color: ColorsManager.gray),
                  ),
                  onPressed: () async {
                    if (!enableShowRegion.value) {
                      Get.snackbar("Error", "Please enter a location");
                      return;
                    }
                    await showRegionFromInput();
                    endController.text = nearestStationName.value;
                    enable2.value = true;
                    streetController.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
