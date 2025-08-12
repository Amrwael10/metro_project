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
  final stations = [...line1, ...line2, ...line_three_old, ...list_three_new]; // will be obs
  final startController = TextEditingController();
  final endController = TextEditingController();
  var enable1 = false.obs;
  var enable2 = false.obs;

  void getBasicData(){
    print('work');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              DropdownMenu<String>(
                  onSelected: (a){
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
                  onSelected: (a){
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
                onPressed: () {
                  // Todo show time , ticket price , number of stations
                  if(enable1.value && enable2.value) getBasicData();
                  enable1.value = false;
                  enable2.value = false;
                },
                child: Text('Show Basic Data'),
              ),
              ElevatedButton(
                onPressed: () {
                  if(enable1.value && enable2.value) Get.to(DetailsPage());
                  enable1.value = false;
                  enable2.value = false;
                },
                child: Text('Show More Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

