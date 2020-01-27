import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  String resultQR = '';

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
            Text(
              resultQR
            )
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
