import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  // get instance of firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              "groupId": doc.id,
              "groupName": data["groupName"],
              "members": data["members"],
            };
          }).toList(),
        );
  }

  // get the time of the last message in a chat
  Stream<DateTime?> getLastMessageTime(String convoId) {
    return _firestore
      .collection('chats')
      .doc(convoId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return (snapshot.docs.first['timestamp'] as Timestamp).toDate();
        }
        return null;
      });
  }

  // Format times for chats on homepage
  String getFormattedTime(DateTime time) {
    final now = DateTime.now();
    final timeDifference = now.difference(time);

    if (timeDifference.inDays == 0) {
      int hour = time.hour;
      final minute = time.minute.toString().padLeft(2,'0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
      return "$hour:$minute $ampm";
    } else if (timeDifference.inDays == 1) {
      return "1 day ago";
    } else if (timeDifference.inDays <= 6) {
      return "${timeDifference.inDays} days ago";
    } else {
      return "${time.month}/${time.day}/${time.year}";
    }
  }

  Stream<Map<String, dynamic>?> getLastMessage(String convoId) {
    return _firestore
      .collection('chats')
      .doc(convoId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          return {
            'text': data['text'],
            'senderId': data ['senderId'],
          };
        }
        return null;
      }); 
  }

  Stream<DateTime?> getLastReadTime(String convoId, String userId) {
  return _firestore
      .collection('chats')
      .doc(convoId)
      .collection('readStatus')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data()!['lastRead'] != null) {
          return (snapshot.data()!['lastRead'] as Timestamp).toDate();
        }
        return null;
      });
}
}
