import 'dart:ffi';

import 'package:flutter/material.dart';
import '../bluetooth.dart';

class SendPage extends StatefulWidget {
  final Bluetooth? bluetooth;

  const SendPage({Key? key, required this.bluetooth}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final TextEditingController _messageController = TextEditingController();
  String _receivedMessage = '';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      //await widget.bluetooth.sendData(message); // TODO Send data to the device connected to in Bluetooth class
    }
  }

  void _startListening() {
    //Future<String?> read = widget.bluetooth.readData(); // TODO Figure out how to read data from other device
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Messages"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: "Enter message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text("Send"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startListening,
              child: const Text("Start Listening"),
            ),
            const SizedBox(height: 16),
            Text(
              "Received Message: $_receivedMessage",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
