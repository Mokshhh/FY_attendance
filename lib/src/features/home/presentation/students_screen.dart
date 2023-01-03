import 'package:arp_scanner/arp_scanner.dart';
import 'package:arp_scanner/device.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  bool _sessionOn = false;
  String _hostname = "";
  bool _hostnameVerified = false;
  bool _isAuthenticated = false;
  bool _verifyingHost = false;
  List<Device> _devices = [];
  String _result = "";

  void authenticateUser() async {
    try {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      print(canAuthenticate);
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty) {
        print(availableBiometrics);
      }

      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.face)) {
        final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to mark attendance',
            options: const AuthenticationOptions(biometricOnly: true));
        if (didAuthenticate) {
          setState(() {
            _isAuthenticated = true;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _verifyHost() {
    setState(() {
      _verifyingHost = true;
    });
    ArpScanner.scan();
  }

  @override
  void initState() {
    super.initState();
    database.ref('/session').onValue.listen((event) {
      setState(() {
        _sessionOn = event.snapshot.value as bool;
      });
      if (_sessionOn == true && _hostnameVerified == true) {
        authenticateUser();
      }
    });

    database.ref('/hostname').onValue.listen((event) {
      setState(() {
        _hostname = event.snapshot.value as String;
      });
    });

    ArpScanner.onScanning.listen((Device device) {
      // if (device.hostname == _hostname) {
      //   _hostnameVerified = true;
      // }
      setState(() {
        _devices.add(device);
      });
    });
    ArpScanner.onScanFinished.listen((List<Device> devices) {
      setState(() {
        for (var element in devices) {
          if (element.hostname == _hostname) {
            _hostnameVerified = true;
            _verifyingHost = false;
          }
        }
        _devices = devices;
        _result =
            "${_result}total: ${devices.length} Students attended. (updated in database)";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _verifyingHost
              ? const CupertinoActivityIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !_hostnameVerified
                        ? OutlinedButton(
                            onPressed: _verifyHost,
                            child: const Text(
                              "Verify Host",
                              textAlign: TextAlign.center,
                              // style: TextStyle(fontSize: 16),
                            ),
                          )
                        : !_isAuthenticated
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Host name is verified. You can now mark attendance.",
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox.shrink(),
                    !_hostnameVerified && _isAuthenticated
                        ? const Text("Verify hostname first.")
                        : _sessionOn
                            ? _isAuthenticated
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset("assets/images/board.png"),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 38),
                                        child: Text("Attendance Marked"),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "Session has started, yet to mark attendance.")
                            : const Text(
                                "Wait for teacher to start attendance."),
                    if (_sessionOn && !_isAuthenticated && _hostnameVerified)
                      ElevatedButton(
                        onPressed: authenticateUser,
                        child: const Text("Mark Attendance"),
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
