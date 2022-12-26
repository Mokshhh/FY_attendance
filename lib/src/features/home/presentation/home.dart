import 'package:arp_scanner/arp_scanner.dart';
import 'package:arp_scanner/device.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAuthenticated = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FirebaseAuth.instance.currentUser?.email ?? "",
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go("/");
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: isAuthenticated
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.done_outline_rounded,
                    color: Colors.green,
                    size: 48,
                  ),
                  Text(
                    "Authenticated",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w900),
                  ),
                  Expanded(child: ScannerWIFI())
                ],
              )
            : TextButton(
                child: const Text("Authenticate"),
                onPressed: () async {
                  try {
                    final LocalAuthentication auth = LocalAuthentication();
                    final bool canAuthenticateWithBiometrics =
                        await auth.canCheckBiometrics;
                    final bool canAuthenticate =
                        canAuthenticateWithBiometrics ||
                            await auth.isDeviceSupported();
                    print(canAuthenticate);
                    final List<BiometricType> availableBiometrics =
                        await auth.getAvailableBiometrics();
                    if (availableBiometrics.isNotEmpty) {
                      print(availableBiometrics);
                    }

                    if (availableBiometrics.contains(BiometricType.strong) ||
                        availableBiometrics.contains(BiometricType.face)) {
                      final bool didAuthenticate = await auth.authenticate(
                          localizedReason:
                              'Please authenticate to show account balance',
                          options:
                              const AuthenticationOptions(biometricOnly: true));
                      if (didAuthenticate) {
                        setState(() {
                          isAuthenticated = true;
                        });
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
      ),
    );
  }
}

class ScannerWIFI extends StatefulWidget {
  const ScannerWIFI({Key? key}) : super(key: key);

  @override
  State<ScannerWIFI> createState() => _ScannerWIFIState();
}

class _ScannerWIFIState extends State<ScannerWIFI> {
  String _result = '';

  @override
  void initState() {
    super.initState();
    ArpScanner.onScanning.listen((Device device) {
      setState(() {
        _result =
            "${_result}Mac:${device.mac} ip:${device.ip} hostname:${device.hostname} time:${device.time} vendor:${device.vendor} \n";
      });
    });
    ArpScanner.onScanFinished.listen((List<Device> devices) {
      setState(() {
        _result = "${_result}total: ${devices.length} Students attended. (updated in database)";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () async {
              await ArpScanner.cancel();
            },
          ),
          TextButton.icon(
            onPressed: () async {
              await ArpScanner.scan();
              setState(() {
                _result = "";
              });
            },
            icon: const Icon(Icons.scanner_sharp),
            label: const Text("Search Attended Users"),
          ),
          Text(_result),
        ],
      ),
    );
  }
}
