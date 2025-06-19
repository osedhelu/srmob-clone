import 'package:araee/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'editar_muestra_operador.dart';


class ListadoMuestrasPage extends StatefulWidget{

  final Usuario usuario;
  final DocumentSnapshot gestor;
  final DocumentSnapshot aparato;
  final String color;
  final String numeroSeguimiento;
  final String conteo;

  ListadoMuestrasPage({Key key, this.usuario, this.gestor, this.aparato, this.color, this.numeroSeguimiento, this.conteo}) : super(key: key);

    @override
    State<ListadoMuestrasPage> createState() => new _ListadoMuestrasState();
}

class _ListadoMuestrasState extends State<ListadoMuestrasPage>{

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<DocumentSnapshot> muestras = List<DocumentSnapshot>();  

  @override
  void initState() {  
    CollectionReference analisis = Firestore.instance.collection("analisis");
    Query query = analisis.where("conteo", isEqualTo: this.widget.conteo).orderBy("fechaHora", descending: true);
    
      
    query.snapshots().listen(
      (querySnapshot){
        querySnapshot.documentChanges.forEach(
          (change){
            print('cambio... ${change.document.data}');
          }
        );
        setState(() {
          this.muestras = querySnapshot.documents;
        });
      }
    );
    super.initState();
  }  

  Color _getColor( String grupo ){
    switch( grupo ){
      case 'LIBRE':{
        return Colors.green;
      }break;
      case 'SOSPECHOSO':{
        return Colors.blue;
      }break;
      case 'CONTAMINADO':{
        return Colors.red;
      }break;
      default:{
        return Colors.white;
      }break;
    }
  }

  Widget _buildMuestra(BuildContext context, DocumentSnapshot muestra){
    Timestamp fsT = muestra['fechaHora'];        
    String fechaHora = DateFormat("yyyy/MM/dd HH:mm:ss").format( fsT.toDate() );
    return Card(
      elevation: 2,      
      child: FutureBuilder(
        future: Firestore.instance.collection("aparato").document(muestra['aparato']).get(),
        builder: (BuildContext aContext, AsyncSnapshot<DocumentSnapshot> aSnapshot){
          return ListTile(
            title: Text(
              '${muestra['id']??'...'}',
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 24),
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: <Widget>[
                Text( 
                  aSnapshot.hasData && aSnapshot.data != null ? "${aSnapshot.data['nombre']}" : "...",
                  style: Theme.of(context).textTheme.subtitle, 
                ),
                Text(
                  "Fecha y hora: $fechaHora",
                  style: Theme.of(context).textTheme.caption, 
                ),
              ],
            ),
            trailing: 
              Icon( 
                muestra["estado"] == 0
                ? FontAwesomeIcons.clipboard
                : FontAwesomeIcons.solidClipboard,
                color: _getColor( aSnapshot.hasData && aSnapshot.data != null ? aSnapshot.data['grupos'][muestra['color']] : null ),
              ),
            onTap: () async {              
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarMuestraOperadorPage(
                    usuario: this.widget.usuario,
                    //aparato: aSnapshot.data,
                    muestra: muestra
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
          );
        },
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {        
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Muestras creadas"), 
      ),
      body: 
        this.muestras.isEmpty
        ? Center(child: Text("Cargando muestras"),)
        : GridView.extent(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            maxCrossAxisExtent: 600,
            childAspectRatio: 4.8,
            scrollDirection: Axis.vertical,
            children: muestras.map(
              (DocumentSnapshot muestra) => _buildMuestra(context, muestra)
            ).toList(),
          )      
    );    
  }

}