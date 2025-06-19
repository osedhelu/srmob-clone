import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/listado_muestras.dart';
import 'package:araee/pages/analista/menu_analista.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:araee/widget/WaitingWidget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ListadoGestoresPage extends StatefulWidget{    

    ListadoGestoresPage({Key key}) : super(key: key);

    @override
    State<ListadoGestoresPage> createState() => new _ListadoGestoresPageState();
}

class _ListadoGestoresPageState extends State<ListadoGestoresPage>{

  Widget _buildGestor(BuildContext context, Usuario usuario, DocumentSnapshot gestor){
    return Card(
      elevation: 3.0,      
      margin: EdgeInsets.all(6.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        title: Hero(
          tag: '${gestor.documentID}Hero',
          child: AutoSizeText(
            gestor['razonSocial'], 
            softWrap: true,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headline,
          )
        ),
        isThreeLine: false,
        subtitle: Text(gestor['sede']),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListadoMuestrasPage(
                usuario: usuario,
                gestor: gestor,                      
              )
            ),
          );
        },
      )            
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
            appBar: AppBar(
              title: Text("Seleccione un gestor"),
            ),
            drawer: MenuAnalistaPage(usuario:uSnapshot.data),
            body: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("gestor").snapshots(),
              builder: (BuildContext gbContext, AsyncSnapshot<QuerySnapshot> gSnapshot) {
                if( gSnapshot.hasData && gSnapshot.data != null ){
                  return GridView.extent(
                    shrinkWrap: true,
                    maxCrossAxisExtent: 600,
                    childAspectRatio: 4,
                    children: gSnapshot.data.documents.map(
                      (DocumentSnapshot documentSnapshot) => _buildGestor(gbContext, uSnapshot.data, documentSnapshot)
                    ).toList(),
                  );
                }
                return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
              },
            )       
          );
        }
        return WaitingWidget(message: "Cargando información de analista");
      }
    );

  }

}