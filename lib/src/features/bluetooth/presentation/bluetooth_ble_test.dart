
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:wifi_scan/wifi_scan.dart';

class BluetoothBleTestScreen extends StatefulWidget {
  const BluetoothBleTestScreen({super.key});

  @override
  State<BluetoothBleTestScreen> createState() => _BluetoothBleTestScreenState();
}

class _BluetoothBleTestScreenState extends State<BluetoothBleTestScreen> {
  void _startScan() async {
  // check platform support and necessary requirements
  final can = await WiFiScan.instance.canStartScan(askPermissions: true);
  switch(can) {
    case CanStartScan.yes:
      // start full scan async-ly
      final isScanning = await WiFiScan.instance.startScan();
      //...
      break;
    // ... handle other cases of CanStartScan values
  }
}

void _getScannedResults() async {
  print("Get scanned results");
  // check platform support and necessary requirements
  final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
  switch(can) {
    case CanGetScannedResults.yes:
      // get scanned results
      final accessPoints = await WiFiScan.instance.getScannedResults();
      print(accessPoints);
      // ...
      break;
    // ... handle other cases of CanGetScannedResults values
  }
}

  final flutterReactiveBle = FlutterReactiveBle();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: () {
          // _startScan();
          _getScannedResults();
        }, child: const Text("Scan")),
      ),
    );
  }
}
