

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:wesh/components/ErrorDialog.dart';
import 'package:wesh/components/LoginDialog.dart';

final LoginDialog _loginDialog = LoginDialog();

class CodePromo {
  String name;
  String code;
  DateTime startDate;
  DateTime endDate;

  CodePromo({this.name = 'NoName', this.code = 'NONAME', DateTime startDate, DateTime endDate}):
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now();

  factory CodePromo.fromJson(Map<String, dynamic> json) {
    return CodePromo(
      name: utf8.decode(json['name'].toString().codeUnits),
      code: utf8.decode(json['code'].toString().codeUnits),
      startDate: DateTime.parse(json["create_time"]),
      endDate: DateTime.parse(json["end_time"]),
    );
  }

  Color getColorByStatue(){
    if(startDate.isAfter(DateTime.now())){
      return Colors.blue;
    }else if(endDate.isAfter(DateTime.now())){
      return Colors.green;
    }else{
      return Colors.grey;
    }
  }


  static Future<List<CodePromo>> getAllCodePromosAPI(BuildContext context) async
  {
    List<CodePromo> newListCodePromos = [];
    try{
      final http.Response response = await http.get("http://192.168.43.2:8008/api/codepromo/?time=" + DateTime.now().toIso8601String(), headers: {"Authorization" : LoginDialog.token})
          .timeout(new Duration(seconds: 5));

      switch(response.statusCode){
        case 200:
          List<Object> responseCodePromos = json.decode(response.body);
          for(int i=0; i<responseCodePromos.length; i++){
            CodePromo newCodePromo = CodePromo.fromJson(responseCodePromos[i]);
            newListCodePromos.add(newCodePromo);
          }
          break;
        case 401:
          _loginDialog.loginDialogShow(context);
          ErrorDialog('Erreur API', 'Veuillez vous authentifier', context);
          break;
        default:
          ErrorDialog("Erreur API", "L'API n'est pas accessible", context);
          break;

      }
    }catch(exception){
      ErrorDialog("Erreur Réseau", "Impossible de se connecter au réseau", context);
    }
    return newListCodePromos;
  }


  static Future<CodePromo> getOneCodePromoAPI(String codePromo, BuildContext context) async
  {

    CodePromo newCodePromo;

    try{
      final http.Response response = await http.get("http://192.168.43.2:8008/api/codepromo/" + codePromo + "/", headers: {"Authorization" : LoginDialog.token})
          .timeout(new Duration(seconds: 5));

      switch(response.statusCode){
        case 200:
          newCodePromo = CodePromo.fromJson(json.decode(response.body));
          break;
        case 401:
          _loginDialog.loginDialogShow(context);
          ErrorDialog('Erreur API', 'Veuillez vous authentifier', context);
          break;
        case 404:
          ErrorDialog("Erreur avec votre QRCode", "Ce code n'est pas disponible", context);
          break;
        default:
          ErrorDialog("Erreur avec votre QRCode", "Ce QrCode n'est pas correct", context);
          break;
      }
    }catch(exception){
      ErrorDialog('Erreur Réseau', "Impossible d'acceder au reseau", context);
    }

    return newCodePromo;
  }

  Widget widgetCard(){
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      color: this.getColorByStatue(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(this.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4),
                  Text("Code: " + this.code, style: TextStyle(color: Colors.white70)),
                  Text(new DateFormat.yMMMd().format(this.startDate)
                      + " --> "
                      + new DateFormat.yMMMd().format(this.endDate),
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool get isValide {
    DateTime now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

}