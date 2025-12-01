import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slice/services/keys_generate.dart';

class OneToOneChat {
  final FirebaseFirestore _firebaseFirestore;
  final String Function() _keyGenerator;

  OneToOneChat() : _firebaseFirestore = FirebaseFirestore.instance, _keyGenerator = generateMediaKey;

  //created this in order for the test cases to pass
  OneToOneChat.forTest(
    this._firebaseFirestore,
    this._keyGenerator,
  );


  Future<String> directChat(String user1, String user2) async{
    // final snapshot = await _firebaseFirestore
    //   .collection('chats')
    //   .where('isGroup', isEqualTo: false)
    //   .where('members', arrayContains: user1)
    //   .get();

    // for(final doc in snapshot.docs){
    //   final members = List<String>.from(doc['members']);

    //   if(members.contains(user2)){
    //     return doc.id;
    //   }
    // }
    final convoId = user1.hashCode <= user2.hashCode
      ? "${user1}_$user2"
      : "${user2}_$user1";

    final doc = await _firebaseFirestore.collection('chats').doc(convoId).get();

    if (doc.exists) {
      return convoId;
    }

    //create chat
    //final chatId = _firebaseFirestore.collection('chats').doc().id;
    final mediaKey = _keyGenerator();

    await _firebaseFirestore.collection('chats').doc(convoId).set({
      'isGroup': false,
      'members': [user1, user2],
      'mediaKey': mediaKey,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return convoId;
  }

  //get the media key
  Future<String> getKey(String chatId) async{
    final doc = await _firebaseFirestore.collection('chats').doc(chatId).get();

    return doc['mediaKey'];
  }
}