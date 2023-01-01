import 'package:do_my_homework/custom_widgets/button_solid_with_icon.dart';
import 'package:do_my_homework/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'contra_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void googleSignIn(BuildContext context) async {
    print("sda");
    try {
      // await FirebaseAuth.instance.signOut();
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      await googleSignIn.signOut();
      final res = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await res?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      context.go("/home");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Login successfull with email ${res!.email}")));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
          Container(
            height: 410,
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), color: white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: const [
                    ContraText(
                      text: "Login",
                      alignment: Alignment.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Login with your college account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          color: trout,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonPlainWithIcon(
                      color: wood_smoke,
                      textColor: white,
                      iconPath: "assets/myicons/google.svg",
                      isPrefix: true,
                      isSuffix: false,
                      text: "Google",
                      callback: () async {
                        print(FirebaseAuth.instance.currentUser);

                        googleSignIn(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
