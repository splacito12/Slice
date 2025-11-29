import 'package:flutter/material.dart';

// home page filler for now to test email auth
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text(
          "Welcome to Slice!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
