import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SendPage extends StatefulWidget{
  final BluetoothDevice device;

  const SendPage({super.key, required this.device});

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _txCharacteristic; // Characteristic for transmitting data
  BluetoothCharacteristic? _rxCharacteristic; // Characteristic for receiving data
  TextEditingController _textController = TextEditingController();
  String _receivedData = "";

  @override
  void initState() {
    super.initState();
    _device = widget.device;
    _connectToDevice();
  }

  // Connect to the Bluetooth device and discover services and characteristics
  Future<void> _connectToDevice() async {
    try {
      await _device!.connect();
      List<BluetoothService> services = await _device!.discoverServices();
      _setupCharacteristics(services);
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  // Find the necessary characteristics for sending/receiving data
  void _setupCharacteristics(List<BluetoothService> services) {
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        // Assuming characteristic for sending data is writeable and for receiving is readable
        if (characteristic.properties.write) {
          _txCharacteristic = characteristic;
        }
        if (characteristic.properties.read) {
          _rxCharacteristic = characteristic;
          _startListeningForData();
        }
      }
    }
  }

  // Start listening for received data
  void _startListeningForData() {
    if (_rxCharacteristic != null) {
      _rxCharacteristic!.setNotifyValue(true);
      _rxCharacteristic!.value.listen((value) {
        setState(() {
          _receivedData = String.fromCharCodes(value);
        });
      });
    }
  }

  // Send data to the Bluetooth device
  Future<void> _sendData() async {
    if (_txCharacteristic != null) {
      String dataToSend = _textController.text;
      List<int> bytes = dataToSend.codeUnits; // Convert text to byte array
      await _txCharacteristic!.write(bytes);
      setState(() {
        _textController.clear();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _device!.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Data to Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text area to display received data
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _receivedData.isEmpty ? "No data received" : _receivedData,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Text field for user to input data to send
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter data to send',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to send data
            ElevatedButton(
              onPressed: _sendData,
              child: const Text('Send Data'),
            ),
          ],
        ),
      ),
    );
  }
}