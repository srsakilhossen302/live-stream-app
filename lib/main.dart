import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'core/app_route.dart';
import 'core/dependency.dart';
import 'data/helpers/shared_prefe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  await SharePrefsHelper.init();
  DependencyInjection.init();

  final String accessToken = SharePrefsHelper.getString(SharePrefsHelper.accessTokenKey);
  final bool hasSeenOnboarding = SharePrefsHelper.getBool("hasSeenOnboarding");

  String initialRoute;
  if (accessToken.isNotEmpty) {
    initialRoute = AppRoute.main;
  } else if (hasSeenOnboarding) {
    initialRoute = AppRoute.login;
  } else {
    initialRoute = AppRoute.onboarding;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

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
          initialRoute: initialRoute,
          getPages: AppRoute.routes,
          routingCallback: (routing) {
            if (routing != null) {
              AppRoute.routeStream.add(routing.current);
            }
          },
        );
      },
    );
  }
}
