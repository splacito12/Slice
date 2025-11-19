import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:slice/services/message_service.dart';
import 'message_test.mocks.dart';

//mock classes
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
])

void main(){
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockCollectionReference<Map<String, dynamic>> mockMessagesCollection;

  late MessageService messageService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockMessagesCollection = MockCollectionReference();

    //firestore collections
    when(mockFirestore.collection('chats')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.collection('messages')).thenReturn(mockMessagesCollection);

    //return a future when adding a message
    when(mockMessagesCollection.add(any)).thenAnswer((_) async => mockDocumentReference);

    messageService = MessageService(firestore: mockFirestore);
  });

  //test that the messageSend function sends the correct data to firestore
  test("messageData sends correct data to firestore", () async{
    await messageService.messageSend(
      convoId: "testConvo",
      senderId: "testUser",
      text: "Hi! How are you?",
      mediaUrl: "",
      mediaType: null,
      );

      //use verify
      verify(mockMessagesCollection.add(argThat(
        allOf(
          containsPair("senderId", "testUser"),
          containsPair("text", "Hi! How are you?"),
          containsPair("mediaUrl", ""),
          containsPair("mediaType", null),
        ),
      ))).called(1);
  });

  //test so that the messageSend function sends the media message correctly
  test("messageSend sends media correctly", () async{
    await messageService.messageSend(
      convoId: "testConvo", 
      senderId: "testUser",
      text: "",
      mediaUrl: "https://example.com/file.jpg",
      mediaType: "image",
      );

      //verify
      verify(mockMessagesCollection.add(argThat(
        allOf(
          containsPair("senderId", "testUser"),
          containsPair("text", ""),
          containsPair("mediaUrl", "https://example.com/file.jpg"),
          containsPair("mediaType", "image"),
        ),
      ))).called(1);
  });
}