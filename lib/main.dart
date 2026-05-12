import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/app_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Stream App',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: AppRoute.onboarding,
      getPages: AppRoute.routes,
    );
  }
}
