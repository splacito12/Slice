import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  String userName = "";
  String email = "";

  @override
  Widget build(BuildContext context){
    return Scaffold(
      
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF6FFF6),
        title: const Text("Chats", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold,color: Colors.black),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(Icons.account_circle, 
            size: 150, 
            color: const Color(0xFFFFC0CB)
            ),
            const SizedBox(height: 15),
            Text(userName, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: () async{},
              selectedColor: Color.fromARGB(255, 185, 219, 185),
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.chat),
              title: const Text(
                "Chats",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
              selectedColor: Color.fromARGB(255, 185, 219, 185),
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async{
              },
              selectedColor: Color.fromARGB(255, 185, 219, 185),
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}