import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test app',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
        ),
        body: Center(
          child: Column(             // Use a Column to stack widgets vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Hello World'),
              SizedBox(height: 20),  // Add space between the text and button
              ElevatedButton(
                onPressed: () {
                  // Define the action to perform when the button is clicked
                  _onButtonClicked();
                },
                child: const Text('Click Me'),  // Button label
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onButtonClicked() async {
    print("The button has been clicked!");
    if(await FlutterBluePlus.isSupported == false){
      print("Bluetooth is not supported by this platform!");
      return;
    }

    var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // Bluetooth is enabled, proceed with BLE operations
        // Start scanning
        await FlutterBluePlus.startScan(
          timeout: Duration(seconds: 15),
          //withServices: [Guid("180D")],   // Filter by service UUID (optional)
          //withNames: ["Bluno"],           // Filter by device name (optional)
        );
        BluetoothDevice? device;
        Completer<BluetoothDevice> deviceCompleter = Completer(); // Create a Completer to handle the device

        var subscription = FlutterBluePlus.onScanResults.listen((results) {
          if (results.isNotEmpty) {
            for(ScanResult r in results){
              print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            }
            ScanResult r = results.last;
            device = r.device;


            if (!deviceCompleter.isCompleted) {
              deviceCompleter.complete(device);
            }

          }
        }, onError: (e) => print(e));
        FlutterBluePlus.cancelWhenScanComplete(subscription); // Cancel the subscription when the scan stops

        // Wait for scanning to stop
        await FlutterBluePlus.isScanning.where((val) => val == false).first;
        await device?.connect(autoConnect: true);
        device?.connectionState.listen((BluetoothConnectionState state) async {
          if (state == BluetoothConnectionState.connected) {
            print('Connected to the device!');
            // Proceed with discovering services
            List<BluetoothService>? services = await device?.discoverServices();

          } else if (state == BluetoothConnectionState.disconnected) {
            print('Disconnected from the device!');
            // Handle disconnection
          }
        });
      } else {
        // Bluetooth is off or in an error state, handle appropriately
        if (Platform.isAndroid) {
          FlutterBluePlus.turnOn(); // Request the user to turn on Bluetooth
        }
        print("There is something wrong with the Bluetooth device!");
      }
    });
    subscription.cancel(); // Cancel the subscription when done
  }
}