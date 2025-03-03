import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class Bluetooth {
  static const String uuid = "00001111-0000-1000-8000-00805f9b34fb"; // Should be equivalent to UUID of 0x1111? (identifier for other devices running my app)
  final ScanResult scanResult;
  late final BluetoothDevice device; // This is the object for the current "peripheral" device connected to!

  Bluetooth(this.scanResult) : device = scanResult.device;

  // Below functions implement all of the functionality required to transmit messages through BLE
  Future<void> connect() async{
    try {
      print('Connecting to ${device.platformName} (${device.remoteId})...');
      await device.connect();
      print('Connected to ${device.platformName}');
    } catch (e) {
      print('Failed to connect: $e');
    }
  }

  Future<void> disconnect() async{
    try {
      print('Disconnecting from ${device.name}...');
      await device.disconnect();
      print('Disconnected from ${device.name}');
    } catch (e) {
      print('Failed to disconnect: $e');
    }
  }

  /// Sends data to the device via a writable characteristic.
  Future<void> sendData(String data, BluetoothCharacteristic characteristic) async {
    try {
      print('Sending data: $data');
      await characteristic.write(data.codeUnits, withoutResponse: true);
      print('Data sent');
    } catch (e) {
      print('Failed to send data: $e');
    }
  }

  /// Reads data from a readable characteristic.
  Future<String?> readData(BluetoothCharacteristic characteristic) async {
    try {
      print('Reading data...');
      List<int> value = await characteristic.read();
      String result = String.fromCharCodes(value);
      print('Data read: $result');
      return result;
    } catch (e) {
      print('Failed to read data: $e');
      return null;
    }
  }

  // Below methods are static and for the most part should be used prior to constructing an instance of Bluetooth
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