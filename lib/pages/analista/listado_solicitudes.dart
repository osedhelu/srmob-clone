import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/revisar_solicitud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ListadoSolicitudesPage extends StatelessWidget {
  final Usuario usuario;

  ListadoSolicitudesPage({Key key, this.usuario}) : super(key: key);

  Widget _buildSolicitud(BuildContext context, DocumentSnapshot solicitud) {
    TextStyle capTS = Theme.of(context)
        .textTheme
        .caption
        .copyWith(fontWeight: FontWeight.bold);
    TextStyle valTS = Theme.of(context)
        .textTheme
        .caption
        .copyWith(fontWeight: FontWeight.normal, fontSize: 10);
    Timestamp fsT = solicitud['fechaHora'];
    String fechaHora = DateFormat("yyyy/MM/dd HH:mm").format(fsT.toDate());
    Timestamp fssT = solicitud['fechaHoraSolucion'];
    String fechaHoraSolucion = DateFormat("yyyy/MM/dd HH:mm")
        .format(fssT != null ? fssT.toDate() : fsT.toDate());
    return ListTile(
      isThreeLine: true,
      title: Text(
        solicitud["nombre"],
        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 24),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(flex: 2, child: Text("Solicita", style: capTS)),
              Expanded(
                flex: 8,
                child: FutureBuilder(
                    future: Firestore.instance
                        .collection("usuario")
                        .document(solicitud["solicita"])
                        .get(),
                    builder: (BuildContext abContext,
                        AsyncSnapshot<DocumentSnapshot> aSnapshot) {
                      if (aSnapshot.hasData && aSnapshot.data != null) {
                        return Text("${aSnapshot.data["email"]} $fechaHora",
                            textAlign: TextAlign.right,
                            style: valTS,
                            softWrap: false);
                      }
                      return Text("... $fechaHora",
                          textAlign: TextAlign.right, style: valTS);
                    }),
              ),
            ],
          ),
          solicitud["aprueba"] != null
              ? Row(
                  children: <Widget>[
                    Expanded(flex: 2, child: Text("Resuelve", style: capTS)),
                    Expanded(
                      flex: 8,
                      child: FutureBuilder(
                          future: Firestore.instance
                              .collection("usuario")
                              .document(solicitud["aprueba"])
                              .get(),
                          builder: (BuildContext abContext,
                              AsyncSnapshot<DocumentSnapshot> aSnapshot) {
                            if (aSnapshot.hasData && aSnapshot.data != null) {
                              return Text(
                                "${aSnapshot.data["email"]} $fechaHoraSolucion",
                                textAlign: TextAlign.right,
                                style: valTS,
                                softWrap: false,
                              );
                            }
                            return Text("... $fechaHoraSolucion",
                                textAlign: TextAlign.right, style: valTS);
                          }),
                    ),
                  ],
                )
              : Container(
                  height: 0,
                ),
          solicitud["equivalente"] != null
              ? Row(
                  children: <Widget>[
                    Expanded(
                        flex: 4, child: Text("RAEE recomendado", style: capTS)),
                    Expanded(
                        flex: 6,
                        child: Text(solicitud["equivalente"],
                            textAlign: TextAlign.right, style: valTS)),
                  ],
                )
              : Container(
                  height: 0,
                ),
          Divider(),
        ],
      ),
      trailing: _getIcon(solicitud['estado']),
      onTap: () {
        if (solicitud['estado'] != "aprobada" &&
            solicitud['estado'] != "rechazada") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RevisarSolicitudPage(
                    usuario: this.usuario, solicitud: solicitud)),
          );
        }
      },
    );
  }

  Icon _getIcon(String estado) {
    switch (estado) {
      case 'aprobada':
        return Icon(
          FontAwesomeIcons.check,
          color: Colors.green,
          size: 48,
        );
      case 'rechazada':
        return Icon(FontAwesomeIcons.times, color: Colors.red, size: 48);
      default:
        return Icon(FontAwesomeIcons.question, color: Colors.blue, size: 48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Solicitud nuevo RAEE"),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("solicitudes")
                .orderBy("fechaHora", descending: true)
                .snapshots(),
            builder: (BuildContext abContext,
                AsyncSnapshot<QuerySnapshot> aSnapshot) {
              if (aSnapshot.hasData && aSnapshot.data != null) {
                return GridView.extent(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  maxCrossAxisExtent: 600,
                  childAspectRatio: 4.8,
                  scrollDirection: Axis.vertical,
                  children: aSnapshot.data.documents
                      .map((DocumentSnapshot analisis) =>
                          _buildSolicitud(abContext, analisis))
                      .toList(),
                );
              }
              return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
            }));
  }
}
