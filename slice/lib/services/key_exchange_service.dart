import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';

class KeyExchangeService {
  final _storage = const FlutterSecureStorage();
  final _algorithm = X25519(); // Standard ECDH algorithm

  // 1. Generate my Key Pair (Private & Public)
  // Call this when a user starts a new chat
  Future<SimpleKeyPair> generateKeyPair() async {
    return await _algorithm.newKeyPair();
  }

  // 2. Derive the Shared Secret (The AES Key)
  // localPrivateKey: My private key
  // remotePublicKeyBytes: The other user's public key (downloaded from Firestore)
  Future<String> deriveSharedSecret(SimpleKeyPair localPrivateKey, List<int> remotePublicKeyBytes) async {
    
    // Convert bytes back to a Public Key object
    final remotePublicKey = SimplePublicKey(
      remotePublicKeyBytes,
      type: KeyPairType.x25519,
    );

    // Perform the math
    final sharedSecretKey = await _algorithm.sharedSecretKey(
      keyPair: localPrivateKey,
      remotePublicKey: remotePublicKey,
    );

    // Extract the 32 bytes (256 bits)
    final bytes = await sharedSecretKey.extractBytes();
    
    // Convert to Hex String to use in your EncryptService
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // --- STORAGE HELPERS ---
  
  // Save keys securely so we don't lose them when app closes
  Future<void> saveSecretKey(String convoId, String hexKey) async {
    await _storage.write(key: 'key_$convoId', value: hexKey);
  }

  Future<String?> getSecretKey(String convoId) async {
    return await _storage.read(key: 'key_$convoId');
  }
}