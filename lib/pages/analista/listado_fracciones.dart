import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/editar_fraccion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ListadoFraccionesPage extends StatefulWidget {
  final Usuario usuario;
  final DocumentSnapshot aparato;
  final DocumentSnapshot muestra;
  final bool eliminable;

  ListadoFraccionesPage({
    this.usuario,
    this.aparato,
    this.muestra,
    this.eliminable,
  });

  @override
  State<ListadoFraccionesPage> createState() =>
      new _ListadoFraccionesPageState();
}

class _ListadoFraccionesPageState extends State<ListadoFraccionesPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool loading = false;

  @override
  void initState() {
    super.initState();
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
        builder: (_, fSnapshot) {
          if (fSnapshot.hasData && fSnapshot.data != null) {
            return GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 600,
              childAspectRatio: 4.2,
              children: fSnapshot.data.documents
                  .map((dsFraccion) => _FraccionWidget(
                        fraccion: dsFraccion,
                        aparato: this.widget.aparato,
                        eliminable: this.widget.eliminable,
                        muestra: this.widget.muestra,
                      ))
                  .toList(),
            );
          }
          return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: this.loading
            ? null
            : () async {
                setState(() => this.loading = true);

                FieldValue iFraccion = FieldValue.increment(1);
                await this
                    .widget
                    .muestra
                    .reference
                    .updateData({'fraccion.total': iFraccion});

                DocumentSnapshot analisis =
                    await this.widget.muestra.reference.get();
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
                      eliminable: this.widget.eliminable,
                    ),
                  ),
                );

                setState(() => this.loading = false);

                if (message != null) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text(
                      message,
                      style: Theme.of(context)
                          .textTheme
                          .body2
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

class _FraccionWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final DocumentSnapshot fraccion;
  final DocumentSnapshot aparato;
  final DocumentSnapshot muestra;
  final bool eliminable;

  const _FraccionWidget({
    @required this.fraccion,
    @required this.aparato,
    @required this.muestra,
    @required this.eliminable,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    String grupo = this.aparato.data['grupos'][this.muestra.data['color']];
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
          style: Theme.of(context).textTheme.headline,
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
                        textAlign: TextAlign.right, style: valTS))
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
                      aparato: this.aparato,
                      analisis: this.muestra,
                      fraccion: fraccion,
                      eliminable: this.eliminable,
                    )),
          );
          if (message != null) {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .body2
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              duration: Duration(seconds: 3),
            ));
          }
        },
      ),
    );
  }

  Color _getColor(String grupo) {
    switch (grupo) {
      case 'LIBRE':
        return Colors.green;
      case 'SOSPECHOSO':
        return Colors.blue;
      case 'CONTAMINADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
