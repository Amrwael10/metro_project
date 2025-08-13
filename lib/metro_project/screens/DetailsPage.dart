import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Route = Get.arguments;
    return Scaffold(
      appBar: AppBar(title: const Text("Metro Project")),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/red_metro.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('The stations you will visit' , style: TextStyle(fontSize: 30.sp , color: Colors.blueAccent),),
               SizedBox(height: 12.h,),
              Expanded(
                child: ListView.builder(
                    itemCount: Route.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Center(child: Text(Route[index] , style: TextStyle(fontSize: 25.sp , color: Colors.blueAccent),)),
                      );
                    },
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
