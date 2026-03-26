import 'package:flutter/material.dart';
import 'package:hemacostos/ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';
import 'services/session.dart';

/*
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
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLogged = await SessionService.isLogged();

  runApp(MyApp(isLogged: isLogged));
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeMa Costos',
      theme: AppTheme.lightTheme,

      initialRoute: isLogged ? "/home" : "/login",

      routes: {
        "/login": (_) => const LoginScreen(),
        "/home": (_) => const HomeScreen(),
      },
    );
  }
}