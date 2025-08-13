import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:seconed_depi/metro_project/managers/RoutesManager.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(minTextAdapt: true,designSize: const Size(512,333),
      splitScreenMode: true,
// el size just for testing

      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RoutesManager.router,
        initialRoute: RoutesManager.home,
      ),
    );
  }
}
