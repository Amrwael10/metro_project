import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/stations.dart';

class DropDownMenu extends StatelessWidget {
  final RxBool enable1;
  final RxBool enable2;

  final RxString startStationLink;
  final RxString endStationLink;

  final TextEditingController startController;
  final TextEditingController? endController;

  final List<Station> stations;

  final String Function(String) createGoogleMapsUrl;

  const DropDownMenu({
    super.key,
    required this.enable1,
    required this.enable2,
    required this.startStationLink,
    required this.endStationLink,
    required this.startController,
    this.endController,
    required this.stations,
    required this.createGoogleMapsUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownMenu<String>(
              menuHeight: MediaQuery.of(context).size.width,
              onSelected: (a) {
                final ok = (a != null && a.isNotEmpty);
                enable1.value = ok;
                startController.text = a ?? '';
                startStationLink.value = ok ? createGoogleMapsUrl(a!) : '';
              },
              controller: startController,
              hintText: 'Select Start Station',
              width: double.infinity,
              enableSearch: true,
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: [
                for (final station in stations)
                  DropdownMenuEntry<String>(value: station.EnglishName, label: station.EnglishName),
              ],
            ),
            Obx(() {
              if (startStationLink.value.isEmpty) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final value = startStationLink.value;
                    if (value.isEmpty) return;
                    try {
                      final url = Uri.parse(value);
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      Get.snackbar('Error', 'Could not open maps: ${e.toString()}');
                    }
                  },
                  child: const Text(
                    "View Start Station on Map",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              );
            }),

            SizedBox(height: 12.h),

            // Destination
            DropdownMenu<String>(
              menuHeight: MediaQuery.of(context).size.width/2,
              onSelected: (a) {
                final ok = (a != null && a.isNotEmpty);
                enable2.value = ok;
                endController?.text = a ?? '';
                endStationLink.value = ok ? createGoogleMapsUrl(a!) : '';
              },
              controller: endController,
              hintText: 'Select Destination',
              width: double.infinity,
              enableSearch: true,
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: [
                for (final station in stations)
                  DropdownMenuEntry<String>(value: station.EnglishName, label: station.EnglishName),
              ],
            ),
            Obx(() {
              if (endStationLink.value.isEmpty) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final value = endStationLink.value;
                    if (value.isEmpty) return;
                    try {
                      final url = Uri.parse(value);
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      Get.snackbar('Error', 'Could not open maps: ${e.toString()}');
                    }
                  },
                  child: const Text(
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
}
