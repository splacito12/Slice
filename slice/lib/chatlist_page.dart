import 'package:flutter/material.dart';

class ChatlistPage extends StatefulWidget{
  const ChatlistPage({super.key});

  @override
  State<ChatlistPage> createState() => _ChatlistPageState();
}

class _ChatlistPageState extends State<ChatlistPage>{

  @override
  Widget build(BuildContext context){
      
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 255, 245, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(246, 255, 245, 1),
        title: Padding(
        padding: EdgeInsets.only(left: 10,top: 16),
        child: Text("Chats", style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        )
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.separated(...), // <- Chat list view
          ), 
           _BottomInputField(), // <- Fixed bottom TextField widget
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16,top: 16),
                child: Row(
                  children: <Widget>[
                    Text("Convo 1",style: TextStyle(fontSize: 20),)
                  ]
                )
              )
            )
          ]
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 32,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Color.fromRGBO(153, 226, 145, 1),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "",
          ),
        ],
      ),
    );
  }
}