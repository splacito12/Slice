import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> messageSend({
    required String convoId,
    required String senderId,
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
        'text': text,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }
}