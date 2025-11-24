import 'package:flutter/material.dart';
import 'package:slice/views/pages/addfriend_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(246, 255, 245, 1),
        toolbarHeight: 80,
        title: Text(
          "Chats",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, size: 35, color: Colors.black),
            tooltip: 'Add Friend',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AddFriendPage();
              },));
            },
          ),
        ],
      ),
      
      body: Center(child: Text('Home Page'))
    );
  }
}
