import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:slice/chat_page.dart';
import 'package:slice/services/media_service.dart';
import 'package:slice/services/message_service.dart';

import 'chatPage_test.mocks.dart';

//mock classes
@GenerateMocks([
  MediaService,
  MessageService,
])
void main(){
  late MockMediaService mockMediaService;
  late MockMessageService mockMessageService;
  late FakeFirebaseFirestore fakeFirebaseFirestore;

  Widget makeTestable(Widget child){
    return MaterialApp(home: child);
  }

  setUp(() {
    mockMessageService = MockMessageService();
    mockMediaService = MockMediaService();
    fakeFirebaseFirestore = FakeFirebaseFirestore();
  });

  //test whether sending a text will call the messageService.messageSend function
  testWidgets("Text calls messageService.messageSend", (tester) async{
    await tester.pumpWidget(
      makeTestable(ChatPage(
        convoId: "testConvo123", 
        currUserId: "me", 
        currUserName: "Me",
        chatPartnerId: "testPartner",
        mediaService: mockMediaService,
        messageService: mockMessageService,
        firestore: fakeFirebaseFirestore,
        )),
    );

    //enter a text
    await tester.enterText(find.byType(TextField), "nice to meet you");
    await tester.pump();

    //send
    final sendBtn = find.byIcon(Icons.send);
    expect(sendBtn, findsOneWidget);

    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    //verify
    verify(mockMessageService.messageSend(
      convoId: "testConvo123",
      senderId: "me",
      text: "nice to meet you",
      mediaType: null,
      mediaUrl: "",
      )).called(1);
  });

  //test that the _pickMedia function sends an image
  testWidgets("_pickMedia sends image", (tester) async{
    final file = File('fake_image.jpg');

    when(mockMediaService.pickMedia(true)).thenAnswer((_) async => file);
    when(mockMediaService.uploadMedia(file: file, convoId: 'fakeConvo123')).thenAnswer((_) async => "fake_url");

    await tester.pumpWidget(
      makeTestable(ChatPage(
        convoId: "fakeConvo123", 
        currUserId: "me", 
        currUserName: "Me",
        chatPartnerId: "fakePartner",
        mediaService: mockMediaService,
        messageService: mockMessageService,
        firestore: fakeFirebaseFirestore,
        )),
    );

    final imageBtn = find.byIcon(Icons.image);
    await tester.tap(imageBtn);

    await tester.pumpAndSettle();

    //verify
    verify(mockMediaService.pickMedia(true)).called(1);
    verify(mockMediaService.uploadMedia(file: file, convoId: "fakeConvo123")).called(1);

    verify(mockMessageService.messageSend(
      convoId: "fakeConvo123", 
      senderId: "me",
      text: "",
      mediaUrl: "fake_url",
      mediaType: "image",
      )).called(1);
  });

  //test that the _pickMedia function returns null
  testWidgets("_pickMedia returns null", (tester) async{
    when(mockMediaService.pickMedia(true)).thenAnswer((_) async => null);

    await tester.pumpWidget(
      makeTestable(ChatPage(
        convoId: "fakeConvo123", 
        currUserId: "me", 
        currUserName: "Me",
        chatPartnerId: "fakePartner",
        mediaService: mockMediaService,
        messageService: mockMessageService,
        firestore: fakeFirebaseFirestore,
        )),
    );

    final imageBtn = find.byIcon(Icons.image);

    await tester.tap(imageBtn);
    await tester.pumpAndSettle();

    //verify
    verify(mockMediaService.pickMedia(true)).called(1);
    verifyNever(mockMessageService.messageSend(
      convoId: anyNamed("convoId"), 
      senderId: anyNamed("senderId"),
      text: anyNamed("text"),
      mediaUrl: anyNamed("mediaUrl"),
      mediaType: anyNamed("mediaType"),
      ));
  });

  //test whether the group chat shows the sender names and the name
  testWidgets("Group Chat shows sender names and group name", (tester)async{
    await fakeFirebaseFirestore
      .collection('chats')
      .doc("groupChat123")
      .collection('messages')
      .add({
        'senderId': 'testUser',
        'senderName': 'Bob',
        'text': 'Hello everyone',
        'mediaType': '',
        'mediaUrl': '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      //message from the current user
      await fakeFirebaseFirestore
        .collection('chats')
        .doc("groupChat123")
        .collection('messages')
        .add({
          'senderId': 'me',
          'senderName': 'Me',
          'text': 'Hello Bob!',
          'mediaType': '',
          'mediaUrl': '',
          'timestamp': DateTime.now().millisecondsSinceEpoch + 1,
        });

        await tester.pumpWidget(
          MaterialApp(
            home: ChatPage(
              convoId: "groupChat123",
              currUserId: "me",
              currUserName: "Me",
              isGroupChat: true,
              groupName: "Our GC",
              mediaService: mockMediaService,
              messageService: mockMessageService,
              firestore: fakeFirebaseFirestore,
              ),
          ),
        );

        await tester.pumpAndSettle();

        //assertions
        expect(find.text("Our GC"), findsOneWidget);
        expect(find.text("Bob"), findsOneWidget);
        expect(find.text("Me"), findsNothing);
        expect(find.text("Hello everyone"), findsOneWidget);
        expect(find.text("Hi Bob!"), findsOneWidget);
  });
}