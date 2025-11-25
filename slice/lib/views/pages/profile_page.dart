import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slice/services/auth/auth_service.dart';
import 'package:slice/data/notifiers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void logOut() {
    final _auth = AuthService();
    _auth.signOut();
  }

  Future<void> unfriend(String friendUid) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(friendUid)
        .delete();

    // remove myself from their list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(uid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final username = user.displayName ?? "User";
    final uid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FFF5),
        toolbarHeight: 80,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 80,
            child: const Icon(Icons.person, size: 70),
          ),

          const SizedBox(height: 10),
          Text(username, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SizedBox(
              width: 300,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 148, 148),
                ),
                onPressed: () {
                  logOut();
                  currentPageNotifier = ValueNotifier(0);
                },
                child: const Text('Logout'),
              ),
            ),
          ),
          
          const Text(
            "Friends",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('friends')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No friends added yet"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    final friendUid = data["friendUid"]; // correct field
                    final friendName = data["username"] ?? "Unknown";
                    final friendPic = data["profilePic"] ?? "";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (friendPic != null && friendPic != "")
                                ? NetworkImage(friendPic)
                                : null,
                        child: (friendPic == "" || friendPic == null)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(friendName),

                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red),
                        onPressed: () => unfriend(friendUid),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
