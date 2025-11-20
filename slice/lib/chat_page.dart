import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'dart:io';


import 'package:slice/widgets/video_bubble.dart';
import 'package:slice/services/media_service.dart';
import 'package:slice/services/message_service.dart';

//this is not the official chats page. need to create one for sharing media

class ChatPage extends StatefulWidget{
  final String convoId;
  final String currUserId;
  final String currUserName;
  final String? chatPartnerId; //for 1-1
  final bool isGroupChat; //for group chats
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

class _ChatPageState extends State<ChatPage>{
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  late MediaService _mediaService;
  late MessageService _messageService;
  late FirebaseFirestore _firebaseFirestore;

  //initstate so that its easier to use mock tests
  @override
  void initState(){
    super.initState();
    _mediaService = widget.mediaService ?? MediaService();
    _messageService = widget.messageService ?? MessageService();
    _firebaseFirestore = widget.firestore ?? FirebaseFirestore.instance;
  }

  //message
  Future<void> _sendMessage({String? text, File? file, String? mediaType}) async{
    if ((text == null || text.trim().isEmpty) && file == null){
      return;
    }

    //upload our media into the firebase storage
    String mediaUrl = "";
    if(file != null && mediaType != null){
      mediaUrl = await _mediaService.uploadMedia(file: file, convoId: widget.convoId);
    }

    //message data
    await _messageService.messageSend(
      convoId: widget.convoId,
     senderId: widget.currUserId,
     senderName: widget.currUserName,
     text: text ?? "",
     mediaType: mediaType,
     mediaUrl: mediaUrl,
     );

    _textEditingController.clear();

    Future.delayed(const Duration(milliseconds: 300), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  //Pick media function
  Future<void> _pickMedia(bool isImage) async{
    File? file = await _mediaService.pickMedia(isImage);

    if(file == null){
      return;
    }

    await _sendMessage(file: file, mediaType: isImage ? "image" : "video",);
  }

  //here will go all the design of the chat page
  @override
  Widget build(BuildContext context){
    final messageRef = (widget.firestore ?? FirebaseFirestore.instance)
      .collection('chats')
      .doc(widget.convoId)
      .collection('messages')
      .orderBy('timestamp', descending: false);

      //for group chats
      final String appBarTitle = widget.isGroupChat ?
        (widget.groupName ?? "Group Chat") : (widget.chatPartnerId ?? "Chat");

      //design
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 233, 250, 221),
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: const TextStyle(color: Colors.white),
            ),

          backgroundColor: Colors.green[700],
          leading: IconButton(onPressed: () => Navigator.pop(context), //takes us to the previous page 
          icon: const Icon( Icons.arrow_back, color: Colors.white,),
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: messageRef.snapshots(), 
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

                      Widget bubble;

                      //Imported text bubbles
                      if(msg['mediaType'] == "" || msg['mediaType'] == null){
                        bubble = BubbleSpecialOne(
                          isSender: isMe,
                          text: msg['text'] ?? "",
                          color: isMe ? const Color(0xFFD0F6C1) : const Color(0xFFFFD8DF),
                          textStyle: const TextStyle(fontSize: 16),
                        );
                      }

                      //the image bubble
                      else if(msg['mediaType'] == "image"){
                        bubble = BubbleNormalImage(
                          id: msg['senderId'],
                          image: Image.network(
                            msg['mediaUrl'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          color: Colors.transparent,
                        );
                      }

                      //video bubble
                      else if(msg['mediaType'] == "video"){
                        bubble = VideoBubble(
                          videoUrl: msg['mediaUrl'], 
                          isSender: isMe,
                          );
                      }else{
                        bubble = const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: isMe ?
                          CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            senderLabel,
                            bubble,
                          ],
                      );
                    },
                  );
                },
              ),
            ),

            //The message bar
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(20),
              child: MessageBar(
                onSend: (text) => _sendMessage(text: text),
                messageBarHintText: "Type a message...",
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
              ),
          ],
        ),
      );
  }
}