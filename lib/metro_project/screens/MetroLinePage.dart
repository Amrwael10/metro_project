import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:seconed_depi/metro_project/data/data.dart';
import 'package:seconed_depi/metro_project/managers/RoutesManager.dart';
import 'package:seconed_depi/metro_project/screens/DetailsPage.dart';
import '../core/Algo.dart';
import '../data/stations.dart';

class MetroLinePage extends StatefulWidget {
  const MetroLinePage({super.key});

  @override
  State<MetroLinePage> createState() => _MetroLinePageState();
}

class _MetroLinePageState extends State<MetroLinePage> {

  // metro stations
  final stations = [
    ...line1,
    ...line2,
    ...line_three_old,
    ...list_three_new
  ];

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

  final startController = TextEditingController();
  final endController = TextEditingController();
  var enable1 = false.obs;
  var enable2 = false.obs;
  final BasicOutputMessages = <String>[].obs;
  final ExtraOutputMessages = <String>[].obs;

  void getBasicData() {
    final metroGraph = MetroGraph();
    final graph = metroGraph.buildMetroGraph();

    final shortestPath = metroGraph.findShortestPath(
      graph,
      startController.text.trim().toLowerCase(),
      endController.text.trim().toLowerCase(),
    );

    if(startController.text == endController.text){
      Get.snackbar('Oops', 'your destination can not be your Starting station');
      return;
    }

    // basic data
    final stopCount = shortestPath.length - 1;
    final time = stopCount * 2;
    var ticketPrice = 0;
    if (stopCount > 23) {
      ticketPrice = 20;
    } else if (stopCount == 23) {
      ticketPrice = 15;
    } else if (stopCount >= 16 && stopCount < 23) {
      ticketPrice = 10;
    } else if (stopCount >= 9 && stopCount < 16) {
      ticketPrice = 8;
    } else if (stopCount < 9){
      ticketPrice = 5;
    }

    final info = [
      "🚉 Number of stations: $stopCount",
      "💰 Ticket price: $ticketPrice EGP",
      if (time < 60)
        "⏱️ Estimated time: $time mins"
      else
        "⏱️ Estimated time: ${time ~/ 60} hour(s) and ${time % 60} mins"
    ];
    BasicOutputMessages.assignAll([...info]);
  }

  // extra data
  void getExtraData(){
    final metroGraph = MetroGraph();
    final graph = metroGraph.buildMetroGraph();

    final shortestPath = metroGraph.findShortestPath(
      graph,
      startController.text.trim().toLowerCase(),
      endController.text.trim().toLowerCase(),
    );
    if(startController.text == endController.text){
      Get.snackbar('Oops', 'your destination can not be your Starting station');
      return;
    }
    // Route details
    final routeDetails = metroGraph.routeWithTransfers(shortestPath);
    ExtraOutputMessages.assignAll([...routeDetails]);
    Get.to(DetailsPage() , arguments: ExtraOutputMessages);
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
    //streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final region = Get.arguments;
    endController.text = region;
    return Scaffold(
      appBar: AppBar(title: Text("Choose your start and your destination",style: TextStyle(fontSize: 23.sp),)),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          spacing: 12,
          children: [
            DropdownMenu<String>(
                onSelected: (a) {
                  enable1.value = a.isNotNullOrEmpty;
                },
                controller: startController,
                hintText: 'please select your start station',
                width: double.infinity,
                enableSearch: true,
                enableFilter: true,
                requestFocusOnTap: true,
                dropdownMenuEntries: [
                  for (var station in stations)
                    DropdownMenuEntry(value: station, label: station)
                ]),
            DropdownMenu<String>(
                onSelected: (a) {
                  enable2.value = a.isNotNullOrEmpty;
                },
                controller: endController,
                hintText: 'please select your destination',
                width: double.infinity.w,
                enableSearch: true,
                enableFilter: true,
                requestFocusOnTap: true,
                dropdownMenuEntries: [
                  for (var station in stations)
                    DropdownMenuEntry(value: station, label: station)
                ]),
            ElevatedButton(
              onPressed: () async {
                try {
                  Position pos = await _determinePosition();
                  Station? nearest = await getNearestStation(pos, stationsCoordinates);
                  print('Nearest station: ${nearest?.EnglishName}');
                  startController.text=nearest!.EnglishName;
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('the nearest station from your location'),
            ),
            ElevatedButton(
              onPressed: () {
                //Todo : if (enable1.value && enable2.value)
                  getBasicData();
              },
              child: Text('Show Basic Data'),
            ),
            ElevatedButton(
              onPressed: () {
                // Todo : if(enable1.value && enable2.value)
                  getExtraData();
              },
              child: Text('Show More Data'),
            ),
            const Divider(),
            Obx(() {
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: BasicOutputMessages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(BasicOutputMessages[index]),
                    );
                  });

            }),
            IconButton(onPressed: (){Navigator.pushNamed(context, RoutesManager.map);}, icon: Icon(Icons.map))
          ],
        ),
      ),
    );
  }
}
