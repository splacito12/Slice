import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:slice/services/encryption _service.dart';
import 'package:slice/services/media_service.dart';
import 'package:slice/services/message_service.dart';

class ChatControllers {
  final String convoId;
  final String currUserId;
  final String currUserName;
  final String? chatPartnerId; //for 1-1
  final bool isGroupChat; //for group chats
  final String? groupName;
  final List<String>? chatMembers;

  final FirebaseFirestore firestore;
  final MessageService? mesgService;
  final MediaService? medService;
  
  late MediaService mediaService;
  late MessageService messageService;
  late EncryptService encryptService;

  bool initialized = false;

  ChatControllers({
    required this.convoId,
    required this.currUserId,
    required this.currUserName,
    this.chatPartnerId,
    this.isGroupChat = false,
    this.groupName,
    this.chatMembers,
    this.medService,
    this.mesgService,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  //initialize and load key
  Future<void> init() async{
    if(initialized){
      return;
    }

    final chatDoc = await firestore
      .collection('chats')
      .doc(convoId)
      .get();
    final mediaKey = chatDoc['mediaKey'];

    encryptService = EncryptService(mediaKey);
    mediaService = medService ?? MediaService(encryptService: encryptService);
    messageService = mesgService ?? MessageService();

    initialized = true;
    
  }

  Stream<QuerySnapshot> messageStream(){
    return firestore
      .collection('chats')
      .doc(convoId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
  }

  //send messages
  Future<void> sendMessage({
    String? text,
    File? file,
    String? mediaType
  }) async {
    if(!initialized){
      await init();
    }

    if((text == null || text.trim().isEmpty) && file == null){
      return;
    }

    //upload media
    String mediaUrl = "";
    if(file != null && mediaType != null){
      mediaUrl = await mediaService.uploadMedia(file: file, convoId: convoId);
    }

    await messageService.messageSend(
      convoId: convoId, 
      senderId: currUserId, 
      senderName: currUserName,
      text: text ?? "",
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      );
  }

  //pick media
  Future<void> pickMedia(bool isImage) async{
    if(!initialized){
      await init();
    }

    final file = await mediaService.pickMedia(isImage);
    
    if(file == null){
      return;
    }

    await sendMessage(
      file: file,
      mediaType: isImage ? "image" : "video",
    );
  }

}