import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:slice/services/encryption _service.dart';

void main() {

  const testKeyHex = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  
  late EncryptService encryptionService;

  setUp(() {
    encryptionService = EncryptService(testKeyHex);
  });

  group('EncryptService E2E Tests', () {
    
    // --- Test Case 1: Text Encryption and Decryption ---
    test('Should correctly encrypt and decrypt a simple string', () {
      const originalText = "This is a secret message for end-to-end testing.";
      
      // 1. Encryption
      final encryptedText = encryptionService.encryptText(originalText);
      
      // Verification 1: Check if the output looks encrypted (not the same as input)
      expect(encryptedText, isNot(equals(originalText)));
      
      // Verification 2: Check if the output is a valid Base64 string
      expect(base64.decode(encryptedText).length, greaterThan(originalText.length));

      // 2. Decryption
      final decryptedText = encryptionService.decryptText(encryptedText);

      // Verification 3: Check if the decrypted text matches the original
      expect(decryptedText, equals(originalText));
    });

    // --- Test Case 2: Error Handling (Short Data) ---
    test('Should throw an error if decrypting data that is too short (missing IV)', () {
      final shortData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Expect the decryptBytes function to throw expection
      expect(() => encryptionService.decryptBytes(shortData), 
             throwsA(predicate((e) => e is Exception && e.toString().contains("Encryption too short"))));
    });
  });
}
