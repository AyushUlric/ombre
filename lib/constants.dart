import 'package:flutter/material.dart';

class Constants {
  static Color primaryColor = Colors.indigo;
  static Color secondaryColor = Colors.indigoAccent;
  static TextStyle logoStyle = TextStyle(
    fontSize: 24,
    color: primaryColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );
  static TextStyle heading1 = const TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
  static TextStyle heading2 = const TextStyle(
    fontSize: 14,
    color: Colors.white,
  );
}

Future<dynamic> showLoadingDialog(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        content: SizedBox(
          height: 50,
          child: Center(
            child: CircularProgressIndicator(
              color: Constants.primaryColor,
            ),
          ),
        ),
      ),
    ),
  );
}
