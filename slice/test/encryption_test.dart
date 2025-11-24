import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import 'package:slice/services/encryption _service.dart';
import 'package:slice/services/keys_generate.dart';

void main(){
  //test whether generating a media key generates a 32-byte hex
  test("generatMediaKey creates 32 byte hex", (){
    final key = generateMediaKey();

    expect(key.length, 64);
    final exHex = RegExp(r'^[0-9a-f]+$');
    expect(exHex.hasMatch(key), true);
  });

  //test encryption and decryption
  test("encryption and decryption", (){
    final key = generateMediaKey();
    final service = EncryptService(key);

    final og = Uint8List.fromList(List<int>.generate(5000, (i) => i % 256));
    final encrypted = service.encryptBytes(og);
    final decrypted = service.decryptBytes(encrypted);

    expect(decrypted, og);
  });

  //test whether the decryption throws when the IV is short
  test("decrypt throws when short", (){
    final key = generateMediaKey();
    final service = EncryptService(key);

    expect(() => service.decryptBytes(Uint8List(5)), throwsException);
  });
}