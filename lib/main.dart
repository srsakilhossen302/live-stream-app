import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/app_route.dart';
import 'core/dependency.dart';
import 'data/helpers/shared_prefe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharePrefsHelper.init();
  DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 950),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
      },
    );
  }
}
