import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/operador/conteo_aparatos.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListadoColoresPage extends StatefulWidget{    
        
    final Usuario usuario;
    final DocumentSnapshot gestor;
    final DocumentSnapshot aparato;
    final String numeroSeguimiento;

    ListadoColoresPage({Key key, this.usuario, this.gestor, this.aparato, this.numeroSeguimiento}) : super(key: key);

    @override
    State<ListadoColoresPage> createState() => new _ListadoColoresPageState();
}

class _ListadoColoresPageState extends State<ListadoColoresPage>{

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
        return Colors.grey;
      }break;
    }
  }

  Widget _buildAparato(BuildContext context, String color){
    
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: RawMaterialButton(
        elevation: 5.0,      
        fillColor: _getColor( widget.aparato['grupos'][color] ),
        splashColor: Theme.of(context).backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text( 
            color,
            maxLines: 1,
            style: Theme.of(context).textTheme.display1,
          )          
        ), 
        onPressed: () async {
          String message = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConteoAparatosPage(
                  usuario: widget.usuario,
                  gestor: widget.gestor,
                  aparato: widget.aparato,
                  color: color,
                  numeroSeguimiento: this.widget.numeroSeguimiento
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
        title: Text("Seleccione el color"),
      ),
      //drawer: MenuOperadorPage(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Hero(
                tag: '${widget.aparato.documentID}Hero',
                child: AutoSizeText( 
                  widget.aparato['nombre'],
                  maxLines: 1,
                  style: Theme.of(context).textTheme.display2, 
                )
              )
            ),
          ),
          GridView.extent(
            shrinkWrap: true,
            maxCrossAxisExtent: 600,
            childAspectRatio: 5,
            children: <Widget>[
              _buildAparato(context, "BLANCO"),
              _buildAparato(context, "NEGRO"),
              _buildAparato(context, "OTROS"),
            ],
          )
        ],
      )
    );
  }

}