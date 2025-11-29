import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  // get instance of firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  // get user stream
  // Stream<List<Map<String,dynamic>>> getUserStream() {
  //   return _firestore.collection("Users").snapshots().map(snapshot) {

  //   }
  // }

  Stream<List<Map<String, dynamic>>> getFriendsList() {
    String currentUid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
    Stream<List<Map<String, dynamic>>> getGroupChats() {
    String uid = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('isGroup', isEqualTo: true)
        .where('members', arrayContains: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                "groupId": doc.id,
                "groupName": data["groupName"],
                "members": data["members"],
              };
            }).toList());
  }

  // send messages


  // receive messages
}