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

/** Lance l'application **/
void main() => runApp(MyApp());

/**
 * Coeur de l'application
 */
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

/**
 * Classe gerant la page du site
 */
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/**
 * State de la classe MyHomePage (gère le comportement et le rendu)
 */
class _MyHomePageState extends State<MyHomePage> {

  CodePromo resultQR;
  List<CodePromo> codePromos = [];
  List<CodePromoHistory> historyCodePromos = [];
  String errorMessage = '';

  @override
  void initState(){
    ///Excecution de la fonction parent
    super.initState();
    ///Appel de la fonction loginAndRefresh après le rendu de la page
    WidgetsBinding.instance.addPostFrameCallback((_) => loginAndRefresh());
  }

  /**
   * @return Widget composant affichant la liste des codes promos ou d'un message d'erreur
   */
  Widget _widgetListCodePromos(BuildContext context){
    Widget child;

    /// Si la liste des codes promos possède au moins un élément
    if(codePromos.length > 0){
      /// On récupère la liste de toutes les Card comportant les infos des codes promos
      child = ListView.builder(
          padding: EdgeInsets.only(bottom: 24.0),
          itemCount: codePromos.length,
          itemBuilder: (context, index){
            return codePromos[index].widgetCard();
          }
      );
      /// Sinon on récupère une liste comportant un message d'erreur
    }else{
      /// Le message d'erreur est stocké dans une liste afin que le
      /// RefreshIndicatorState puisse fonctionné correctement
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

    /// On retourne le Widget récupéré
    return child;
  }

  /**
   * @return Widget composant affichant la liste des codes promos scannés ou d'un message d'erreur
   */
  Widget _widgetListCodePromosHistory(BuildContext context){
    Widget child;
    /// Si la liste des codes promos scannés possède au moins un élément
    if(historyCodePromos.length > 0){
      /// On récupère la liste de toutes les Card comportant les infos des codes promos
      child = ListView.builder(
          padding: EdgeInsets.only(bottom: 24.0),
          itemCount: historyCodePromos.length,
          itemBuilder: (context, index){
            return historyCodePromos[index].widgetCard();
          }
      );
      /// Sinon on récupère une liste comportant un message d'erreur
    }else{
      /// Le message d'erreur est stocké dans une liste afin que le
      /// RefreshIndicatorState puisse fonctionné correctement
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
    /// On retourne le Widget récupéré
    return child;
  }

  /**
   * @return Widget Card affichant un message
   */
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

  /**
   * Architecture d'affichage principale de la page
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          ///Page d'affichage des codes promos
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
          ///Page d'affichage des code promos scannés
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
      ///Barre possédant les boutons pour naviguer dans les pages
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
      /// Bouton lançant le scan du QRCode
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt), onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /**
   * Fonction qui scanne, actualise la liste des codes promos scannés
   * et redirige vers la pages des codes scannés
   */
  Future _scanQR() async
  {

    try{
      /// On attend le retour de la librairie BarcodeScanner
      String qrCode = await BarcodeScanner.scan();
      /// On attend le retour de l'API avec le code scanné
      await CodePromo.getOneCodePromoAPI(qrCode, context).then((_codePromo) => {
        ///Si le code existe on rafraichie la liste des codes promos scannés
        if(_codePromo is CodePromo){
          _refreshHistory()
        }
      });

      ///Gestion des cas d'erreurs
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

    /// On redirige l'utilisateur vers la page des codes promos scannés
    _pageController.jumpToPage(1);
  }


  /**
   * Rafraichie la liste des codes promos
   */
  Future<Null> _refreshListCodePromos() {
    /// On attend la liste des codes promos retournée par l'API
    return CodePromo.getAllCodePromosAPI(context).then((_codePromos) {
      /// On affecte la liste retournée à notre liste
      setState(() {
        codePromos = _codePromos;
      });
      /// Cas d'erreur
    }).catchError((error) => {
      ErrorDialog('Erreur Actualisation', "une erreur c'est produite pendant l'actualisation de la liste", context),
    });
  }

  /**
   * Rafraichie la liste des codes promos scannés
   */
  Future<Null> _refreshHistory(){
    /// On attend la liste des codes promos scannés retournée par l'API
    return CodePromoHistory.getHistory(context).then((_codePromos){
      /// On affecte la liste retournée à notre liste
      setState(() {
        historyCodePromos = _codePromos;
      });
      /// Cas d'erreur
    }).catchError((error) => {
      ErrorDialog('Erreur Actualisation', "une erreur c'est produite pendant l'actualisation de la liste", context),
    });
  }

  /**
   * Fonction qui affiche la page de login et actualise les listes de code promos
   */
   Future loginAndRefresh() async{
    String state = await _loginDialog.loginDialogShow(context);

    /// si la personne se connecte correctement
    if(state == 'success'){
      _refreshListCodePromos();
      _refreshHistory();
    }

  }

}
