import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:wesh/components/ErrorDialog.dart';
import 'package:wesh/components/LoginDialog.dart';
import 'package:wesh/models/codePromo.dart';

class CodePromoHistory {
  CodePromo code;
  DateTime dateScan;

  CodePromoHistory({CodePromo code, DateTime dateScan}):
      code = code ?? CodePromo(name: 'Name', code: 'Code'),
      dateScan = dateScan ?? DateTime.now();

  factory CodePromoHistory.fromJson(Map<String, dynamic> json) {
    return CodePromoHistory(
      code: CodePromo.fromJson(json["code"]),
      dateScan: DateTime.parse(json["time"]),
    );
  }

  Color getColorByStatue(){
    if(code.startDate.isAfter(DateTime.now())){
      return Colors.blue;
    }else if(code.endDate.isAfter(DateTime.now())){
      return Colors.green;
    }else{
      return Colors.grey;
    }
  }

  static Future<List<CodePromoHistory>> getHistory(BuildContext context) async{

    List<CodePromoHistory> newListCodePromos = [];

    try{

      final http.Response response = await http.get("http://192.168.43.2:8008/api/history/", headers: {"Authorization" : LoginDialog.token})
          .timeout(new Duration(seconds: 5));

      switch(response.statusCode){
        case 200:
          List<Object> responseCodePromos = json.decode(response.body);
          for(int i=0; i<responseCodePromos.length; i++){
            CodePromoHistory newCodePromo = CodePromoHistory.fromJson(responseCodePromos[i]);
            newListCodePromos.add(newCodePromo);
          }
          break;
        case 401:
          ErrorDialog('Erreur API', 'Veuillez vous authentifier', context);
          break;
        default:
          ErrorDialog("Erreur API", "L'API n'est pas accessible", context);
          throw Exception('failed to connect to API');
          break;
      }

    }catch(exception){
      ErrorDialog('Erreur Réseau', "Impossible d'acceder au reseau", context);
    }

    return newListCodePromos;
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
                  Text(this.code.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4),
                  Text("Code: " + this.code.code, style: TextStyle(color: Colors.white70)),
                  Text(new DateFormat.yMMMd().format(this.code.startDate)
                      + " --> "
                      + new DateFormat.yMMMd().format(this.code.endDate),
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


}