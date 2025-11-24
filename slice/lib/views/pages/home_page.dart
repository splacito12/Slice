import 'package:flutter/material.dart';
import 'package:slice/views/pages/addfriend_page.dart';
import 'package:slice/services/chat/chat_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatService = ChatService();

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
      
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatService.getFriendsList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
      
                final friends = snapshot.data!;
                if (friends.isEmpty) {
                  return const Center(child: Text("No friends"));
                }
      
                return ListView.separated(
                  itemCount: friends.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final friendUsername = friend['username'];
                    final profilePic = friend['profilePic'];
      
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: profilePic != null && profilePic != ''
                        ? NetworkImage(profilePic) 
                        : AssetImage('assets/slice_logo.jpeg')
                        ),
                      title: Text(friendUsername, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('latest text placeholder'),
                      onTap: () {
                        
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
