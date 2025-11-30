import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:slice/widgets/video_bubble.dart';
import 'package:slice/services/media_service.dart';
import 'package:slice/services/message_service.dart';
import 'package:slice/services/encryption _service.dart';
import 'package:slice/controllers/chat_controllers.dart';

class ChatPage extends StatefulWidget{
  final String convoId;
  final String currUserId;
  final String currUserName;
  final String? chatPartnerId;
  final bool isGroupChat;
  final String? groupName;
  final List<String>? chatMembers;

  final MediaService? mediaService;
  final MessageService? messageService;
  final FirebaseFirestore? firestore;

  const ChatPage({
    super.key,
    required this.convoId,
    required this.currUserId,
    required this.currUserName,
    this.chatPartnerId,
    this.isGroupChat = false,
    this.groupName,
    this.chatMembers,
    this.mediaService,
    this.messageService,
    this.firestore,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  late ChatControllers _chatControllers;
  String? partnerPfp;
  String? chatPartnerUsername;

  @override
  void initState() {
    super.initState();
    
    _chatControllers = ChatControllers(
      convoId: widget.convoId,
      currUserId: widget.currUserId,
      currUserName: widget.currUserName,
      chatPartnerId: widget.chatPartnerId,
      isGroupChat: widget.isGroupChat,
      groupName: widget.groupName,
      chatMembers: widget.chatMembers,
      media: widget.mediaService,
      msg: widget.messageService,
      firestore: widget.firestore,
      );
    _initControllers();

  }

  Future<void> _initControllers() async{

    await _chatControllers.init();
    if(!widget.isGroupChat && widget.chatPartnerId != null){
      partnerPfp = await _chatControllers.getPFP(widget.chatPartnerId!);
      chatPartnerUsername = await _chatControllers.retrieveUsername(widget.chatPartnerId!);
    }
      setState(() {});
  }

  void markAsRead() {
  FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.convoId)
      .collection('readStatus')
      .doc(widget.currUserId)
      .set({'lastRead': DateTime.now()}, SetOptions(merge: true));
  }

  // ------------------------------
  //       LEAVE GROUP
  // ------------------------------
  Future<void> _leaveGroup() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Leave Group"),
        content: const Text("Are you sure you want to leave this group?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.convoId)
          .update({
        "members": FieldValue.arrayRemove([widget.currUserId])
      });

      if (mounted) Navigator.pop(context);
    }
  }

  // ------------------------------
  //       SEND MESSAGE
  // ------------------------------

  //message
  Future<void> _sendMessage(String text) async{
    final cleaned = text.trim();
    if(cleaned.isEmpty){
      return;
    }

    await _chatControllers.sendMessage(text: cleaned);
    _textEditingController.clear();

    Future.delayed(const Duration(milliseconds: 250), (){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  //Pick media function
  Future<void> _pickMedia(bool isImage) async{
    await _chatControllers.pickMedia(isImage);

    Future.delayed(const Duration(milliseconds: 250), (){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context){
    if(!_chatControllers.initialized){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

      final messageRef = _chatControllers.messageStream();

      //for group chats
      final String appBarTitle = widget.isGroupChat ?
        (widget.groupName ?? "Group Chat") : (chatPartnerUsername ?? "Chat");

      //design
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 233, 250, 221),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 151, 193, 125),
          
          title: Row(
            children: [
              if(!widget.isGroupChat)
                CircleAvatar(
                  radius: 18,
                  backgroundImage: partnerPfp != null ?
                    NetworkImage(partnerPfp!) : null,
                  backgroundColor: Colors.grey[300],
                  child: partnerPfp == null 
                    ? const Icon(Icons.person, color: Colors.white) 
                    : null,
                ),

              const SizedBox(width: 10),
              
              Text(
                appBarTitle,
                style: const TextStyle(color: Colors.white,),
              ),
            ],
          ),

          leading: IconButton(
            onPressed: () => Navigator.pop(context), //takes us to the previous page 
            icon: const Icon( Icons.arrow_back, color: Colors.white,),
          ),
          
          actions: [
            if (widget.isGroupChat)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: "Leave Group",
                onPressed: _leaveGroup,
              ),
           ],
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _chatControllers.messageStream(), 
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index){
                      final msg = docs[index].data() as Map<String, dynamic>;
                      final isMe = msg['senderId'] == widget.currUserId;

                      //display the name of a member of the group chat
                      Widget senderLabel = SizedBox.shrink();
                      if(widget.isGroupChat && !isMe){
                        senderLabel = Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 2),
                          child: Text(
                            msg['senderName'] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      Widget bubble = const SizedBox();

                      //Imported text bubbles
                      if(msg['mediaType'] == "" || msg['mediaType'] == null){
                        bubble = BubbleSpecialOne(
                          isSender: isMe,
                          text: msg['text'] ?? "",
                          color: isMe ? const Color(0xFFD0F6C1) : const Color(0xFFFFD8DF),
                          textStyle: const TextStyle(fontSize: 16),
                          tail: true,
                        );
                      }

                      //the image bubble
                      else if(msg['mediaType'] == "image"){
                        bubble = FutureBuilder<Uint8List>(
                          future: _chatControllers.mediaService.decrypt(msg['mediaUrl']),
                          builder: (context, snap){
                            if(!snap.hasData){
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                                );
                            }
                            return BubbleNormalImage(
                              id: msg['senderId'],
                              image: Image.memory(
                                snap.data!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),

                              color: Colors.transparent,
                            );
                          },
                        );
                      }

                      //video bubble
                      else if(msg['mediaType'] == "video"){
                        bubble = FutureBuilder<Uint8List>(
                          future: _chatControllers.mediaService.decrypt(msg['mediaUrl']),
                          builder: (context, snap){
                            if(!snap.hasData){
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              );
                            }

                            return VideoBubble(
                              bytes: snap.data!,
                              isSender: isMe,
                            );
                          },
                        );
                      }
                      return FutureBuilder<String?>(
                        future: _chatControllers.getPFP(msg['senderId']),
                        builder: (context, snapshot){
                          final profileUrl = snapshot.data;

                          Widget avatar = isMe ? const SizedBox(width: 40)
                            : CircleAvatar(
                              radius: 16,
                              backgroundImage: profileUrl!= null ? NetworkImage(profileUrl) : null,
                              backgroundColor: Colors.grey[300],
                              child: profileUrl == null ?
                                const Icon(Icons.person, size: 18, color: Colors.white) : null,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                if(!isMe) avatar,

                                Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    senderLabel,
                                    bubble,
                                  ],
                                ),

                                if(isMe) const SizedBox(width: 40),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

              //The message bar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: MessageBar(
                onSend: (text) => _sendMessage(text),
                messageBarHintText: "Type a message...",
                sendButtonColor: const Color.fromARGB(255, 71, 133, 73),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.grey),
                    onPressed: () => _pickMedia(true),
                  ),

                  IconButton(
                    icon: const Icon(Icons.video_library, color: Colors.grey),
                    onPressed: () => _pickMedia(false),
                  ),
                ],
              ),
            )
          ],
        ),
      );
  }
}