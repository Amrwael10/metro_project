import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class BasicInfo extends StatelessWidget {
  final List<String>Messages;
   BasicInfo({super.key, required this.Messages});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Messages.isEmpty
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
              ...Messages.map(
                    (msg) =>
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(msg, style: TextStyle(fontSize: 16.sp)),
                    ),
              ).toList(),
            ],
          ),
        ),
      );
    });;
  }
}
