import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slice/services/keys_generate.dart';

class OneToOneChat {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> directChat(String user1, String user2) async{
    final snapshot = await _firebaseFirestore
      .collection('chats')
      .where('isGroup', isEqualTo: false)
      .where('members', arrayContains: user1)
      .get();

    for(final doc in snapshot.docs){
      final members = List<String>.from(doc['members']);

      if(members.contains(user2)){
        return doc.id;
      }
    }

    //create chat
    final chatId = _firebaseFirestore.collection('chats').doc().id;
    final mediaKey = generateMediaKey();

    await _firebaseFirestore.collection('chats').doc(chatId).set({
      'isGroup': false,
      'members': [user1, user2],
      'mediaKey': mediaKey,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatId;
  }

  //get the media key
  Future<String> getKey(String chatId) async{
    final doc = await _firebaseFirestore.collection('chats').doc(chatId).get();

    return doc['mediaKey'];
  }
}