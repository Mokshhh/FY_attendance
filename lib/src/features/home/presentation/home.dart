import 'package:arp_scanner/arp_scanner.dart';
import 'package:arp_scanner/device.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAuthenticated = false;

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FirebaseAuth.instance.currentUser?.displayName ?? "",
        ),
        leading: Image.network(FirebaseAuth.instance.currentUser!.photoURL!),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child:
            // isAuthenticated
            //     ? Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: const [
            //           Icon(
            //             Icons.done_outline_rounded,
            //             color: Colors.green,
            //             size: 48,
            //           ),
            //           Text(
            //             "Authenticated",
            //             style: TextStyle(
            //                 color: Colors.green, fontWeight: FontWeight.w900),
            //           ),
            //           Expanded(child: ScannerWIFI()),
            //         ],
            //       )
            //     :
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextButton(
            //   child: const Text("Authenticate"),
            //   onPressed: () async {
            //     try {
            //       final LocalAuthentication auth = LocalAuthentication();
            //       final bool canAuthenticateWithBiometrics =
            //           await auth.canCheckBiometrics;
            //       final bool canAuthenticate =
            //           canAuthenticateWithBiometrics ||
            //               await auth.isDeviceSupported();
            //       print(canAuthenticate);
            //       final List<BiometricType> availableBiometrics =
            //           await auth.getAvailableBiometrics();
            //       if (availableBiometrics.isNotEmpty) {
            //         print(availableBiometrics);
            //       }

            //       if (availableBiometrics
            //               .contains(BiometricType.strong) ||
            //           availableBiometrics.contains(BiometricType.face)) {
            //         final bool didAuthenticate = await auth.authenticate(
            //             localizedReason:
            //                 'Please authenticate to show account balance',
            //             options: const AuthenticationOptions(
            //                 biometricOnly: true));
            //         if (didAuthenticate) {
            //           setState(() {
            //             isAuthenticated = true;
            //           });
            //         }
            //       }
            //     } catch (e) {
            //       print(e);
            //     }
            //   },
            // ),
            InkWell(
              onTap: () => context.pushNamed('teacher'),
              child: Card(
                child: Column(
                  children: [
                    Image.asset("assets/images/teacher.png"),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Teacher",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => context.pushNamed('student'),
              child: Card(
                child: Column(
                  children: [
                    Image.asset("assets/images/student.png"),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Student",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
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
        _result =
            "${_result}total: ${devices.length} Students attended. (updated in database)";
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
          Expanded(
            child: SingleChildScrollView(
              child: Text(_result),
            ),
          ),
        ],
      ),
    );
  }
}
