import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seconed_depi/metro_project/managers/RoutesManager.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome to the Cairo metro line"),centerTitle: true,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context, RoutesManager.metroline);
            }, child: Text("choose from the metro lines")),
            SizedBox(height: 10.h,),

            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context, RoutesManager.locations);

            }, child: Text("choose a location"))
          ],
        ),
      ),
    );
  }
}
