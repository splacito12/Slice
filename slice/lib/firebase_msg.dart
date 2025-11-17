import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMsg {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void>initFCM() async{

    await _firebaseMessaging.requestPermission();

    var token = _firebaseMessaging.getToken();

    print("Token: $token" );

    FirebaseMessaging.onBackgroundMessage(handleNotification);
    FirebaseMessaging.onMessage.listen(handleNotification);
  }
}

Future<void> handleNotification(RemoteMessage msg) async{

}