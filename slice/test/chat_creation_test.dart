import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:slice/services/chat/chat_service.dart';
import 'package:slice/services/keys_generate.dart';
import 'package:slice/services/chat/OneToOne_chat.dart';

//create a fake key
String fakeKey() => "TEST_KEY";

void main(){
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late OneToOneChat oneToOneChat;

  setUp((){
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    oneToOneChat = OneToOneChat.forTest(fakeFirebaseFirestore, fakeKey);
  });

  //test whether a 1-1 chat is created when one doesn't exist
  test("creates 1-1 when one doesn't exist", () async{
    final chatId = await oneToOneChat.directChat("UserA", "UserB");

    final doc = await fakeFirebaseFirestore
      .collection("chats")
      .doc(chatId)
      .get();
    final data = doc.data();

    expect(data, isNotNull);
    expect(data!["isGroup"], false);
    expect(data["members"], ["UserA", "UserB"]);
    expect(data["mediaKey"], "TEST_KEY");
  });

  //test if a chat exists and returns chat instead of creating a new one
  test("returns existing chat", () async{
    final existingId = await fakeFirebaseFirestore
      .collection("chats")
      .add({
        "isGroup": false,
        "members": ["UserA", "UserB"],
        "mediaKey": "OLD_KEY",
        "createdAt": null,
      })
      .then((doc) => doc.id);
    final chatId = await oneToOneChat.directChat("UserA", "UserB");

    expect(chatId, existingId);
  });

  //test if the getKey returns the correct media key
  test("getKey returns correct media key", () async{
    final chatId = await fakeFirebaseFirestore
      .collection("chats")
      .add({
        "isGroup": false,
        "members": ["UserA", "UserB"],
        "mediaKey": "MY_SECRET_KEY",
        "createdAt": null,
      })
      .then((doc) => doc.id);
    final key = await oneToOneChat.getKey(chatId);

    expect(key, "MY_SECRET_KEY");
  });
}