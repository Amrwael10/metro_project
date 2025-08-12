import 'dart:collection';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seconed_depi/metro_project/data/data.dart';
import 'package:seconed_depi/metro_project/screens/DetailsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // metro stations
  final stations = [
    ...line1,
    ...line2,
    ...line_three_old,
    ...list_three_new
  ];
  final startController = TextEditingController();
  final endController = TextEditingController();
  final streetController = TextEditingController();
  var enable1 = false.obs;
  var enable2 = false.obs;
  var enableShowRegion = false.obs;
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
    var ticketPrice = 5;
    if (stopCount > 23) {
      ticketPrice = 20;
    } else if (stopCount == 23) {
      ticketPrice = 15;
    } else if (stopCount >= 16 && stopCount < 23) {
      ticketPrice = 10;
    } else if (stopCount >= 9 && stopCount < 16) {
      ticketPrice = 8;
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

  void showRegion(){}

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
      appBar: AppBar(title: const Text("Metro Project")),
      body: SafeArea(
        child: Column(
          spacing: 12,
          children: [
            DropdownMenu<String>(
                onSelected: (a) {
                  enable1.value = a.isNotNullOrEmpty;
                },
                controller: startController,
                hintText: 'please select a start station',
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
                hintText: 'please select an end station',
                width: double.infinity,
                enableSearch: true,
                enableFilter: true,
                requestFocusOnTap: true,
                dropdownMenuEntries: [
                  for (var station in stations)
                    DropdownMenuEntry(value: station, label: station)
                ]),
            ElevatedButton(
                onPressed: (){},
                child: Text('the nearest station from your location'),
            ),
            ElevatedButton(
              onPressed: () {
                // Todo show time , ticket price , number of stations
                if (enable1.value && enable2.value) getBasicData();
              },
              child: Text('Show Basic Data'),
            ),
            ElevatedButton(
              onPressed: () {
                if(enable1.value && enable2.value) getExtraData();
              },
              child: Text('Show More Data'),
            ),
            const Divider(),
            TextField(
              onChanged: (a) {
                enableShowRegion.value = a.isNotEmpty;
              },
              controller: streetController,
              decoration: InputDecoration(
                  hintText: 'Enter the destination want to go.',
                  filled: true,
                  fillColor: Colors.grey,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,),
                  suffixIcon: IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.map),
                  ),
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  enableShowRegion.value ? showRegion(): null;
                },
                child: Text('show nearest station to the street'),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: BasicOutputMessages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(BasicOutputMessages[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// dart logic
class MetroGraph {
  Map<String, List<String>> stationToLines = {};

  // Build a unified graph from all metro lines
  Map<String, List<String>> buildMetroGraph() {
    final Map<String, List<String>> graph = {};

    void connectLine(List<String> line, String lineName) {
      for (int i = 0; i < line.length; i++) {
        final station = line[i].toLowerCase();
        graph.putIfAbsent(station, () => []);

        if (i > 0) {
          final prev = line[i - 1].toLowerCase();
          graph[station]!.add(prev);
        }
        if (i < line.length - 1) {
          final next = line[i + 1].toLowerCase();
          graph[station]!.add(next);
        }

        stationToLines.putIfAbsent(station, () => []);
        if (!stationToLines[station]!.contains(lineName)) {
          stationToLines[station]!.add(lineName);
        }
      }
    }

    connectLine(line1, "Line 1");
    connectLine(line2, "Line 2");
    connectLine(line_three_old, "Line 3 (Rod el Frag)");
    connectLine(list_three_new, "Line 3 (Cairo Uni)");
    return graph;
  }

  // BFS Algorithm
  List<String> findShortestPath(Map<String, List<String>> graph, String start,
      String arrival) {
    final visited = <String>{};
    final queue = Queue<List<String>>();
    queue.add([start]);

    while (queue.isNotEmpty) {
      final path = queue.removeFirst();
      final current = path.last;

      if (current == arrival) return path;

      if (!visited.contains(current)) {
        visited.add(current);
        for (final neighbor in graph[current] ?? []) {
          queue.add([...path, neighbor]);
        }
      }
    }
    return [];
  }

  // Instead of printing, return route list
  List<String> routeWithTransfers(List<String> path) {
    List<String> result = [];
    String? previousLine;

    for (int i = 0; i < path.length; i++) {
      final station = path[i];
      final lines = stationToLines[station] ?? [];

      String? currentLine;
      if (previousLine != null && lines.contains(previousLine)) {
        currentLine = previousLine;
      } else if (lines.length == 1) {
        currentLine = lines.first;
      } else {
        if (i > 0) {
          final prevLines = stationToLines[path[i - 1]] ?? [];
          currentLine = lines.firstWhere(
                (line) => prevLines.contains(line),
            orElse: () => lines.first,
          );
        } else {
          currentLine = lines.first;
        }
      }
      if (previousLine != null && previousLine != currentLine) {
        final prevStation = path[i - 1];
        result.add(
            '↪️ Transfer at $prevStation from $previousLine to $currentLine');
      }
      result.add(
          '${i + 1}. ${station[0].toUpperCase()}${station.substring(1)}');
      previousLine = currentLine;
    }
    return result;
  }
}
