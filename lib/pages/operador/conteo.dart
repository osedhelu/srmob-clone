
import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/operador/consultar_conteo_aparatos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ConteoPage extends StatelessWidget{

  final Usuario usuario;

  final String numeroManifiesto;

  final bool mostrarControles;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  ConteoPage({Key key, this.usuario, this.numeroManifiesto, this.mostrarControles=false}) : super(key: key);

  Future<void> _showConfirmDialog(BuildContext context, DocumentSnapshot conteo) async{
    return showDialog<void>(
      context: context,
      builder: (BuildContext dContext){
        return AlertDialog(
          title: Text("Confirmar", style: Theme.of(context).textTheme.headline,),
          content: Text(
            '¿Esta seguro de querer eliminar este conteo?',
            style: Theme.of(context).textTheme.display1,
            softWrap: true,
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text("Confirmar", style: Theme.of(context).textTheme.button,),
              onPressed: () async{                                
                Navigator.of(dContext).pop();
                conteo.reference.delete();          
              },
            ),            
            RaisedButton(
              child: Text("Volver", style: Theme.of(context).textTheme.button,),
              onPressed: (){
                Navigator.of(dContext).pop();                
              },
            ),                        
          ],

        );
      }
    );
  }

  Widget _buildItem(BuildContext context, DocumentSnapshot conteo){
    Timestamp fsT = conteo.data['fechaHora'];        
    String fechaHora = DateFormat("yyyy/MM/dd HH:mm:ss").format( fsT.toDate() );
    return FutureBuilder<DocumentSnapshot>(
      future: Firestore.instance.collection("aparato").document(conteo.data['aparato']).get(),
      builder: (BuildContext cbContext, AsyncSnapshot<DocumentSnapshot> cSnapshot) {
        if( cSnapshot.hasData && cSnapshot.data != null ){
          return ListTile(
            title: Text("${cSnapshot.data['nombre']} - ${conteo['color']}"),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: <Widget>[          
                FutureBuilder<DocumentSnapshot>(
                  future: Firestore.instance.collection("usuario").document(conteo.data['usuario']).get(),
                  builder: (BuildContext cbContext, AsyncSnapshot<DocumentSnapshot> cSnapshot) {
                    if( cSnapshot.hasData && cSnapshot.data != null ){
                      if( cSnapshot.data.exists ){
                        return Text("${cSnapshot.data['email']??''}");
                      }
                      else{
                        return Text("Usuario eliminado", style: Theme.of(context).textTheme.body1.copyWith(color:Colors.grey),);
                      }
                    }
                    return Text(conteo.data['usuario']);
                  }
                ),           
                Text(
                  "Fecha y hora: $fechaHora",
                  style: Theme.of(context).textTheme.caption, 
                ),
              ],
            ),
            trailing: Text("${conteo.data['cantidad']}", style: Theme.of(context).textTheme.headline,),
            onTap: () async{
              await Navigator.push(
                  cbContext,
                  MaterialPageRoute(
                    builder: (cbContext) => ConsultarConteoAparatosPage(
                      usuario: this.usuario,
                      aparato: cSnapshot.data,
                      conteo: conteo
                    )
                  ),
              );
              
            },
            onLongPress: () {
              _showConfirmDialog(cbContext, conteo);              
            },
          );
        }
        else{
          return ListTile(
            title: Text("... - ..."),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: <Widget>[          
                Text("..."),           
                Text(
                  "Fecha y hora: $fechaHora",
                  style: Theme.of(context).textTheme.caption, 
                ),
              ],
            ),
            trailing: Text("${conteo.data['cantidad']}", style: Theme.of(context).textTheme.headline,),
          );
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("$numeroManifiesto"),
        actions: <Widget>[
          this.mostrarControles
          ? IconButton(
                icon: Icon(FontAwesomeIcons.save), 
                onPressed: (){
                  Navigator.of(context).pop(true);
                }
            )
          : Container()
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("conteo")
          .where("gestor", isEqualTo: usuario.gestor.documentID)
          .where("numeroManifiesto", isEqualTo: numeroManifiesto)
          .orderBy("fechaHora", descending: true)
          .snapshots(),
        builder: (BuildContext cbContext, AsyncSnapshot<QuerySnapshot> cSnapshot) {
          if( cSnapshot.hasData && cSnapshot.data != null ){            
            return GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 600,
              childAspectRatio: 5,
              children: cSnapshot.data.documents.map(
                (DocumentSnapshot conteo) => _buildItem(cbContext, conteo)
              ).toList(),
            );
          }
          return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
        },  
      ),
    );
  }

}