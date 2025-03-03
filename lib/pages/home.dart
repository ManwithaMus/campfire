import 'package:campfire/pages/connect.dart';
import 'package:campfire/pages/send.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bluetooth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _MyAppState();

}

class _MyAppState extends State<HomePage> {
  ScanResult? selectedDevice;
  Bluetooth? bluetoothDevice;

  @override
  void initState() {
    super.initState();
    // Call the check method once the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) => Bluetooth.check(context));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Campfire",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 46,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlueAccent,
          toolbarHeight: 75,
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 75.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConnectPage(),
                      ),
                    );

                    if (result != null && result is ScanResult) {
                      // Handle the returned ScanResult
                      setState(() {
                        selectedDevice = result;
                        bluetoothDevice = Bluetooth(result);
                      });

                      String deviceName = result.advertisementData.advName ?? "Unknown Device";
                      String deviceID = result.device.remoteId.toString();
                      print('Selected Device: $deviceName (ID: $deviceID)');
                    } else {
                      print('No device was selected.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 75), // Minimum button size (width, height)
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // Adjust padding
                    backgroundColor: const Color(0xFFc6c6c6),
                  ),
                  child: const Text(
                    "Connect",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 75.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDevice != null && bluetoothDevice != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendPage(
                            bluetooth: bluetoothDevice, // Pass the selectedDevice
                          ),
                        ),
                      );
                    } else {
                      // Optionally show a dialog or toast indicating no device is selected
                      print('No device selected.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 75),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: const Color(0xFFc6c6c6),
                  ),
                  child: const Text(
                    "Send Messages",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            if (selectedDevice != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Connected to: ${selectedDevice!.advertisementData.advName ?? "Unknown Device"}',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
