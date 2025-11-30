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
  final myUid = FirebaseAuth.instance.currentUser!.uid;
  final ValueNotifier<List<Map<String, dynamic>>> _sortedChats = ValueNotifier(
    [],
  );

  @override
  void initState() {
    super.initState();
    listenChats();
  }

  void listenChats() {
    chatService.getFriendsList().listen((friends) {
      updateChats(friends: friends);
    });

    chatService.getGroupChats().listen((groups) {
      updateChats(groups: groups);
    });
  }

  final Map<String, Map<String, dynamic>> _chatsMap = {};

  void updateSortedChats() {
    final chatList = _chatsMap.values.toList();
    chatList.sort((chatA, chatB) {
      final timeA =
          chatA["lastMessageTime"] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB =
          chatB["lastMessageTime"] ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });
    _sortedChats.value = chatList;
  }

  void updateChats({
    List<Map<String, dynamic>>? friends,
    List<Map<String, dynamic>>? groups,
  }) {
    if (friends != null) {
      for (var f in friends) {
        final uid = f["friendUid"];
        final convoId = myUid.hashCode <= uid.hashCode
            ? "${myUid}_$uid"
            : "${uid}_$myUid";

        if (!_chatsMap.containsKey(convoId)) {
          _chatsMap[convoId] = {
            "type": "friend",
            "uid": uid,
            "username": f["username"],
            "profilePic": f["profilePic"],
            "convoId": convoId,
          };
          chatService.getLastMessageTime(convoId).listen((time) {
            _chatsMap[convoId]!["lastMessageTime"] = time;
            updateSortedChats();
          });
          chatService.getLastMessage(convoId).listen((text) {
            _chatsMap[convoId]!["lastMessage"] = text ?? "No message yet";
            updateSortedChats();
          });
        }
      }
    }

    if (groups != null) {
      for (var g in groups) {
        final convoId = g["groupId"];
        if (!_chatsMap.containsKey(convoId)) {
          _chatsMap[convoId] = {
            "type": "group",
            "groupId": convoId,
            "groupName": g["groupName"],
            "members": (g["members"] as List).map((e) => e.toString()).toList(),
            "convoId": convoId,
          };
          chatService.getLastMessageTime(convoId).listen((time) {
            _chatsMap[convoId]!["lastMessageTime"] = time;
            updateSortedChats();
          });
          chatService.getLastMessage(convoId).listen((text) {
            _chatsMap[convoId]!["lastMessage"] = text ?? "No message yet";
            updateSortedChats();
          });
        }
      }
    }
  }

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

      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _sortedChats,
        builder: (context, sortedChats, _) {
          if (sortedChats.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          return ListView.separated(
            itemCount: sortedChats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final chat = sortedChats[index];

              if (chat["type"] == "friend") {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        (chat["profilePic"] != null && chat["profilePic"] != '')
                        ? NetworkImage(chat["profilePic"])
                        : null,
                    child:
                        (chat["profilePic"] == null || chat["profilePic"] == '')
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat["username"],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow:  TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat["lastMessageTime"] != null)
                        Text(
                          chatService.getFormattedTime(chat["lastMessageTime"]),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)
                        )
                    ],
                  ),
                  subtitle: Text(
                          chat["lastMessage"] ?? "No messages yet",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                        ),
                  onTap: () {
                    final friendUid = chat["uid"];
                    final convoId = myUid.hashCode <= friendUid.hashCode
                        ? "${myUid}_${friendUid}"
                        : "${friendUid}_${myUid}";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          convoId: convoId,
                          currUserId: myUid,
                          currUserName:
                              FirebaseAuth.instance.currentUser!.displayName ??
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
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat["groupName"],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow:  TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat["lastMessageTime"] != null)
                        Text(
                          chatService.getFormattedTime(chat["lastMessageTime"]),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)
                        )
                    ],
                  ),
                  subtitle: Text(
                          chat["lastMessage"] ?? "No messages yet",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                        ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        convoId: chat["groupId"],
                        currUserId: myUid,
                        currUserName:
                            FirebaseAuth.instance.currentUser!.displayName ??
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
      ),
    );
  }
}
