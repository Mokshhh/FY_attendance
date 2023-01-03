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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            !_sessionOn
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: TextButton(
                        onPressed: () {
                          database.ref("/session").set(true);
                        },
                        child: Column(
                          children: [
                            Image.asset("assets/images/start.png"),
                            const Text(
                              "Start Session",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                        children: [
                          const SizedBox(height: 12,),
                          const Text(
                            "Session Running, Students are notified to mark attendance.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          Image.asset("assets/images/running.gif"),
                          TextButton(
                            onPressed: () {
                              database.ref("/session").set(false);
                            },
                            child: const Text(
                              "Stop Session",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
