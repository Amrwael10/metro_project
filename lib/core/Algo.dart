import 'dart:collection';

import '../metro_project/data/data.dart';

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
