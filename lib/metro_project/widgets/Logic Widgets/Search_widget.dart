import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Search extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const Search({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter destination location',
        prefixIcon: Icon(Icons.place),
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.map),
      ),
    );
  }
}
