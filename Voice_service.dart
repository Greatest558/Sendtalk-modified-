import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'crypto_service.dart';

class VoiceService {
  final _recorder = FlutterSoundRecorder();
  final _player = FlutterSoundPlayer();
  bool _isInited = false;

  Future<void> init() async {
    if (_isInited) return;
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
    _isInited = true;
  }

  void startRecording(SecretKey key, Function(Uint8List) onPacket) {
    _recorder.startRecorder(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      toStream: (buffer) async {
        final encrypted = await AesGcm.with256bits().encrypt(
          buffer!,
          secretKey: key,
          nonce: AesGcm.with256bits().newNonce(),
        );
        onPacket(Uint8List.fromList([
          ...encrypted.nonce,
          ...encrypted.cipherText,
          ...encrypted.mac.bytes,
        ]));
      },
    );
  }

  Future<void> playPacket(Uint8List data, SecretKey key) async {
    final nonce = data.sublist(0, 12);
 final cipherText = data.sublist(12, data.length - 16);
    final mac = Mac(data.sublist(data.length - 16));
    final box = SecretBox(cipherText, nonce: nonce, mac: mac);

    final decrypted = await AesGcm.with256bits().decrypt(box, secretKey: key);
    await _player.startPlayer(
      fromDataBuffer: decrypted,
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
    );
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
  }

  Future<void> stopPlayback() async {
    await _player.stopPlayer();
  }
}