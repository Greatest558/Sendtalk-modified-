import 'package:flutter/material.dart';
import 'crypto_service.dart';
import 'mesh_service.dart';
import 'voice_service.dart';
import 'chat_screen.dart';
import 'call_screen.dart';

void main() {
  runApp(SendtalkApp());
}

class SendtalkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sendtalk',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final mesh = MeshService();
  final crypto = CryptoService();
  final voice = VoiceService();
  final peerId = 'user_b'; // Replace with real peer ID later

  HomeScreen() {
    mesh.startMesh();
    voice.init();
    // TEMPORARY: Fake key setup (replace with real key exchange)
    final fakeKey = crypto.algorithm.newSecretKeySync();
    crypto.storeSessionKey(peerId, fakeKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sendtalk')), body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Chat with peerId'),
              onPressed: () 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      peerId: peerId,
                      mesh: mesh,
                      crypto: crypto,
                    ),
                  ),
                );
              ,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Voice CallpeerId'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      peerId: peerId,
                      crypto: crypto,
                      mesh: mesh,
                      voice: voice,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
