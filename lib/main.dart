import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:wesh/components/ErrorDialog.dart';
import 'package:wesh/components/LoginDialog.dart';
import 'package:wesh/models/codePromo.dart';
import 'models/CodePromoHistory.dart';


final GlobalKey<RefreshIndicatorState> _refreshIndicatorListCodePromos = new GlobalKey<RefreshIndicatorState>();
final GlobalKey<RefreshIndicatorState> _refreshIndicatorLHistoryCodePromos = new GlobalKey<RefreshIndicatorState>();
final LoginDialog _loginDialog = new LoginDialog();
final _pageController = PageController();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wesh',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => loginAndRefresh());
  }

  Widget _widgetListCodePromos(BuildContext context){
    Widget child;

    if(codePromos.length > 0){
      child = ListView.builder(
          padding: EdgeInsets.only(bottom: 24.0),
          itemCount: codePromos.length,
          itemBuilder: (context, index){
            return codePromos[index].widgetCard();
          }
      );
    }else{
      List<CodePromo> listErrorCodePromo = [];
      listErrorCodePromo.add(CodePromo(name: 'Aucun code Promo'));
      
      child = ListView.builder(
          padding: EdgeInsets.only(bottom: 24.0),
          itemCount: listErrorCodePromo.length,
          itemBuilder: (context, index){
            return _errorCard(listErrorCodePromo[index].name);
          }
      );
    }

    return child;
  }

  Widget _widgetListCodePromosHistory(BuildContext context){
    Widget child;

    if(historyCodePromos.length > 0){
      child = ListView.builder(
          padding: EdgeInsets.only(bottom: 24.0),
          itemCount: historyCodePromos.length,
          itemBuilder: (context, index){
            return historyCodePromos[index].widgetCard();
          }
      );
    }else{

      List<CodePromoHistory> listErrorCodePromosHistory = [];
      listErrorCodePromosHistory.add(new CodePromoHistory(code: new CodePromo(name: 'Aucun code promo Scanner')));
      child = ListView.builder(
          padding: EdgeInsets.only(bottom: 24.0),
          itemCount: listErrorCodePromosHistory.length,
          itemBuilder: (context, index){
            return _errorCard(listErrorCodePromosHistory[index].code.name);
          }
      );
    }

    return child;
  }

  Widget _errorCard(String name){
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4),
                ],
              ),
            )
          ],
        ),
      ),
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
                      key: _refreshIndicatorListCodePromos,
                      onRefresh: _refreshListCodePromos,
                      child: _widgetListCodePromos(context),
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
                      child: _widgetListCodePromosHistory(context)
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

  Future _scanQR() async
  {

    try{
      String qrCode = await BarcodeScanner.scan();
      await CodePromo.getOneCodePromoAPI(qrCode, context).then((_codePromo) => {
        if(_codePromo is CodePromo){
          _refreshHistory()
        }
      });

    } on PlatformException catch(err) {
      if (err.code == BarcodeScanner.CameraAccessDenied){
        ErrorDialog('Erreur Scan QrCode', "Impossible d'accéder à la caméra", context);
      } else {
        ErrorDialog('Erreur Inconnue', "Erreur inconnue: $err", context);
      }
    } on FormatException {
      ErrorDialog('Erreur Scan QrCode', "Tu as presser le bouton 'back' trop tôt", context);
    } catch(err) {
      ErrorDialog('Erreur Inconnue', "Erreur inconnue: $err", context);
    }
    _pageController.jumpToPage(1);
  }


  Future<Null> _refreshListCodePromos() {
    return CodePromo.getAllCodePromosAPI(context).then((_codePromos) {
      setState(() {
        codePromos = _codePromos;
      });
    }).catchError((error) => {
      ErrorDialog('Erreur Actualisation', "une erreur c'est produite pendant l'actualisation de la liste", context),
      debugPrint(error.toString())
    });
  }

  Future<Null> _refreshHistory(){
    return CodePromoHistory.getHistory(context).then((_codePromos){
      setState(() {
        historyCodePromos = _codePromos;
      });
    }).catchError((error) => {
      ErrorDialog('Erreur Actualisation', "une erreur c'est produite pendant l'actualisation de la liste", context),
      debugPrint(error.toString())
    });
  }

  Future loginAndRefresh() async{
    String state = await _loginDialog.loginDialogShow(context);

    if(state == 'success'){
      _refreshListCodePromos();
      _refreshHistory();
    }

  }

}
