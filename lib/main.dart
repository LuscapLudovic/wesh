import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wesh',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'The Wesh Scanning Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CodePromo {

  String name = '';
  String code = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  CodePromo({this.name, this.code, this.startDate, this.endDate});

  factory CodePromo.fromJson(Map<String, dynamic> json) {
    return CodePromo(
      name: json["name"],
      code: json["code"],
      startDate: DateTime.parse(json["create_time"]),
      endDate: DateTime.parse(json["end_time"]),
    );
  }

}

class _MyHomePageState extends State<MyHomePage> {

  String resultQR = '';
  List<CodePromo> codePromos = [];

  @override
  void initState(){
    super.initState();
    debugPrint('yes');
    getCodePromosAPI().then((value) {
      debugPrint("Async done");
    });
  }

  Future<void> getCodePromosAPI() async
  {
    final response = await http.get("http://192.168.43.2:8008/api/codepromo/");

    debugPrint(codePromos.toString());

    List<Object> responseCodePromos = json.decode(response.body);

    if(response.statusCode == 200){
      for(int i=0;i<responseCodePromos.length; i++)
      setState(() {
        codePromos.add(CodePromo.fromJson(responseCodePromos[i]));
      });
    }else{
      throw Exception('failed to load post');
    }
  }

  Future _scanQR() async
  {

    try{
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        resultQR = qrResult;
      });


    }on PlatformException catch(err){
      if(err.code == BarcodeScanner.CameraAccessDenied){
        setState(() {
          resultQR = "Camera permission denied";
        });
      }else{
        setState(() {
          resultQR = "Unknown error $err";
        });
      }
    } on  FormatException{
      setState(() {
        resultQR = "You pressed the back button before scanning anything";
      });
    } catch(err){
      setState(() {
        resultQR = "Unknown error $err";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                      itemCount: codePromos.length,
                      itemBuilder: (context, index){
                        return Card(
                          child: Text(codePromos[index].code, style: TextStyle(color: Colors.red, fontSize: 30)),
                          color: Colors.black,
                        );
                      }
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQR,
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
