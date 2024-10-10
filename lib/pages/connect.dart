import 'package:flutter/material.dart';

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
    super.initState();
    findDevices(); // Something here might need to be changed to force the context to load before any possible error message!
  }

  void findDevices(){
    Bluetooth.advertise();
    print(Bluetooth.scan(context));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: ListView(),));
  }
}
