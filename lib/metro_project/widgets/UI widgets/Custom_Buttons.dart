import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/stations.dart';
import '../../managers/ColorsManager.dart';

class Buttons extends StatelessWidget {
  final RxBool enable1;
  final RxBool enable2;
  final TextEditingController startController;
  final TextEditingController? endController;
  final RxString startStationLink;
  final RxString endStationLink;
  final Function getNearestStation;
  final Function determinePosition;
  final Function getBasicData;
  final Function getExtraData;
  final RxBool enableShowRegion;

  const Buttons({
    super.key,
    required this.enable1,
    required this.enable2,
    required this.startController,
    this.endController,
    required this.startStationLink,
    required this.endStationLink,
    required this.getNearestStation,
    required this.determinePosition,
    required this.getBasicData,
    required this.getExtraData,
    required this.enableShowRegion,
  });

  @override
  Widget build(BuildContext context) {
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
                var pos = await determinePosition();
                var nearest = await getNearestStation(pos, stationsCoordinates);
                startController.text = nearest!.EnglishName;
              } catch (e) {
                Get.snackbar('Error', "Some error happened");
              }
            },
          ),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Obx(() => ElevatedButton.icon(
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
            onPressed: (enable1.value && enable2.value) ||
                (enable1.value && enableShowRegion.value)
                ? () => getBasicData()
                : null,
          )),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Obx(() => ElevatedButton.icon(
            icon: Icon(Icons.info_outline, color: ColorsManager.black),
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
            onPressed: (enable1.value && enable2.value) ||
                (enable1.value && enableShowRegion.value)
                ? () {
              getExtraData();
              startController.clear();
              endController?.clear();
              startStationLink.value = "";
              endStationLink.value = "";
            }: null,
          )),
        ),
      ],
    );
  }
}
