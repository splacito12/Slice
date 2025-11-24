import 'dart:io';
import 'dart:typed_data';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:slice/services/media_service.dart';
import 'package:slice/services/encryption _service.dart';
import 'media_EncDec_test.mocks.dart';


@GenerateMocks([
  // ImagePicker,
  // XFile,
  EncryptService,
])
void main(){
  late MediaService mediaService;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockEncryptService mockEncryptService;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp((){
    mockFirebaseStorage = MockFirebaseStorage();
    mockEncryptService = MockEncryptService();

    mediaService = MediaService(
      storage: mockFirebaseStorage,
      encryptService: mockEncryptService,
      );
  });

  //test whether the uploaded media gets encrypted
  test("uploadMedia encrypts", () async{
    //we need to make sure the directory exists or it will continue to fail the tests
    final directory = Directory("test_resources");
    if(!directory.existsSync()){
      directory.createSync(recursive: true);
    }
    
    final file = File("test_resources/test.png");
    final rawBytes = Uint8List.fromList([1, 2, 3, 4]);
    final encryptBytes = Uint8List.fromList([9, 9, 9, 9]);

    await file.writeAsBytes(rawBytes);
    when(mockEncryptService.encryptBytes(any)).thenReturn(encryptBytes);

    final url = await mediaService.uploadMedia(
      file: file,
      convoId: "testConvo",
      );

    //verify encryption happens
    verify(mockEncryptService.encryptBytes(rawBytes)).called(1);

    //verify it has been uploaded
    final fileName = Uri.decodeFull(url)
      .split('/')
      .last
      .split('?')
      .first;
    final ref = mockFirebaseStorage
      .ref()
      .child('chat_media/testConvo/$fileName');
    final upload = await ref.getData();

    expect(upload, encryptBytes);
    expect(upload, isNot(rawBytes));
  });

  //test whether decryption works
  test("decryption downloads encyrption and decrypts", () async{
    final encryptBytes = Uint8List.fromList([9, 9, 9, 9]);
    final decryptBytes = Uint8List.fromList([1, 2, 3, 4]);

    final ref = mockFirebaseStorage
      .ref()
      .child("chat_media/testConvo/test.png");
    await ref.putData(encryptBytes);

    when(mockEncryptService.decryptBytes(encryptBytes)).thenReturn(decryptBytes);

    final result = await mediaService.decrypt("chat_media/testConvo/test.png");

    verify(mockEncryptService.decryptBytes(encryptBytes)).called(1);
    expect(result, decryptBytes);
  });
}