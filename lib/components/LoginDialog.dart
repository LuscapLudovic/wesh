import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:wesh/components/ErrorDialog.dart';
import 'package:wesh/main.dart';

class LoginDialog extends State<MyHomePage>{

  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  static String token = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Authentification'),
      content: ListView(
        children: <Widget>[
          TextField(
            controller: _username,
            decoration: InputDecoration(hintText: 'Username'),
          ),
          TextField(
            obscureText: true,
            controller: _password,
            decoration: InputDecoration(hintText: 'Password'),
          ),
        ],
      ),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new FlatButton(
          child: new Text("Login"),
          onPressed: () {
            _loginApi(context).then((isConnected) => {
              if(isConnected) Navigator.pop(context, 'success')
            });
          },
        ),
      ],
    );
  }

  Future<String> loginDialogShow(BuildContext context) async {

    String value = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: build,
      );

    return value;

    }

    Future<bool> _loginApi(BuildContext context) async {
      try {
        http.Response response = await http.post(
            'http://192.168.43.2:8008/api/token-auth/',
            headers: {"Content-Type": "application/json"},
            body: json.encode(
                {'username': _username.text, 'password': _password.text})
        ).timeout(Duration(seconds: 5)).catchError((onError) => {
          debugPrint(onError.toString())
        });

        switch (response.statusCode) {
          case 200:
            token = "Token " + json.decode(response.body)['token'];
            break;
          case 400:
            ErrorDialog('Erreur Authentification',
                'Identifiant et/ou mot de passe erroné(s)', context);
            break;
          case 404:
            ErrorDialog('Erreur API', "Impossible d'acceder à l'API", context);
            break;
          default:
            ErrorDialog('Erreur Inconnue', "Une erreur inconnue c'est produite", context);
        }

        return (response.statusCode == 200);
      }
      catch(exception){
        ErrorDialog('Erreur Réseau', "Impossible d'acceder au reseau", context);
        return false;
      }
    }


}