import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/editar_muestra_analista.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class ListadoColoresPage extends StatefulWidget {
  final Usuario usuario;
  final DocumentSnapshot gestor;
  final DocumentSnapshot aparato;

  ListadoColoresPage({Key key, this.usuario, this.gestor, this.aparato})
      : super(key: key);

  @override
  State<ListadoColoresPage> createState() => new _ListadoColoresPageState();
}

class _ListadoColoresPageState extends State<ListadoColoresPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final HttpsCallable getSampleId =
      CloudFunctions.instance.getHttpsCallable(functionName: 'getSampleId');

  Color _getColor(String grupo) {
    switch (grupo) {
      case 'LIBRE':
        {
          return Colors.green;
        }
        break;
      case 'SOSPECHOSO':
        {
          return Colors.blue;
        }
        break;
      case 'CONTAMINADO':
        {
          return Colors.red;
        }
        break;
      default:
        {
          return Colors.grey;
        }
        break;
    }
  }

  Widget _buildAparato(
      BuildContext context, DocumentSnapshot gestor, String color) {
    return Card(
        elevation: 2.5,
        color: _getColor(widget.aparato['grupos'][color]),
        child: ListTile(
          title: Text(
            color,
            style: Theme.of(context).textTheme.headline,
          ),
          onTap: () async {
            DocumentReference aRef =
                Firestore.instance.collection("analisis").document();
            try {
              HttpsCallableResult result = await this
                  .getSampleId
                  .call(<String, dynamic>{
                'aparato': this.widget.aparato.documentID,
                'color': color,
                'count': 1
              });
              num count = result.data;
              WriteBatch batch = Firestore.instance.batch();
              batch.setData(aRef, {
                'id': this.widget.aparato["codigo"] +
                    "-" +
                    color.substring(0, 3) +
                    "-$count",
                'gestor': this.widget.gestor.documentID,
                'usuario': this.widget.usuario.id,
                'aparato': this.widget.aparato.documentID,
                'color': color,
                'version': 3,
                'estado': 0,
                'fechaHora': DateTime.now()
              });
              /*
              FieldValue iMuestra = FieldValue.increment(1);
              batch.updateData(
                this.widget.gestor.reference,
                {
                  'muestras.${this.widget.aparato.documentID}-$color': iMuestra,
                  'muestras.${this.widget.aparato.documentID}': iMuestra,
                  'muestras.total': iMuestra
                },
              );
              */
              await batch.commit();
            } catch (error) {
              print("Error inesperado: $error");
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(
                  "Ocurrio un error inesperado, intente nuevamente.\n si el problema persiste contacte al administrador copiando el siguiente código de error: $error",
                  style: Theme.of(context)
                      .textTheme
                      .body2
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
                duration: Duration(seconds: 3),
              ));
            }
            DocumentSnapshot muestra = await aRef.get();
            if (muestra.exists) {
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditarMuestraAnalistaPage(
                        usuario: widget.usuario,
                        aparato: widget.aparato,
                        muestra: muestra)),
              );
              Navigator.of(context).pop(message);
            } else {
              print("falta agrega algun mensaje raro de alerta amiguito");
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.aparato['nombre']),
        ),
        body: GridView.extent(
          shrinkWrap: true,
          maxCrossAxisExtent: 600,
          childAspectRatio: 5,
          children: ["BLANCO", "NEGRO", "OTROS"]
              .map((String color) =>
                  _buildAparato(context, widget.gestor, color))
              .toList(),
        ));
  }
}
