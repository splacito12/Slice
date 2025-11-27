import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slice/services/auth/auth_service.dart';
import 'package:slice/data/notifiers.dart';
import 'package:slice/services/media_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MediaService _mediaService = MediaService();

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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(uid)
        .delete();
  }

  Future<void> changeProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;

    File? image = await _mediaService.pickMedia(true);
    if (image == null) return;

    // Upload file
    final url = await _mediaService.uploadProfilePic(image, uid);

    // Update BOTH Auth + Firestore
    await user.updatePhotoURL(url);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"profilePic": url});

    setState(() {}); // UI refresh (Firestore stream handles photo)
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final username = user.displayName ?? "User";
    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(246, 255, 245, 1),
        toolbarHeight: 80,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),

      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // -------------------------
            // PROFILE PIC (stream updates instantly on Web)
            // -------------------------
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        AssetImage('assets/default_profile.png'),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final photoURL = data["profilePic"] ?? "";

                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 80,
                      backgroundImage: (photoURL.isNotEmpty)
                          ? NetworkImage(
                              "$photoURL?ts=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black87,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: changeProfilePicture,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            // Username
            Text(username),

            const SizedBox(height: 20),

            // Logout button
            SizedBox(
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

            const SizedBox(height: 25),

            const Text(
              "Friends",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // -------------------------
            // FRIEND LIST
            // -------------------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('friends')
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No friends added yet"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;
                      final friendUid = data["friendUid"];
                      final friendName = data["username"];
                      final friendPic = data["profilePic"] ?? "";

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: (friendPic.isNotEmpty)
                              ? NetworkImage(
                                  "$friendPic?ts=${DateTime.now().millisecondsSinceEpoch}",
                                )
                              : const AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                        ),
                        title: Text(friendName),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
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
      ),
    );
  }
}
