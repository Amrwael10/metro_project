import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:seconed_depi/metro_project/screens/HomePage.dart';
import 'package:seconed_depi/metro_project/managers/RoutesManager.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutesManager.router,
      initialRoute: RoutesManager.home,
    );
  }
}













// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'locations',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: MetroPage(),
//     );
//   }
// }





/*
* location
* lat , long , accuracy => 30.13
*  => map => show , => geocoding => address text
*
* location provides some things to get lat & long
*   => GPS (battery hungry , most accurate)
*   => network (light , not battery hungry, sim card (accurate))
*
*
* permissions
*   => normal , dangerous
*
* packages
*   1- (geo locator package)
*   2- (url launcher) you can search with lat , long or name (+ /)
*   3- url => common intense and find the url for the device features
*   4- (geocoding)
*
*
* Exceptions
*  try & catch (not for developers or users errors)
* */



/*
main:


import 'dart:io';
import 'graph.dart';
import 'right_stations.dart';
import 'lines_stations_data.dart';

// price , all routes ,personal info => age (I would like to ...) , all (but short) , direction , some guidelines , some trials , line 3 again , clean code , processing.

void main(){
  // Step 1 : enter the data
  print('Hi Sir , Welcome to the metro station 🤗');
  print('Please , enter ur start');
  final start = validateStation(stdin.readLineSync() ?? '');

  // wrong stations
  if (!allStations.contains(start)){
    print('invalid input');
    return;
  }

  print('good , and what is ur arrival ?');
  final arrival = validateStation(stdin.readLineSync() ?? '');
  print('\n');

  // start == end
  if(start == arrival){
    print("You are already at the station");
    return;
  }

  // Check if the start or the arrival are wrong names
  if(start == null || arrival == null){
    return;
  }

  // Step 2: Build the graph and search (Algorithm)
  final graph = buildMetroGraph();
  final shortestPath = findShortestPath(graph, start, arrival);

  // Step 3 : Output results
  final stopCount = shortestPath.length - 1;
  final time = stopCount * 2;
  var ticketPrice = 5;
  if(stopCount > 23){
    ticketPrice = 20;
  }
  else if(stopCount == 23){
    ticketPrice = 15;
  }
  else if(stopCount >= 16 && stopCount < 23){
      ticketPrice = 10;
    }
  else if(stopCount >= 9 && stopCount < 16){
    ticketPrice = 8;
  }
  print('The number of stations you will visit is $stopCount');
  print('ticket price is $ticketPrice EGP');

  // time
  if(time < 60){
    print('it will take $time mins\n');
  }
  else{
    final hours = time ~/ 60;
    final minutes = time % 60;
    print('it will take $hours hour(s) and $minutes mins\n');
  }

  // Determine direction and print it
  final lines = stationToLines[start] ?? [];
  String? direction;

  for (var line in lines) {
    final fullLine = {
      "Line 1": line1,
      "Line 2": line2,
      "Line 3 (Rod el Frag)": line_three_rod,
      "Line 3 (Cairo Uni)": list_three_cairo,
    }[line];

    if (fullLine != null && fullLine.map((s) => s.toLowerCase()).contains(start) && fullLine.map((s) => s.toLowerCase()).contains(arrival)) {
      final startIndex = fullLine.indexWhere((s) => s.toLowerCase() == start);
      final endIndex = fullLine.indexWhere((s) => s.toLowerCase() == arrival);

      direction = (startIndex < endIndex) ? fullLine.last : fullLine.first;
      break;
    }
  }
  print('direction => ${direction ?? shortestPath.last}');
  print('The stations you will visit are : ');

  // print stations
  if (shortestPath.isNotEmpty) {
    printRouteWithTransfers(shortestPath);
  }
}

*/



/*
 graph:

 import 'dart:collection';
import 'lines_stations_data.dart';
Map<String, List<String>> stationToLines = {};

// Build a unified graph from all metro lines
Map<String, List<String>> buildMetroGraph() {
  final Map<String, List<String>> graph = {};

  void connectLine(List<String> line , String lineName) {
    for (int i = 0; i < line.length; i++) {
      final station = line[i].toLowerCase();
      graph.putIfAbsent(station, () => []);

      // connect every station with the prev and the next one (bidirectional way)
      if (i > 0) {
        final prev = line[i - 1].toLowerCase();
        graph[station]!.add(prev);
      }
      if (i < line.length - 1) {
        final next = line[i + 1].toLowerCase();
        graph[station]!.add(next);
      }

      // Track which line(s) this station is part of
      stationToLines.putIfAbsent(station, () => []);
      if (!stationToLines[station]!.contains(lineName)) {
        stationToLines[station]!.add(lineName);
      }
    }
  }

  // implement the map
  connectLine(line1 , "Line 1");
  connectLine(line2 , "Line 2");
  connectLine(line_three_rod , "Line 3 (Rod el Frag)");
  connectLine(list_three_cairo, "Line 3 (Cairo Uni)");

  return graph;
}

// BFS Algo to find the shortest path between two stations
List<String> findShortestPath(Map<String, List<String>> graph, String start, String arrival) {
  // first station to be visited => first station to be removed and check its adjacent
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
        queue.add([...path, neighbor]); // (value-this)
      }
    }
  }
  return [];
}

void printRouteWithTransfers(List<String> path) {
  String? previousLine;

  for (int i = 0; i < path.length; i++) {
    final station = path[i];
    final lines = stationToLines[station] ?? [];

    // Determine the line used for this station
    String? currentLine;
    if (previousLine != null && lines.contains(previousLine)) {
      currentLine = previousLine;
    }
    else if (lines.length == 1) {
      currentLine = lines.first;
    }
    else {
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

    // Detect transfer
    if (previousLine != null && previousLine != currentLine) {
      final prevStation = path[i - 1];
      print('↪️ Transfer at $prevStation from $previousLine to $currentLine');
    }

    // Print the station
    print('${i + 1}. ${station[0].toUpperCase()}${station.substring(1)}');
    previousLine = currentLine;
  }
}

*/