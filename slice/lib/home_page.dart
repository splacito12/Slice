import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context){
    final List<Map<String, String>> chats = [
      {'name': 'beautifulSkies12', 'msg': 'Started Following You', 'time': '1d'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF6),
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF6FFF6),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index){},
      )
    );
  }
}