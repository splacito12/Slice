import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firebaseFirestore;

  //for easier injection of mock tests
  MessageService({FirebaseFirestore ? firestore})
    : _firebaseFirestore = firestore ?? FirebaseFirestore.instance;

  Future<void> messageSend({
    required String convoId,
    required String senderId,
    required String senderName,
    String text = '',
    String mediaUrl = '',
    String? mediaType,
  })async{
    await _firebaseFirestore
      .collection('chats')
      .doc(convoId)
      .collection('messages')
      .add({
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }
}