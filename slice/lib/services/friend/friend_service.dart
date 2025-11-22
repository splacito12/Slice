import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // search for target email in database
  Future<String?> findUserByEmail(String email) async {
    final targetUser = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (targetUser.docs.isNotEmpty) {
      return targetUser.docs.first.id;
    } else {
      return null;
    }
  }

  // create friend request
  Future<void> sendFriendRequest(String targetEmail) async {
    String myUid = _auth.currentUser!.uid;
    String? targetUid = await findUserByEmail(targetEmail);

    if (targetUid == null) throw Exception("User not found");
    if (myUid == targetUid) throw Exception("Cannot send yourself a request");

    final requestId = '${myUid}_$targetUid';

    await _firestore.collection('friend_requests').doc(requestId).set({
      'fromUid': myUid,
      'toUid': targetUid,
    });
  }

  // accept request
  Future<void> acceptFriendRequest(String requestId, fromUid, toUid) async {
    await _firestore.runTransaction((transaction) async {
      transaction.set(
        _firestore
            .collection('users')
            .doc(fromUid)
            .collection('friends')
            .doc(toUid),
        {'friendUid': toUid},
      );
      transaction.set(
        _firestore
            .collection('users')
            .doc(toUid)
            .collection('friends')
            .doc(fromUid),
        {'friendUid': fromUid},
      );

      transaction.delete(
        _firestore.collection('friend_requests').doc(requestId),
      );
    });
  }

  // reject request
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  // get friend requests
  Stream<List<Map<String, dynamic>>> getFriendRequests() {
    String currentUid = _auth.currentUser!.uid;
    return _firestore
        .collection('friend_requests')
        .where('toUid', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
