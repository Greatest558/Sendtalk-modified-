import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  final Map<String, SecretKey> _sessions = {};
  final algorithm = AesGcm.with256bits();

  void storeSessionKey(String peerId, SecretKey key) {
    _sessions[peerId] = key;
  }

  SecretKey? getSessionKey(String peerId) {
    return _sessions[peerId];
  }

  Future<String> encryptMessage(String message, SecretKey key) async {
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      message.codeUnits,
      secretKey: key,
      nonce: nonce,
    );
    return base64Encode([...nonce, ...secretBox.cipherText, ...secretBox.mac.bytes]);
  }
 Future<String> decryptMessage(String combined, SecretKey key) async {
    final bytes = base64Decode(combined);
    final nonce = bytes.sublist(0, 12);
    final cipherText = bytes.sublist(12, bytes.length - 16);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final box = SecretBox(cipherText, nonce: nonce, mac: mac);
    final clear = await algorithm.decrypt(box, secretKey: key);
    return String.fromCharCodes(clear);
  }