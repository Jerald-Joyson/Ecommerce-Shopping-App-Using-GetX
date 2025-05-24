import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_screen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Shopping App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5368E9),
          elevation: 0,
        ),
        scaffoldBackgroundColor: Color(0xFFF8F9FD),
      ),
      home: HomeScreen(),
    );
  }
}

