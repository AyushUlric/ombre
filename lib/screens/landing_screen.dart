import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:ombre/screens/home_screen.dart";
import "package:ombre/screens/login_screen.dart";
import 'package:ombre/constants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error: ${streamSnapshot.error}",
                style: Constants.heading1,
              ),
            ),
          );
        }
        if (streamSnapshot.connectionState == ConnectionState.active) {
          User? user = streamSnapshot.data;
          if (user == null) {
            return LoginScreen();
          } else {
            return const HomeScreen();
          }
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Constants.primaryColor,
            ),
          ),
        );
      },
    );
  }
}
