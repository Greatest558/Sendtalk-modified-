import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MeshService {
  final _messageStreamController = StreamController<Map<String, String>>.broadcast();
  final _voiceStreamController = StreamController<Uint8List>.broadcast();
  final List<BluetoothDevice> _connectedDevices = [];

  Stream<Map<String, String>> get messageStream => _messageStreamController.stream;
  Stream<Uint8List> get voiceStream => _voiceStreamController.stream;

  Future<void> startMesh() async {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        try {
          final device = r.device;
          await device.connect(timeout: Duration(seconds: 3));
          _connectedDevices.add(device);
          _listenToDevice(device);
        } catch (_) {}
      }
    });
  }

  void _listenToDevice(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
[8/13, 12:09 PM] ChatGPT: if (char.properties.notify) {
          await char.setNotifyValue(true);
          char.value.listen((data) {
            final raw = utf8.decode(data);
            _handleIncomingPacket(raw);
          });
        }
      }
    }
  }

  void _handleIncomingPacket(String raw) {
    final data = jsonDecode(raw);
    final type = data['type'];
    final to = data['to'];
    final from = data['from'];
    final payload = data['payload'];

    if (to != 'your_device_id') return;

    if (type == 'text') {
      _messageStreamController.add({'from': from, 'message': payload});
    } else if (type == 'voice') {
      _voiceStreamController.add(base64Decode(payload));
    }
  }

  Future<void> sendVoicePacket(Uint8List packet, String to) async {
    final encoded = base64Encode(packet);
    final map = {
      'type': 'voice',
      'to': to,
      'from': 'your_device_id',
      'payload': encoded,
    };
    _broadcastPacket(jsonEncode(map));
  }

  Future<void> sendMessage(String message, String to) async {
    final map = {
      'type': 'text',
      'to': to,
      'from': 'your_device_id',
      'payload': message,
    };
    _broadcastPacket(jsonEncode(map));
  }

  void _broadcastPacket(String jsonString) async {
    final data = utf8.encode(jsonString);
[8/13, 12:09 PM] ChatGPT: for (var device in _connectedDevices) {
      try {
        final services = await device.discoverServices();
        for (var service in services) {
          for (var char in service.characteristics) {
            if (char.properties.write) {
              await char.write(data, withoutResponse: true);
            }
          }
        }
      } catch (_) {}
    }
  }
}
