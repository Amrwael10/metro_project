import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Locationspage extends StatefulWidget {
   Locationspage({super.key});

  @override
  State<Locationspage> createState() => _LocationspageState();
}

class _LocationspageState extends State<Locationspage> {
   final streetController = TextEditingController();

   var enableShowRegion = false.obs;

   void showRegion(){}
@override
  void dispose() {
    // TODO: implement dispose
  streetController.dispose();
    super.dispose();
  }
   @override
  Widget build(BuildContext context) {

    return Scaffold(appBar:AppBar(title: Text("choose your location"),),body: Column(children: [ TextField(
      onChanged: (a) {
        enableShowRegion.value = a.isNotEmpty;
      },
      controller: streetController,
      decoration: InputDecoration(
        hintText: 'Enter the destination want to go.',
        filled: true,
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,),
        suffixIcon: IconButton(
          onPressed: (){},
          icon: Icon(Icons.map),
        ),
      ),
    ),
      SizedBox(height: 12.h,),
      ElevatedButton(
        onPressed: (){
          enableShowRegion.value ? showRegion(): null;
        },
        child: Text('show nearest station to the street'),
      ),],),);
  }
}
