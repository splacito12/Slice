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

  //test whether it actually can encrypt and decrypt bytes
  test("EncryptService can encrypt and decrypt actual bytes", () {
    const keyHex = "00112233445566778899aabbccddeeff"; // 32 hex chars = 16 bytes
    final service = EncryptService(keyHex);

    final original = Uint8List.fromList([1, 2, 3, 4, 5]);

    final encrypted = service.encryptBytes(original);
    final decrypted = service.decryptBytes(encrypted);

    expect(decrypted, original);
  });

  //test for different sizd AES keys
  test("EncryptService supports different sized AES keys", (){
    final original = Uint8List.fromList([10,20, 30, 40, 50]);

    //AES-128
    const key128 = "00112233445566778899aabbccddeeff";
    final size128 = EncryptService(key128);
    expect(size128.decryptBytes(size128.encryptBytes(original)), original, reason: "AES-128 failed",);

    //AES-192 
    const key192 = "00112233445566778899aabbccddeeff0011223344556677"; 
    final size192 = EncryptService(key192);
    expect(size192.decryptBytes(size192.encryptBytes(original)), original, reason: "AES-192 failed",);

    //AES-256
    const key256 = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff";
    final size256 = EncryptService(key256);
    expect(size256.decryptBytes(size256.encryptBytes(original)), original, reason: "AES-256 failed",);
  });

  //Test whether the IV changes on every encryption
  test("New IV is generated for each encryption", (){
    const keyHex = "00112233445566778899aabbccddeeff";
    final service = EncryptService(keyHex);

    final data = Uint8List.fromList([1, 2, 3, 4, 5]);

    final firstEncryption = service.encryptBytes(data);
    final secondEncryption = service.encryptBytes(data);

    final firstIv = firstEncryption.sublist(0, 12);
    final secondIv = secondEncryption.sublist(0, 12);

    //the Iv's shouldn't match
    expect(firstIv, isNot(equals(secondIv)), reason: "IV should change");
    expect(firstEncryption, isNot(equals(secondEncryption)), reason: "the ciphertext should also be different");
  });

}