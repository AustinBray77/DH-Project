import 'package:flutter/material.dart';
import 'package:flutter_front_end/dashboard.dart';
import 'package:flutter_front_end/home.dart';
import 'package:flutter_front_end/login.dart';
import 'package:flutter_front_end/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var loggedIn = true;
  var name = "safjiowe";
  var role = 1;

  void finalizeLogin(name,role) {
    setState(() {
      this.name = name;
      this.role = role;
      this.loggedIn = true;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kittnz.io',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => loggedIn ? DashboardPage(name: name, role: role) : const MyHomePage(),
        '/login': (context) => LoginPage(finalizeLogin: finalizeLogin),
        '/signup': (context) => SignupPage(finalizeLogin: finalizeLogin),
      },
    );
  }
}

