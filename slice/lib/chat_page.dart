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
  final String chatPartnerId;

  const ChatPage({
    super.key,
    required this.convoId,
    required this.currUserId,
    required this.chatPartnerId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  final MediaService _mediaService = MediaService();
  final MessageService _messageService = MessageService();

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
    final messageRef = FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.convoId)
      .collection('messages')
      .orderBy('timestamp', descending: false);

      //design
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 233, 250, 221),
        appBar: AppBar(
          title: Text(
            widget.chatPartnerId,
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

                      //Imported text bubbles
                      if(msg['mediaType'] == "" || msg['mediaType'] == null){
                        return BubbleSpecialOne(
                          isSender: isMe,
                          text: msg['text'] ?? "",
                          color: isMe ? const Color(0xFFD0F6C1) : const Color(0xFFFFD8DF),
                          textStyle: const TextStyle(fontSize: 16),
                        );
                      }

                      //the image bubble
                      if(msg['mediaType'] == "image"){
                        return BubbleNormalImage(
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
                      if(msg['mediaType'] == "video"){
                        return VideoBubble(
                          videoUrl: msg['mediaUrl'], 
                          isSender: isMe,
                          );
                      }

                      return const SizedBox.shrink();
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