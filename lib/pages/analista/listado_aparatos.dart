import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/listado_colores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListadoAparatosPage extends StatefulWidget{    

  final Usuario usuario;
  
  final DocumentSnapshot gestor;


  ListadoAparatosPage({Key key, this.usuario, this.gestor}) : super(key: key);    

  @override
  State<ListadoAparatosPage> createState() => new _ListadoAparatosPageState();
}

class _ListadoAparatosPageState extends State<ListadoAparatosPage>{

  Widget _buildAparato(BuildContext context, DocumentSnapshot aparato){
    return Card(
      elevation: 2.5,
      child: ListTile(        
        title: Text(aparato['nombre'], style: Theme.of(context).textTheme.headline,),            
        trailing: Icon(FontAwesomeIcons.plus, color: Theme.of(context).primaryColor,),
        onTap: () async {
          String message = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListadoColoresPage(
                  usuario: widget.usuario,
                  gestor: widget.gestor,
                  aparato: aparato,
                )
              ),
            );
          Navigator.of(context).pop(message);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: Text("Muestras"),
      ),      
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("aparato")/*.orderBy("frecuente", descending: true)*/.orderBy("nombre").snapshots(),
        builder: (BuildContext abContext, AsyncSnapshot<QuerySnapshot> aSnapshot) {
          if( aSnapshot.hasData && aSnapshot.data != null ){
            return GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 600,
              childAspectRatio: 5,
              children: aSnapshot.data.documents.map(
                (DocumentSnapshot aparato) => _buildAparato(abContext, aparato)
              ).toList(),
            );
          }
          return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
        },
      )
    );
  }

}