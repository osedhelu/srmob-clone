import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/operador/editar_fraccion_operador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListadoFraccionesPage extends StatefulWidget {
  final Usuario usuario;
  final DocumentSnapshot aparato;
  final DocumentSnapshot muestra;

  ListadoFraccionesPage({Key key, this.usuario, this.aparato, this.muestra})
      : super(key: key);

  @override
  State<ListadoFraccionesPage> createState() =>
      new _ListadoFraccionesPageState();
}

class _ListadoFraccionesPageState extends State<ListadoFraccionesPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

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

  Widget _buildFraccionWidget(BuildContext context, DocumentSnapshot fraccion) {
    String grupo =
        this.widget.aparato.data['grupos'][this.widget.muestra.data['color']];
    TextStyle capTS =
        Theme.of(context).textTheme.caption.copyWith(color: Colors.black);
    TextStyle valTS = Theme.of(context)
        .textTheme
        .caption
        .copyWith(fontWeight: FontWeight.normal);
    return Card(
      elevation: 2.5,
      color: _getColor(grupo),
      child: ListTile(
        title: Text(
          fraccion['id'] ?? '',
          style: Theme.of(context).textTheme.headline5,
        ),
        isThreeLine: true,
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(flex: 4, child: Text("Plástico:", style: capTS)),
                Expanded(
                    flex: 4,
                    child: Text("${fraccion['plastico'] ?? ''}",
                        textAlign: TextAlign.right, style: valTS)),
                Expanded(flex: 1, child: Text("")),
                Expanded(flex: 4, child: Text("Color:", style: capTS)),
                Expanded(
                    flex: 4,
                    child: Text("${fraccion['color'] ?? ''}",
                        textAlign: TextAlign.right, style: valTS)),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(flex: 4, child: Text("Peso (g):", style: capTS)),
                Expanded(
                    flex: 3,
                    child: Text("${fraccion['peso'] ?? ''}",
                        textAlign: TextAlign.right, style: valTS)),
                Expanded(flex: 1, child: Text("")),
                Expanded(flex: 4, child: Text("ppm (Br):", style: capTS)),
                Expanded(
                    flex: 3,
                    child: Text("${fraccion['pprBr'] ?? ''}",
                        textAlign: TextAlign.right, style: valTS)),
                Expanded(flex: 1, child: Text("")),
                Expanded(flex: 6, child: Text("Incertidumbre:", style: capTS)),
                Expanded(
                    flex: 2,
                    child: Text("${fraccion['incertidumbre'] ?? ''}",
                        textAlign: TextAlign.right, style: valTS)),
              ],
            ),
          ],
        ),
        onTap: () async {
          String message = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditarFraccionPage(
                      aparato: widget.aparato,
                      analisis: widget.muestra,
                      fraccion: fraccion,
                    )),
          );
          if (message != null) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              duration: Duration(seconds: 3),
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("${widget.muestra.data['id']}"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: this
            .widget
            .muestra
            .reference
            .collection("fraccion")
            .orderBy("id")
            .snapshots(),
        builder:
            (BuildContext fContext, AsyncSnapshot<QuerySnapshot> fSnapshot) {
          if (fSnapshot.hasData && fSnapshot.data != null) {
            return GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 600,
              childAspectRatio: 4.2,
              children: fSnapshot.data.documents
                  .map((DocumentSnapshot dsFraccion) => _buildFraccionWidget(
                        fContext,
                        dsFraccion,
                      ))
                  .toList(),
            );
          }
          return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(FontAwesomeIcons.plus, color: Colors.white),
        onPressed: () async {
          FieldValue iFraccion = FieldValue.increment(1);
          await this.widget.muestra.reference.updateData({
            'fraccion.total': iFraccion,
          });
          DocumentSnapshot analisis = await this.widget.muestra.reference.get();
          DocumentSnapshot fraccion = await (await analisis.reference
                  .collection("fraccion")
                  .add({
            'id': '${analisis['id']}-${analisis['fraccion']['total']}'
          }))
              .get();
          String message = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditarFraccionPage(
                      aparato: widget.aparato,
                      analisis: widget.muestra,
                      fraccion: fraccion,
                    )),
          );
          if (message != null) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              duration: Duration(seconds: 3),
            ));
          }
        },
      ),
    );
  }
}
