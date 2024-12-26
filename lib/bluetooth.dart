import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class Bluetooth {
  static const String uuid = "00001111-0000-1000-8000-00805f9b34fb"; // Should be equivalent to UUID of 0x1111?

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

  static Future<Set<ScanResult>> scan(BuildContext context) async {
    print("Bluetooth.scan has been called!");

    // Ensure Bluetooth is enabled
    if (Platform.isAndroid) await FlutterBluePlus.turnOn();
    if (!await FlutterBluePlus.isOn) {
      print("Bluetooth is not enabled!");
      return {};
    }

    Completer<Set<ScanResult>> completer = Completer();
    Set<ScanResult> results = {};

    // Start scanning
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen for scan results
    var scanSubscription = FlutterBluePlus.onScanResults.listen((scanResults) {
      results.addAll(
        scanResults.where((r) =>
        r.advertisementData.serviceUuids.isNotEmpty &&
            r.advertisementData.serviceUuids[0] == Guid(uuid)),
      );
    });

    // Complete scanning after timeout
    Future.delayed(const Duration(seconds: 5), () async {
      await FlutterBluePlus.stopScan();
      await scanSubscription.cancel();
      completer.complete(results);
    });

    return completer.future;
  }


  static Future<void> advertise() async {
    final AdvertiseData advertiseData = AdvertiseData(
      includeDeviceName: true,
      serviceUuid: uuid
    );
    FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
    blePeripheral.start(advertiseData: advertiseData);

    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    // If there are any connected devices, stop advertising
    if (devices.isNotEmpty) {
      print("Device connected. Stopping advertising...");
      blePeripheral.stop(); // Stop advertising
    }

  }

}