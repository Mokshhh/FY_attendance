import 'package:do_my_homework/src/features/authentications/presentation/login_screen.dart';
import 'package:do_my_homework/src/features/home/presentation/home.dart';
import 'package:do_my_homework/src/features/home/presentation/students_screen.dart';
import 'package:do_my_homework/src/features/home/presentation/teacher_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    if (FirebaseAuth.instance.currentUser != null && state.location == "/") {
      return "/home";
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      // builder: (context, state) => const BluetoothBleTestScreen(),
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: "home",
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/teacher',
      name: "teacher",
      builder: (context, state) => const TeacherScreen(),
    ),
    GoRoute(
      path: '/student',
      name: "student",
      builder: (context, state) => const StudentScreen(),
    ),
  ],
);
