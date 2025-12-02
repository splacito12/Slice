import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';


//create the encryption class
class EncryptService{
  final Key key;

  EncryptService(String hexKey) : 
    key = Key(Uint8List.fromList(
      List.generate(hexKey.length ~/ 2,
      (i) => int.parse(hexKey.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    ));
  EncryptService.fromBase64(Uint8List keyBytes) : key = Key(keyBytes);

  //create a randome IV
  IV _randomIV(){
    final ran = Random.secure();
    final bytes = List<int>.generate(12, (_) => ran.nextInt(256));

    return IV(Uint8List.fromList(bytes));
  }

  //here we will do the encyrption of media
  Uint8List encryptBytes(Uint8List data){
    final iv = _randomIV();
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encryptBytes(data, iv: iv);

    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }

  Uint8List decryptBytes(Uint8List encryptedData){
    if(encryptedData.length < 12){
      throw Exception("Encryption too short");
    }

    final iv = IV(encryptedData.sublist(0, 12));
    final decipher = Encrypted(encryptedData.sublist(12));

    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final decrypted = encrypter.decryptBytes(decipher, iv: iv);

    
    return Uint8List.fromList(decrypted);
  }
  // 1. Encrypts a String and returns a Base64 String
  String encryptText(String plainText) {
    final plainBytes = utf8.encode(plainText);
    // Now this works because it is inside the class
    final encryptedBytes = encryptBytes(Uint8List.fromList(plainBytes)); 
    return base64.encode(encryptedBytes);
  }

  // 2. Decrypts a Base64 String and returns the original String
  String decryptText(String base64Encrypted) {
    final encryptedBytes = base64.decode(base64Encrypted);
    // Now this works because it is inside the class
    final decryptedBytes = decryptBytes(Uint8List.fromList(encryptedBytes)); 
    return utf8.decode(decryptedBytes);
  }
}