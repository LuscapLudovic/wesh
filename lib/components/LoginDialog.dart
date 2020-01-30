import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:wesh/components/ErrorDialog.dart';

class LoginDialog{
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  LoginDialog(BuildContext context){

      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text('Authentification'),
            content: ListView(
              children: <Widget>[
                TextField(
                  controller: _username,
                  decoration: InputDecoration(hintText: 'Username'),
                ),
                TextField(
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
                  if (_loginApi(context))
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    bool _loginApi(BuildContext context) {
      bool isConnected = false;
      http.post(
            'http://192.168.43.2:8008/api/token-auth/',
            headers: {"Content-Type": "application/json"},
            body: json.encode({'username': _username.toString(), 'password': _password.toString()})
        ).timeout(Duration(seconds: 5))
          .then((response) => { if(response.statusCode == 200) isConnected = true })
          .catchError((error) => {ErrorDialog('Error Auth', 'Username or Password is wrong', context)});

      return isConnected;
    }

}