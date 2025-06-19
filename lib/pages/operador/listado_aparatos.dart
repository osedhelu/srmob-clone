import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/operador/listado_colores.dart';
import 'package:araee/pages/operador/menu_operador.dart';
import 'package:araee/pages/operador/nueva_categoria.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:araee/widget/WaitingWidget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'conteo.dart';

class ListadoAparatosPage extends StatefulWidget{    

    ListadoAparatosPage({Key key}) : super(key: key);

    @override
    State<ListadoAparatosPage> createState() => new _ListadoAparatosPageState();
}

class _ListadoAparatosPageState extends State<ListadoAparatosPage>{

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _numeroSeguimiento;

  final _formKey = GlobalKey<FormState>();

  void showTrackIdDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext dContext){
        return AlertDialog(
          title: Text("Manifiesto de recolección"),
          content: SafeArea(
            child: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  hintText: "###############",                  
                ),                
                validator: (value){
                  if( value.isEmpty ){
                    return "Ingrese el número del manifiesto de recolección";
                  }
                  return null;
                },
                onSaved: (value){
                  this._numeroSeguimiento = value;
                },
                textAlign: TextAlign.right,
                maxLength: 100,
              ),
            ),            
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text("Cancelar", style: Theme.of(context).textTheme.button,),
              onPressed: (){
                Navigator.of(dContext).pop();
              },
            ),
            RaisedButton(
              child: Text("Guardar", style: Theme.of(context).textTheme.button,),
              color: Theme.of(dContext).primaryColor,
              onPressed: (){
                if(_formKey.currentState.validate()){
                  _formKey.currentState.save();
                  setState(() {

                  });
                  Navigator.of(dContext).pop();
                }
              },
            )
          ],
        );
      }
    );
  }

  Widget _buildAparato(BuildContext context, Usuario usuario, DocumentSnapshot aparato){
    return Padding(
          padding: EdgeInsets.all(3.0),
          child: RawMaterialButton(
            elevation: 2.0,      
            fillColor: Theme.of(context).accentColor,
            splashColor: Theme.of(context).backgroundColor,
            child: Hero( 
              tag: '${aparato.documentID}Hero',
              child: AutoSizeText( 
                aparato['nombre'],
                maxLines: 1,
                style: Theme.of(context).textTheme.display1, 
              )
            ),     
            onPressed: () async {
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListadoColoresPage(
                    usuario: usuario,
                    gestor: usuario.gestor,
                    aparato: aparato,
                    numeroSeguimiento: _numeroSeguimiento,
                  )
                ),
              );
              if( message != null ){
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(message, style: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).primaryColor),),
                      duration: Duration(seconds: 3),
                    )
                  );
              }
            },
          ),
        );
  }

  Widget _buildOtro(BuildContext context, Usuario usuario){
    return Padding(
          padding: EdgeInsets.all(3.0),
          child: RawMaterialButton(
            elevation: 2.0,      
            fillColor: Theme.of(context).primaryColor,
            splashColor: Theme.of(context).accentColor,
            child: Hero( 
              tag: 'otroHero',
              child: AutoSizeText( 
                "OTRO",
                maxLines: 1,
                style: Theme.of(context).textTheme.display1.copyWith(color:Colors.white), 
              )
            ),     
            onPressed: () async {
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuevoAparatoPage(
                    usuario: usuario,
                    gestor: usuario.gestor,                    
                  )
                ),
              );
              if( message != null ){
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(message, style: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).primaryColor),),
                      duration: Duration(seconds: 3),
                    )
                  );
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final SecurityBloc securityBloc = AppBlocProvider.securityBlocOf(context);
    return FutureBuilder<Usuario>(
      future: securityBloc.getUser(), 
      builder: (BuildContext sContext, AsyncSnapshot<Usuario> uSnapshot) {
        if( uSnapshot.hasData && uSnapshot.data != null ){
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("${_numeroSeguimiento ?? 'Conteo'}"),
            ),
            drawer: MenuOperadorPage(usuario:uSnapshot.data),
            body: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("aparato").orderBy("nombre").snapshots(),
              builder: (BuildContext abContext, AsyncSnapshot<QuerySnapshot> aSnapshot) {                
                if( aSnapshot.hasData && aSnapshot.data != null ){
                  List<Widget> aees = aSnapshot.data.documents.map(
                      (DocumentSnapshot aparato) => _buildAparato(abContext, uSnapshot.data, aparato)
                    ).toList();
                  aees.add(_buildOtro(abContext, uSnapshot.data));
                  return GridView.extent(
                    shrinkWrap: true,
                    maxCrossAxisExtent: 600,
                    childAspectRatio: 5,                          
                    children: aees,
                  );
                }
                return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              child: Icon(FontAwesomeIcons.truck),        
              onPressed: () async{
                if( this._numeroSeguimiento == null ){
                  this.showTrackIdDialog(context);
                }
                else{
                  bool guardar = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConteoPage(usuario: uSnapshot.data, numeroManifiesto: this._numeroSeguimiento, mostrarControles: true,)
                    ),
                  );
                  if( guardar != null && guardar ){
                    setState(() {
                      this._numeroSeguimiento = null;
                    });            
                  }                  
                }
              },
            )
          );
        }
        return WaitingWidget(message: "Cargando información de operador");
      }
    );
  }

}