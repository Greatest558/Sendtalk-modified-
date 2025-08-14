import 'package:flutter/material.dart';
import 'crypto_service.dart';
import 'mesh_service.dart';
import 'voice_service.dart';

class CallScreen extends StatefulWidget {
  final String peerId;
  final CryptoService crypto;
  final MeshService mesh;
  final VoiceService voice;

  CallScreen({
    required this.peerId,
    required this.crypto,
    required this.mesh,
    required this.voice,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _calling = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    final key = widget.crypto.getSessionKey(widget.peerId);
    if (key == null) return;
    widget.mesh.voiceStream.listen((packet) {
      widget.voice.playPacket(packet, key);
    });
  }

  void _startCall() {
    final key = widget.crypto.getSessionKey(widget.peerId);
    if (key == null) return;
    widget.voice.startRecording(key, (packet) {
      widget.mesh.sendVoicePacket(packet, widget.peerId);
    });
    setState(() => _calling = true);
  }

  void _endCall() async { await widget.voice.stopRecording();
    await widget.voice.stopPlayback();
    setState(() => _calling = false);
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Call: ${widget.peerId}')),
      body: Center(
        child: ElevatedButton(
          onPressed: _calling ? _endCall : _startCall,
          child: Text(_calling ? 'End Call' : 'Start Call'),
        ),
      ),
    );
  }
}