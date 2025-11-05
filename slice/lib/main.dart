import 'package:flutter/material.dart';
import 'login_page.dart'; // make sure this file is in /lib
import 'signup_page.dart'; // make sure this file is in /lib

void main() {
  runApp(const SliceApp());
}

class SliceApp extends StatelessWidget {
  const SliceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2FFF2),
      ),
      home: const LoginPage(), // start on login
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
