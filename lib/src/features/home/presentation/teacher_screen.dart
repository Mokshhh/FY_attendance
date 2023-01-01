import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  bool _sessionOn = false;

  @override
  void initState() {
    super.initState();
    database.ref('/session').onValue.listen((event) {
      setState(() {
        _sessionOn = event.snapshot.value as bool;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            !_sessionOn
                ? TextButton(
                    onPressed: () {
                      database.ref("/session").set(true);
                    },
                    child: const Text("Start Session"),
                  )
                : TextButton(
                    onPressed: () {
                      database.ref("/session").set(false);
                    },
                    child: const Text("Stop Session"),
                  ),
          ],
        ),
      ),
    );
  }
}