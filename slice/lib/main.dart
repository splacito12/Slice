import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slice/services/auth/auth_gate.dart';
import 'package:slice/views/pages/home_page.dart';
import 'firebase_options.dart';
import 'views/widget_tree.dart';
import 'package:slice/login_page.dart';
//import 'package:slice/firebase_msg.dart';
import 'login_page.dart'; // make sure this file is in /lib
import 'signup_page.dart'; // make sure this file is in /lib
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      // name: "slice-32bc8",
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Slice());
}

class Slice extends StatelessWidget {
  const Slice({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2FFF2),
      ),
      home: const AuthGate(),
    );
  }
}