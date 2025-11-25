import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slice/chat_page.dart';
import 'package:slice/views/pages/addfriend_page.dart';
import 'package:slice/views/pages/creategroup_page.dart';
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
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FFF5),
        title: const Text(
          "Chats",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 80,

        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, size: 35, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddFriendPage()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.group_add, size: 35, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateGroupPage()),
              );

              if (result != null) {
                final current = FirebaseAuth.instance.currentUser!;
                final myName = current.displayName ?? "You";

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      convoId: result["groupId"],
                      currUserId: myUid,
                      currUserName: myName,
                      isGroupChat: true,
                      groupName: result["groupName"],
                      chatMembers: (result["members"] as List)
                          .map((e) => e.toString())
                          .toList(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatService.getFriendsList(),
              builder: (context, friendsSnap) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: chatService.getGroupChats(),
                  builder: (context, groupsSnap) {
                    if (!friendsSnap.hasData || !groupsSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final friends = friendsSnap.data!;
                    final groups = groupsSnap.data!;

                    final safeGroups = groups.map((g) {
                      return {
                        "type": "group",
                        "groupId": g["groupId"],
                        "groupName": g["groupName"],
                        "members": (g["members"] as List<dynamic>)
                            .map((e) => e.toString())
                            .toList(),
                      };
                    }).toList();

                    final allChats = [
                      ...friends.map(
                        (f) => {
                          "type": "friend",
                          "uid": f["friendUid"],
                          "username": f["username"],
                          "profilePic": f["profilePic"],
                        },
                      ),
                      ...safeGroups,
                    ];

                    if (allChats.isEmpty) {
                      return const Center(child: Text("No chats yet"));
                    }

                    return ListView.separated(
                      itemCount: allChats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final chat = allChats[index];

                        if (chat["type"] == "friend") {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  (chat["profilePic"] != null &&
                                      chat["profilePic"] != '')
                                  ? NetworkImage(chat["profilePic"])
                                  : null,
                              child:
                                  (chat["profilePic"] == null ||
                                      chat["profilePic"] == '')
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              chat["username"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              final friendUid = chat["uid"];
                              final convoId =
                                  myUid.hashCode <= friendUid.hashCode
                                  ? "${myUid}_${friendUid}"
                                  : "${friendUid}_${myUid}";

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    convoId: convoId,
                                    currUserId: myUid,
                                    currUserName:
                                        FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .displayName ??
                                        "You",
                                    chatPartnerId: friendUid,
                                    chatPartnerUsername: chat["username"],
                                    isGroupChat: false,
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return ListTile(
                          leading: const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.group),
                          ),
                          title: Text(
                            chat["groupName"],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text("${chat["members"].length} members"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  convoId: chat["groupId"],
                                  currUserId: myUid,
                                  currUserName:
                                      FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .displayName ??
                                      "You",
                                  isGroupChat: true,
                                  groupName: chat["groupName"],
                                  chatMembers: chat["members"],
                                ),
                              ),
                            );
                          },
                        );
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
