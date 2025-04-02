import 'package:class_interaction_wear_os/Websocket/Websocket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dialogs {
  static Future<dynamic> showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
