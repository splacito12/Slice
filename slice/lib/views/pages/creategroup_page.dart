import 'package:flutter/material.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(246, 255, 245, 1),
        toolbarHeight: 80,
        title: Text(
          "Create Group",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      
      body: Center(child: Text('Create Group Page'))
    );
  }
}