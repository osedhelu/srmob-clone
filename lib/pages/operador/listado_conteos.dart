import 'package:araee/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'conteo.dart';

class ListadoConteosPage extends StatelessWidget{

  final Usuario usuario;  

  ListadoConteosPage({Key key, this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {        
    return Scaffold(
      appBar: AppBar(
        title: Text("Conteos"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("conteo")
          .where("gestor", isEqualTo: usuario.gestor.documentID)
          .orderBy("fechaHora", descending: true)
          .snapshots(),
        builder: (BuildContext cbContext, AsyncSnapshot<QuerySnapshot> cSnapshot) {          
          if( cSnapshot.hasData && cSnapshot.data != null ){            
            Map<String,num> conteos = new Map<String,num>();
            cSnapshot.data.documents.forEach(
              (DocumentSnapshot conteo){
                if(!conteos.containsKey( conteo['numeroManifiesto'] )){
                  conteos[ conteo['numeroManifiesto'] ] = 0;
                }
                conteos[ conteo['numeroManifiesto'] ] += conteo['cantidad'];
              }
            );
            
            return GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 600,
              childAspectRatio: 5,                          
              children: conteos.entries.map(
                (MapEntry<String,num> item) => Card(
                  child: ListTile(
                    title: Text(item.key),
                    trailing: Text("${item.value}", style: Theme.of(context).textTheme.headline),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConteoPage(usuario: usuario, numeroManifiesto: item.key,)
                        ),
                      );                      
                    },
                  ),
                )
              ).toList(),
            );
          }
          return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
        },  
      ),
    );
  }

}