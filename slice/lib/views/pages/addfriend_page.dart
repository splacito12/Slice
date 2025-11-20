import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 255, 245, 1),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color.fromRGBO(246, 255, 245, 1),
        title: Text(
          'Add Friend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Username',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color.fromRGBO(153, 226, 145, 1),
              ),
              onPressed: () {},
              child: Text('Send Request'),
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
