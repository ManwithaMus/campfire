import 'dart:io';

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
        print("This should have run!");
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
    subscription.cancel(); // Used to make sure we don't have duplicate listeners
  }

}