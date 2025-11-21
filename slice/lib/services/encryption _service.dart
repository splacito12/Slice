import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

//create the encryption class
class EncryptService{
  final Key key;
  final IV iv;

  EncryptService(String sharedKey) : 
    key = Key.fromUtf8(sharedKey.padRight(32).substring(0, 32)),
    iv = IV.fromLength(16);

  //here we will do the encyrption of media
  Uint8List encryptBytes(Uint8List data){
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encryptBytes(data, iv: iv);

    return Uint8List.fromList(encrypted.bytes);
  }

  Uint8List decryptBytes(Uint8List encryptedData){
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decryptBytes(Encrypted(encryptedData), iv: iv);
    
    return Uint8List.fromList(decrypted);
  }
}