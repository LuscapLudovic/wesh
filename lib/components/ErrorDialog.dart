import 'package:flutter/material.dart';

class ErrorDialog{
  String title;
  String content;

  /**
   * @return Widget rendu d'un PopUp avec titre et message
   *
   * @param String title Titre de la PopUp
   * @param String content Message de la PopUp
   */
  ErrorDialog(String title, String content,BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
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