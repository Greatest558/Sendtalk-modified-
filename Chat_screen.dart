import 'package:flutter/material.dart';
import 'mesh_service.dart';
import 'crypto_service.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final MeshService mesh;
  final CryptoService crypto;

  ChatScreen({required this.peerId, required this.mesh, required this.crypto});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    widget.mesh.messageStream.listen((msg) async {
      if (msg['from'] == widget.peerId) {
        final key = widget.crypto.getSessionKey(widget.peerId);
        if (key != null) {
          final decrypted = await widget.crypto.decryptMessage(msg['message']!, key);
          setState(() {
            _messages.add({'from': widget.peerId, 'text': decrypted});
          });
        }
      }
    });
  }

  void _sendMessage() async {
    final key = widget.crypto.getSessionKey(widget.peerId);
    if (key == null) return;
    final text = _controller.text.trim();
 if (text.isEmpty) return;
    final encrypted = await widget.crypto.encryptMessage(text, key);
    await widget.mesh.sendMessage(encrypted, widget.peerId);
    setState(() {
      _messages.add({'from': 'me', 'text': text});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.peerId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return ListTile(
                  title: Text(msg['text']!),
                  subtitle: Text(msg['from']!),
                  tileColor: msg['from'] == 'me' ? Colors.green[50] : Colors.grey[200],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Message')),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          )
          ],
      ),
    );
  }
}
