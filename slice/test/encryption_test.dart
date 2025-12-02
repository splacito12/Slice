import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

// Import your EncryptService file.
// Adjust the path below to match your actual file location.
import 'package:slice/services/encryption%20_service.dart';

void main() {
  // --- SETUP ---
  // A 32-byte (256-bit) key is required for AES-256 GCM.
  // We'll use a fixed Hex string for testing.
  // NOTE: This must match the key format expected by your EncryptService constructor.
  const testKeyHex = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  
  late EncryptService encryptionService;

  setUp(() {
    // Initialize the service before each test
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
      // (Encrypted bytes combined with IV, then Base64 encoded)
      expect(base64.decode(encryptedText).length, greaterThan(originalText.length));

      // 2. Decryption
      final decryptedText = encryptionService.decryptText(encryptedText);

      // Verification 3: Check if the decrypted text matches the original
      expect(decryptedText, equals(originalText));
    });


    // --- Test Case 2: Byte Encryption and Decryption (Simulating Media) ---
    test('Should correctly encrypt and decrypt Uint8List (media bytes)', () {
      // Create a test buffer of 1MB (simulating a small image/video file)
      final originalBytes = Uint8List.fromList(List<int>.generate(1024 * 1000, (i) => i % 256));
      
      // 1. Encryption (Returns IV + Ciphertext)
      final encryptedBytes = encryptionService.encryptBytes(originalBytes);
      
      // Verification 1: Encrypted length must be longer than original length 
      // (Original length + 12-byte IV + 16-byte GCM tag)
      expect(encryptedBytes.length, greaterThan(originalBytes.length + 20));

      // 2. Decryption
      final decryptedBytes = encryptionService.decryptBytes(encryptedBytes);

      // Verification 2: Check if the decrypted bytes are exactly the same as the original
      expect(decryptedBytes, equals(originalBytes));
    });

    // --- Test Case 3: Error Handling (Short Data) ---
    test('Should throw an error if decrypting data that is too short (missing IV)', () {
      // GCM requires at least 12 bytes for the IV + some ciphertext/tag.
      final shortData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Expect the decryptBytes function to throw the custom Exception you defined
      expect(() => encryptionService.decryptBytes(shortData), 
             throwsA(predicate((e) => e is Exception && e.toString().contains("Encryption too short"))));
    });
  });
}