import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/appwrite_service.dart';
import 'screens/splash.dart';
import 'constants/theme.dart';

void main() {
  // Ensure Flutter binding is initialized before using any plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Appwrite
  AppwriteService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Dua App',
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
