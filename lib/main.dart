import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


import 'package:wesh/components/ErrorDialog.dart';
import 'package:wesh/components/LoginDialog.dart';
import 'package:wesh/models/CodePromoHistory.dart';
import 'package:wesh/models/codePromo.dart';


final GlobalKey<RefreshIndicatorState> _refreshIndicatorListCodePromos = new GlobalKey<RefreshIndicatorState>();
final GlobalKey<RefreshIndicatorState> _refreshIndicatorLHistoryCodePromos = new GlobalKey<RefreshIndicatorState>();

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
  List<CodePromoHistory> historyCodePromos = [];
  String errorMessage = '';

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => LoginDialog(context));
  }

  Future<List<CodePromo>> _getAllCodePromosAPI() async
  {
    final response = await http.get("http://192.168.43.2:8008/api/codepromo/?time=" + DateTime.now().toIso8601String(), headers: {"Authorization" : LoginDialog.token})
        .timeout(new Duration(seconds: 5))
        .catchError((error){
      ErrorDialog('Error API', 'Fail to connect to the API', context);
    });

    List<CodePromo> newListCodePromos = [];

    switch(response.statusCode){
      case 200:
        List<Object> responseCodePromos = json.decode(response.body);
        for(int i=0; i<responseCodePromos.length; i++){
          CodePromo newCodePromo = CodePromo.fromJson(responseCodePromos[i]);
          newListCodePromos.add(newCodePromo);
        }
        break;
      case 401:
        LoginDialog(context);
        ErrorDialog('Error API', 'Your are not authentified', context);
        break;
      case 404:
        ErrorDialog('Code not found', 'this code is not available', context);
        throw Exception("this code doesn't exist");
        break;
      default:
        ErrorDialog("Error with your qrCode", "Your QrCode is no correct", context);
        throw Exception('failed to load post');
        break;
    }
    return newListCodePromos;
  }

  Future<CodePromo> _getOneCodePromoAPI(String codePromo) async
  {
    final response = await http.get("http://192.168.43.2:8008/api/codepromo/" + codePromo + "/", headers: {"Authorization" : LoginDialog.token})
        .timeout(new Duration(seconds: 5))
        .catchError((error){
      ErrorDialog('Error API', 'Fail to connect to the API', context);
    });

    CodePromo newCodePromo;

    switch(response.statusCode){
      case 200:
        newCodePromo = CodePromo.fromJson(json.decode(response.body));
        break;
      case 401:
        LoginDialog(context);
        ErrorDialog('Error API', 'Your are not authentified', context);
        break;
      case 404:
        ErrorDialog('Code not found', 'this code is not available', context);
        throw Exception("this code doesn't exist");
        break;
      default:
        ErrorDialog("Error with your qrCode", "Your QrCode is no correct", context);
        throw Exception('failed to load post');
        break;
    }

    return newCodePromo;
  }

  Future<List<CodePromoHistory>> _getHistory() async{
    final response = await http.get("http://192.168.43.2:8008/api/history/", headers: {"Authorization" : LoginDialog.token})
        .timeout(new Duration(seconds: 5))
        .catchError((error){
      ErrorDialog('Error API', 'Fail to connect to the API', context);
    });

    List<CodePromoHistory> newListCodePromos = [];

    switch(response.statusCode){
      case 200:
        List<Object> responseCodePromos = json.decode(response.body);
        for(int i=0; i<responseCodePromos.length; i++){
          CodePromoHistory newCodePromo = CodePromoHistory.fromJson(responseCodePromos[i]);
          newListCodePromos.add(newCodePromo);
        }
        break;
      case 401:
        LoginDialog(context);
        ErrorDialog('Error API', 'Your are not authentified', context);
        break;
      case 404:
        ErrorDialog('History not found', 'Error request History', context);
        throw Exception("your history doesn't exist");
        break;
      default:
        ErrorDialog("Error with your qrCode", "Your QrCode is no correct", context);
        throw Exception('failed to load post');
        break;
    }
    return newListCodePromos;
  }

  Future _scanQR() async
  {

    try{
      String qrCode = await BarcodeScanner.scan();
      await _getOneCodePromoAPI(qrCode);
      _refreshHistory();

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

  Future<Null> _refreshListCodePromos() {
    return _getAllCodePromosAPI().then((_codePromos) {
      setState(() {
        codePromos = _codePromos;
      });
    });
  }

  Future<Null> _refreshHistory(){
    return _getHistory().then((_codePromos){
      setState(() {
        historyCodePromos = _codePromos;
      });
    });
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
                      key: _refreshIndicatorListCodePromos,
                      onRefresh: _refreshListCodePromos,
                      child: ListView.builder(
                        itemCount: codePromos.length,
                        itemBuilder: (context, index){
                          return Card(
                            margin: EdgeInsets.all(12),
                            elevation: 4,
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                              child: Row(
                                children: <Widget>[
                                  Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(codePromos[index].name,
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          maxLines: 1,
                                      ),
                                      SizedBox(height: 4),
                                      Text("Code: " + codePromos[index].code, style: TextStyle(color: Colors.white70)),
                                      Text(new DateFormat.yMMMd().format(codePromos[index].startDate)
                                          + " --> "
                                          + new DateFormat.yMMMd().format(codePromos[index].endDate),
                                          style: TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                    child: RefreshIndicator(
                      key: _refreshIndicatorLHistoryCodePromos,
                      onRefresh: _refreshHistory,
                      child: ListView.builder(
                          itemCount: historyCodePromos.length,
                          itemBuilder: (context, index){
                            return Card(
                              margin: EdgeInsets.all(12),
                              elevation: 4,
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(historyCodePromos[index].code.name,
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                            overflow: TextOverflow.clip,
                                            softWrap: false,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 4),
                                          Text("Code: " + historyCodePromos[index].code.code, style: TextStyle(color: Colors.white70)),
                                          Text(new DateFormat.yMMMd().format(historyCodePromos[index].code.startDate)
                                              + " --> "
                                              + new DateFormat.yMMMd().format(historyCodePromos[index].code.endDate),
                                              style: TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
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
