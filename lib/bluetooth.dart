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
    // Turn on Bluetooth for Android devices if needed
    if (Platform.isAndroid) { // Figure out what to do with this or if it's even needed?
      await FlutterBluePlus.turnOn();
    }

    var isBluetoothOn = await FlutterBluePlus.isOn;
    if(!isBluetoothOn){
      print("There is something wrong with the Bluetooth!");
    }

    // Check the Bluetooth adapter state
    var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

        // Listen for scan results
        var scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
          if (results.isNotEmpty) {
            print("Found ${results.length} devices.");

            for (ScanResult r in results) {
              print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            }
            ScanResult lastResult = results.last;
            BluetoothDevice device = lastResult.device;
          }else{
            print("Could not find any Bluetooth devices!");
          }
        });

        // Stop scanning after the timeout and cancel the subscription
        //FlutterBluePlus.stopScan();
        FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
      } else {
        // Handle Bluetooth being in an improper state
        // String error = state as String;
        String error = "ERROR";
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