import 'package:campfire/pages/connect.dart';
import 'package:flutter/material.dart';

import '../bluetooth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _MyAppState();

}

class _MyAppState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Call the check method once the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) => Bluetooth.check(context));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        appBar: AppBar(title: const Text("Campfire", style: TextStyle(
            color: Colors.redAccent,
            fontSize: 46,
            fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.lightBlueAccent,
            toolbarHeight: 75),
        body: Column(children: [
          Align(alignment: Alignment.topCenter,
              child: Padding(padding: const EdgeInsets.only(top: 75.0),
                  child: ElevatedButton(onPressed: () {
                    print("Button Pressed");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConnectPage()),
                    );
                  },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(250, 75),
                        // Minimum button size (width, height)
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                        // Adjust padding
                        backgroundColor: const Color(0xFFc6c6c6),
                      ),
                      child: const Text("Connect",
                          style: TextStyle(color: Colors.redAccent)))))
        ]
        )));
  }
}
