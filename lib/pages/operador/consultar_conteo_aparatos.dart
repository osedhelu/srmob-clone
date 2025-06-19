import 'package:araee/model/Usuario.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'editar_conteo_aparatos.dart';

class ConsultarConteoAparatosPage extends StatelessWidget {
  final Usuario usuario;
  final DocumentSnapshot aparato;
  final DocumentSnapshot conteo;

  ConsultarConteoAparatosPage(
      {Key key, this.usuario, this.aparato, this.conteo})
      : super(key: key);

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
          print("Llego un valor raro: $grupo");
          return Colors.grey;
        }
        break;
    }
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Card(
        elevation: 5.0,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 10,
              top: 5,
              child: Text(
                label,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Positioned(
              right: 10.0,
              bottom: 3.0,
              left: 0,
              top: 18,
              child: AutoSizeText(
                value,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.right,
                maxLines: 1,
                softWrap: true,
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Consultar conteo"),
        ),
        backgroundColor:
            _getColor(this.aparato['grupos'][this.conteo['color']]),
        body: ListView(
            padding: EdgeInsets.all(15.0),
            shrinkWrap: true,
            children: <Widget>[
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: AutoSizeText(
                      this.aparato['nombre'],
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline5,
                    )),
              ),
              Divider(),
              GridView.extent(
                shrinkWrap: true,
                maxCrossAxisExtent: 600,
                childAspectRatio: 5,
                children: <Widget>[
                  _buildInfoCard(context, "Color", this.conteo['color']),
                  _buildInfoCard(context, "Grupo",
                      this.aparato['grupos'][this.conteo['color']]),
                ],
              ),
              Divider(),
              GridView.extent(
                shrinkWrap: true,
                maxCrossAxisExtent: 600,
                childAspectRatio: 4.6,
                children: <Widget>[
                  _buildInfoCard(
                      context, "Cantidad", '${this.conteo['cantidad']}'),
                  Divider(),
                ],
              ),
              RaisedButton(
                  elevation: 5,
                  color: Theme.of(context).accentColor,
                  child: AutoSizeText(
                    "Actualizar",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditarConteoAparatosPage(
                              usuario: this.usuario,
                              aparato: this.aparato,
                              conteo: this.conteo)),
                    );
                    Navigator.of(context).pop();
                  }),
              RaisedButton(
                elevation: 5,
                color: Theme.of(context).primaryColor,
                child: AutoSizeText(
                  "Volver",
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]));
  }
}
