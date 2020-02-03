import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:wesh/components/ErrorDialog.dart';

class LoginDialog{
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  static String token = '';

  LoginDialog(BuildContext context){

      showDialog(
        context: context,
        barrierDismissible: false,
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
                  _loginApi(context).then((isConnected) => {
                    Navigator.of(context).pop()
                  });
                },
              ),
            ],
          );
        },
      );
    }


    Future<bool> _loginApi(BuildContext context) async {
      http.Response response = await http.post(
            'http://192.168.43.2:8008/api/token-auth/',
            headers: {"Content-Type": "application/json"},
            body: json.encode({'username': _username.text, 'password': _password.text})
        ).timeout(Duration(seconds: 5));

      if(response.statusCode != 200){
        ErrorDialog('Error Auth', 'Username or Password is wrong', context);
      }else{
        token = "Token " + json.decode(response.body)['token'];
      }

      debugPrint(token);

      return (response.statusCode == 200);
    }

}