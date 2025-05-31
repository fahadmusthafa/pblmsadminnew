import 'package:flutter/material.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:pb_lms/providers/navigation_provider.dart';
import 'package:pb_lms/providers/super_admin_provider.dart';
import 'package:pb_lms/providers/user_manager_provider/getall_user_provider.dart';
import 'package:pb_lms/views/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolix.LMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(255, 255, 255, 1),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade900),
        drawerTheme: DrawerThemeData(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        ),
        appBarTheme: AppBarTheme(
          color: Color.fromRGBO(255, 255, 255, 1),
          surfaceTintColor: Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
