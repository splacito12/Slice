import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:slice/widgets/video_bubble.dart';
import 'dart:io';

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
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  //message
  Future<void> _sendMessage({String? text, File? file, String? mediaType}) async{
    if ((text == null || text.trim().isEmpty) && file == null){
      return;
    }

    //upload our media into the firebase storage
    String? mediaUrl;
    if(file != null && mediaType != null){
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final reference = FirebaseStorage.instance
        .ref()
        .child('chat_media/${widget.convoId}/$fileName');

      await reference.putFile(file);
      mediaUrl = await reference.getDownloadURL();
    }

    //message data
    final messageData = {
      'senderId': widget.currUserId,
      'text': text ?? '',
      'mediaUrl': mediaUrl ?? '',
      'mediaType': mediaType,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.convoId)
      .collection('messages')
      .add(messageData);

    _textEditingController.clear();

    Future.delayed(const Duration(milliseconds: 300), (){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  //Pick media function
  Future<void> _pickMedia(bool isImage) async{
    final pickedMedia = await (isImage ?
      _imagePicker.pickImage(source: ImageSource.gallery)
      : _imagePicker.pickVideo(source: ImageSource.gallery));

    if(pickedMedia != null){
      final file = File(pickedMedia.path);
      _sendMessage(file:file, mediaType: isImage ? 'image' : 'video');
    }
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
          title: Text(widget.chatPartnerId),
          backgroundColor: Colors.green[700],
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
                      if(msg['mediaType'] == ""){
                        return BubbleSpecialOne(
                          isSender: isMe,
                          text: msg['text'],
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

                      // TODO: video bubble
                      if(msg['mediaType'] == "video"){

                      }

                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),

            //The text bar
            MessageBar(
              onSend: (text) => _sendMessage(text: text),
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
          ],
        ),
      );
  }
}