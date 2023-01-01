import 'package:firebase_database/firebase_database.dart';
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
  bool _isAuthenticated = false;

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

  @override
  void initState() {
    super.initState();
    database.ref('/session').onValue.listen((event) {
      setState(() {
        _sessionOn = event.snapshot.value as bool;
      });
      if (_sessionOn == true) {
        authenticateUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_sessionOn
                  ? _isAuthenticated
                      ? "Attendance Marked"
                      : "Session has started, yet to mark attendance."
                  : "Wait for teacher to start attendance"),
              if(_sessionOn && !_isAuthenticated) ElevatedButton(
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
