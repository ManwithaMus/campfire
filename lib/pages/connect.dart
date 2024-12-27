import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bluetooth.dart';

class ConnectPage extends StatefulWidget{
  const ConnectPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<ConnectPage> {

  @override
  void initState() {
    findDevices();
    super.initState();
  }

  void findDevices() async {
    Bluetooth.advertise();
    Set<ScanResult> devices = await Bluetooth.scan(context);
    if(devices.isEmpty){
      print("No Devices Found!");
    }else{
      for (ScanResult d in devices){
        String deviceName = d.advertisementData.advName ?? "Unknown Device";
        String deviceID = d.device.remoteId.toString();
        print('Device Found: $deviceName (ID: $deviceID)');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth Devices"),
        ),
        body: FutureBuilder<Set<ScanResult>>(
          future: Bluetooth.scan(context), // Call your scan function
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No Devices Found!"));
            } else {
              // Build the ListView from the results
              final devices = snapshot.data!;
              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  ScanResult device = devices.elementAt(index);
                  String deviceName = device.advertisementData.advName ?? "Unknown Device";
                  String deviceID = device.device.remoteId.toString();
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(deviceName),
                    subtitle: Text("ID: $deviceID"),
                    onTap: () {
                      Bluetooth bluetooth = Bluetooth(device);
                      Navigator.pop(context, bluetooth);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
