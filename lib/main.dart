import 'package:flutter/material.dart';
import 'package:hemacostos/ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeMa Costos',
      theme: AppTheme.lightTheme,
      //home: const HomeScreen(),
      home: LoginScreen(),
    );
  }
}
