import 'package:flutter/material.dart';
import 'package:slice/services/auth/auth_service.dart';
import 'package:slice/data/notifiers.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void logOut() {
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? 'User';

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 80,
              child: Icon(Icons.person, size: 70,),
            ),
            Text(username),
            SizedBox(
              width: 300,
              child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 148, 148),
                  ),
                  onPressed: () {
                    debugPrint('LOGOUT');
                    logOut();
                    currentPageNotifier = ValueNotifier(0);
                  },
                  child: Text('Logout'),
                ),
            ),
          ],
        ),
      )
    );
  }
}