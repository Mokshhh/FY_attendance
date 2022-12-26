import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothTestScreen extends StatefulWidget {
  const BluetoothTestScreen({super.key});

  @override
  State<BluetoothTestScreen> createState() => _BluetoothTestScreenState();
}

class _BluetoothTestScreenState extends State<BluetoothTestScreen> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  final List<ScanResult> scannedResult = [];
  _addDeviceToScannedResultlist(final ScanResult device) {
    if (!scannedResult.contains(device)) {
      setState(() {
        scannedResult.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
        device.discoverServices().then((value) => print(value));
      }
    });
    // flutterBlue.scanResults.listen((List<ScanResult> results) {
    //   for (ScanResult result in results) {
    //     if (result.rssi > -100) {
    //       _addDeviceToScannedResultlist(result);
    //     }
    //     // _addDeviceTolist(result.device);
    //   }
    // });
    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: SafeArea(child: _buildListViewOfScannedResults()),
      body: SafeArea(child: _buildListViewOfDevices()),
    );
  }

  ListView _buildListViewOfScannedResults() {
    List<Widget> containers = <Widget>[];
    for (ScanResult result in scannedResult) {
      containers.add(
        Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(result.device.name == ''
                        ? '(unknown device)'
                        : result.device.name),
                    Text(result.device.id.toString()),
                    Text(result.rssi.toString()),
                    Text(result.advertisementData.toString()),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.black87),
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  List<BluetoothService> services =
                      await result.device.discoverServices();
                  for (var service in services) {
                    print(service);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in devicesList) {
      containers.add(
        Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.black87),
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}
