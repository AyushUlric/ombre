import 'package:flutter/material.dart';
import 'package:ombre/constants.dart';
import "package:ombre/services/auth.dart";

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "ombre",
                  style: TextStyle(
                    fontSize: 32,
                    color: Constants.primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  "a streaming app",
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.secondaryColor,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "Login to continue",
                  style: Constants.heading1,
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    showLoadingDialog(context);
                    await authService.signInWithGoogle();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 1, 0, 1),
                    width: double.infinity,
                    color: Constants.secondaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 32,
                          width: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage("assets/google_logo.png"),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Login with Google",
                          style: Constants.heading2,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
