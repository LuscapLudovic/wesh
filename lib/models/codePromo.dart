

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/material.dart';


import 'package:wesh/components/ErrorDialog.dart';
import 'package:wesh/components/LoginDialog.dart';

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
          LoginDialog();
          ErrorDialog('Erreur API', 'Veuillez vous authentifier', context);
          throw Exception('Error Auth');
          break;
        default:
          ErrorDialog("Erreur API", "L'API n'est pas accessible", context);
          throw Exception('failed to connect to API');
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
          .timeout(new Duration(seconds: 5))
          .catchError((error){
        ErrorDialog('Erreur API', "L'API n'est pas accessible", context);
      });

      switch(response.statusCode){
        case 200:
          newCodePromo = CodePromo.fromJson(json.decode(response.body));
          break;
        case 401:
          ErrorDialog('Erreur API', 'Veuillez vous authentifier', context);
          break;
        case 404:
          ErrorDialog("Erreur avec votre QRCode", "Ce code n'est pas disponible", context);
          throw Exception("code doesn't exist");
          break;
        default:
          ErrorDialog("Erreur avec votre QRCode", "Ce QrCode n'est pas correct", context);
          throw Exception('error QRCode');
          break;
      }
    }catch(exception){
      ErrorDialog('Erreur Réseau', "Impossible d'acceder au reseau", context);
    }

    return newCodePromo;
  }

  bool get isValide {
    DateTime now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

}