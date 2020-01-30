import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;


import 'package:wesh/models/codePromo.dart';


final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

final _pageController = PageController();

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

class _MyHomePageState extends State<MyHomePage> {

  CodePromo resultQR;
  List<CodePromo> codePromos = [];
  List<CodePromo> historyCodePromos = [];
  String errorMessage = '';

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    _getAllCodePromosAPI().then((_codePromos) {
      setState(() {
        codePromos = _codePromos;
      });
      debugPrint("Async done");
    });
  }

  Future<List<CodePromo>> _getAllCodePromosAPI() async
  {
    final response = await http.get("http://192.168.43.2:8008/api/codepromo/")
        .timeout(new Duration(seconds: 5))
        .catchError((error){
      _showDialog('Error API', 'Fail to connect to the API');
    });

    List<Object> responseCodePromos = json.decode(response.body);
    List<CodePromo> newListCodePromos = [];

    if(response.statusCode == 200){
      for(int i=0; i<responseCodePromos.length; i++){
        CodePromo newCodePromo = CodePromo.fromJson(responseCodePromos[i]);
        newListCodePromos.add(newCodePromo);
      }
    }else{
      throw Exception('failed to load post');
    }
    return newListCodePromos;
  }

  Future<CodePromo> _getOneCodePromoAPI(String codePromo) async
  {
    final response = await http.get("http://192.168.43.2:8008/api/codepromo/" + codePromo)
        .timeout(new Duration(seconds: 5))
        .catchError((error){
      _showDialog('Error API', 'Fail to connect to the API');
    });

    CodePromo newCodePromo;

    if(response.statusCode == 200){
      newCodePromo = CodePromo.fromJson(json.decode(response.body));
    }else if(response.statusCode == 404){
      _showDialog('Code not found', 'this code is not available');
      throw Exception("this code doesn't exist");
    }
    else{
      _showDialog("Error with your qrCode", "Your QrCode is no correct");
      throw Exception('failed to load post');
    }
    return newCodePromo;
  }

  Future _scanQR() async
  {

    try{
      String qrCode = await BarcodeScanner.scan();
      CodePromo codePromo = await _getOneCodePromoAPI(qrCode);

      for(int i=0; i < historyCodePromos.length; i++){
        if(historyCodePromos[i].code == codePromo.code){
          historyCodePromos.remove(historyCodePromos[i]);
        }
      }
      setState(() {
        historyCodePromos.add(codePromo);
      });
    } on PlatformException catch(err) {
      if (err.code == BarcodeScanner.CameraAccessDenied){
        setState(() {
          errorMessage = "Camera permission denied";
        });
      } else {
        setState(() {
          errorMessage = "Unknown error $err";
        });
      }
    } on FormatException {
      setState(() {
        errorMessage = "You pressed the back button before scanning anything";
      });
    } catch(err) {
      setState(() {
        errorMessage = "Unknown error $err";
      });
    }
    _pageController.jumpToPage(1);
  }

  Future<Null> _refresh() {
    return _getAllCodePromosAPI().then((_codePromos) {
      setState(() {
        codePromos = _codePromos;
      });
    });
  }

  void _showDialog(String title, String content) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child:Center(
              child : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        itemCount: codePromos.length,
                        itemBuilder: (context, index){
                          return Card(
                            child: Text(codePromos[index].code, style: TextStyle(color: Colors.white)),
                            color: Colors.green,
                          );
                        }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: ListView.builder(
                      itemCount: historyCodePromos.length,
                      itemBuilder: (context, index){
                        return Card(
                          child: Text(historyCodePromos[index].code, style: TextStyle(color: Colors.white)),
                          color: Colors.green,
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(onPressed: (){_pageController.jumpToPage(0);}, icon: Icon(Icons.home)),
            IconButton(onPressed: (){_pageController.jumpToPage(1);}, icon: Icon(Icons.history),),
          ],
        ),
    ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt), onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
