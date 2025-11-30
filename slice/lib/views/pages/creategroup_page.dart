import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat/chat_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  List<String> selectedMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FFF5),
        toolbarHeight: 80,
        title: const Text(
          "Create Group",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getFriendsList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final friends = snapshot.data!;
                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, i) {
                    final f = friends[i];
                    final uid = f["friendUid"];
                    final selected = selectedMembers.contains(uid);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: f["profilePic"] != ""
                            ? NetworkImage(f["profilePic"])
                            : null,
                        child: f["profilePic"] == ""
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(f["username"]),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedMembers.add(uid);
                            } else {
                              selectedMembers.remove(uid);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter group name")),
                  );
                  return;
                }

                if (selectedMembers.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Select at least 1 member")),
                  );
                  return;
                }

                final groupId =
                    FirebaseFirestore.instance.collection("chats").doc().id;

                final allMembers = [...selectedMembers, myUid];

                await FirebaseFirestore.instance
                    .collection("chats")
                    .doc(groupId)
                    .set({
                  "isGroup": true,
                  "groupName": _nameController.text.trim(),
                  "members": allMembers,
                  "createdBy": myUid,
                  "createdAt": FieldValue.serverTimestamp(),
                });

                Navigator.pop(context, {
                  "groupId": groupId,
                  "groupName": _nameController.text.trim(),
                  "members":
                      allMembers.map((e) => e.toString()).toList(),
                });
              },
              child: const Text("Create Group Chat"),
            ),
          ),
        ],
      ),
    );
  }
}
