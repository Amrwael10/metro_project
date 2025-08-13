import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seconed_depi/metro_project/managers/ColorsManager.dart';
import 'package:seconed_depi/metro_project/managers/RoutesManager.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Welcome to the Cairo metro line",
            style: TextStyle(color: ColorsManager.purple),
        ),
        centerTitle: true,),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/metrologo.png"),
                const SizedBox(height: 14,),
                ElevatedButton(onPressed: (){
                  Navigator.pushNamed(context, RoutesManager.metroline);
                }, child: Text("choose from the metro lines")),
                SizedBox(height: 8.h,),
                ElevatedButton(onPressed: (){
                  Navigator.pushNamed(context, RoutesManager.locations);
                }, child: Text("choose a location"))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
