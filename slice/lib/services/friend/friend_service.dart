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

    if (targetUid == null) throw "User not found";
    if (myUid == targetUid) throw "Cannot send yourself a request";

    final requestId = '${myUid}_$targetUid';
    final existingRequest = await _firestore
        .collection('friend_requests')
        .doc(requestId)
        .get();
    if (existingRequest.exists) throw "Friend request already sent";

    final alreadyFriends = await _firestore
        .collection('users')
        .doc(myUid)
        .collection('friends')
        .doc(targetUid)
        .get();
    if (alreadyFriends.exists) throw "This user is already your friend";

    final myAccount = await _firestore.collection('users').doc(myUid).get();

    await _firestore.collection('friend_requests').doc(requestId).set({
      'fromUid': myUid,
      'fromUsername': myAccount['username'],
      'fromProfilePic': myAccount['profilePic'] ?? '',
      'toUid': targetUid,
    });
  }

  // accept request
  Future<void> acceptFriendRequest(String requestId, fromUid, toUid) async {
    final fromAccount = await _firestore.collection('users').doc(fromUid).get();
    final toAccount = await _firestore.collection('users').doc(toUid).get();

    await _firestore.runTransaction((transaction) async {
      transaction.set(
        _firestore
            .collection('users')
            .doc(fromUid)
            .collection('friends')
            .doc(toUid),
        {'friendUid': toUid, 
        'username': toAccount['username'],
        'profilePic': toAccount['profilePic'] ?? ''},
      );
      transaction.set(
        _firestore
            .collection('users')
            .doc(toUid)
            .collection('friends')
            .doc(fromUid),
        {'friendUid': fromUid,
         'username': fromAccount['username'],
         'profilePic': fromAccount['profilePic'] ?? ''},
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
