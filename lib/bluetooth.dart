import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Bluetooth {

  static Future<void> check(BuildContext context) async {
    if (await FlutterBluePlus.isSupported == false) {
      showDialog(
        context: context,
        builder: (context) =>
        const AlertDialog(
          title: Text("Bluetooth is not supported by this device!"),
        ),
      );
      return;
    }
    print("Bluetooth should be working just fine!");
  }

  static Future<void> scan(BuildContext context) async {
    print("Bluetooth.scan has been called!");
    if (Platform.isAndroid) { // Figure out what to do with this or if it's even needed?
      await FlutterBluePlus.turnOn();
    }
    var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {

        var subscription = FlutterBluePlus.onScanResults.listen((results) {
          if (results.isNotEmpty) {
            ScanResult r = results.last; // the most recently found device
            print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
          }
        },
          onError: (e) => print(e),
        );

// cleanup: cancel subscription when scanning stops
        FlutterBluePlus.cancelWhenScanComplete(subscription);

// Wait for Bluetooth enabled & permission granted
// In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states

// Start scanning w/ timeout
// Optional: use `stopScan()` as an alternative to timeout
        FlutterBluePlus.startScan(
            //withServices:[Guid("180D")], // match any of the specified services
            //withNames:["Bluno"], // *or* any of the specified names
            timeout: Duration(seconds:15));

// wait for scanning to stop
        FlutterBluePlus.isScanning.where((val) => val == false).first;


      } else {
        String error = state as String;
        String errorMsg = "Error with Bluetooth Device code: $error";
        showDialog(
          context: context,
          builder: (context) =>
          AlertDialog(
            title: Text(errorMsg),
          ),
        );
      }
    });
    print("Testing if the program gets this far in execution!");
    //subscription.cancel(); // Used to make sure we don't have duplicate listeners
  }

}