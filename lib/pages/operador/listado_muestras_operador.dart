import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:araee/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'editar_muestra_operador.dart';

/**
 * Esta es la pagina a la que se accede desde el principio
 */
class ListadoMuestrasOperadorPage extends StatefulWidget {
  final Usuario usuario;

  final DateTime fechaSeleccionada;

  final int selectedIndex;

  ListadoMuestrasOperadorPage(
      {Key key, this.usuario, this.fechaSeleccionada, this.selectedIndex})
      : super(key: key);

  @override
  State<ListadoMuestrasOperadorPage> createState() =>
      new _ListadoMuestrasOperadorPageState();
}

class _ListadoMuestrasOperadorPageState
    extends State<ListadoMuestrasOperadorPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _bottomSelectedIndex = 0;

  @override
  void initState() {
    this._bottomSelectedIndex = this.widget.selectedIndex != null
        ? this.widget.selectedIndex
        : this._bottomSelectedIndex;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          return Colors.white;
        }
        break;
    }
  }

  bool _isFracciones(num version, String grupo) {
    switch (grupo) {
      case 'LIBRE':
        {
          return version != null && version == 3;
        }
        break;
      case 'SOSPECHOSO':
        {
          return true;
        }
        break;
      case 'CONTAMINADO':
        {
          return false;
        }
        break;
      default:
        {
          return false;
        }
        break;
    }
  }

  Widget _buildMuestra(BuildContext context, DocumentSnapshot muestra) {
    Timestamp fsT = muestra['fechaHora'];
    String fechaHora = DateFormat("yyyy/MM/dd HH:mm:ss").format(fsT.toDate());
    return Card(
      elevation: 2,
      child: FutureBuilder(
        future: Firestore.instance
            .collection("aparato")
            .document(muestra['aparato'])
            .get(),
        builder:
            (BuildContext aContext, AsyncSnapshot<DocumentSnapshot> aSnapshot) {
          return ListTile(
            title: Text(
              '${muestra['id'] ?? '...'}',
              style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 24),
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  aSnapshot.hasData && aSnapshot.data != null
                      ? "${aSnapshot.data['nombre']}"
                      : "...",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  "Fecha y hora: $fechaHora",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            trailing: Icon(
              muestra["estado"] == 0
                  ? FontAwesomeIcons.clipboard
                  : FontAwesomeIcons.solidClipboard,
              color: _getColor(aSnapshot.hasData && aSnapshot.data != null
                  ? aSnapshot.data['grupos'][muestra['color']]
                  : null),
            ),
            onTap: () async {
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditarMuestraOperadorPage(
                        usuario: this.widget.usuario,
                        //aparato: aSnapshot.data,
                        muestra: muestra)),
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
          );
        },
      ),
    );
  }

  Color _getDecorationColor(int estado) {
    switch (estado) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Colors.green;
    }
  }

  List<Widget> groupByDate(List<DocumentSnapshot> muestras) {
    Map<String, num> mapCount = new Map<String, num>();
    muestras.forEach((DocumentSnapshot muestra) {
      Timestamp fechaHora = muestra["fechaHora"];
      String key = DateFormat("yyyy/MM/dd").format(fechaHora.toDate());
      ;
      num qt = mapCount.containsKey(key) ? mapCount[key] : 0;
      mapCount[key] = qt + 1;
    });
    List<Widget> retValue = new List<Widget>();
    mapCount.forEach((String key, num qt) {
      retValue.add(Card(
          elevation: 2,
          child: ListTile(
              title: Text(
                key,
                style: Theme.of(context).textTheme.headline6,
              ),
              trailing: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: _getDecorationColor(this._bottomSelectedIndex),
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    "$qt",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListadoMuestrasOperadorPage(
                            usuario: this.widget.usuario,
                            fechaSeleccionada: DateFormat("yyyy/MM/dd HH:mm:ss")
                                .parse("$key 00:00:00"),
                            selectedIndex: this._bottomSelectedIndex,
                          )),
                );
              })));
    });
    return retValue;
  }

  @override
  Widget build(BuildContext context) {
    Query query = Firestore.instance
        .collection("analisis")
        .where("gestor", isEqualTo: this.widget.usuario.gestor.documentID)
        .where("estado", isEqualTo: this._bottomSelectedIndex);
    if (this.widget.fechaSeleccionada == null) {
      query = query.orderBy("fechaHora", descending: true);
    } else {
      query = query.where("fechaHora",
          isGreaterThanOrEqualTo: this.widget.fechaSeleccionada);
      query = query.where("fechaHora",
          isLessThan: this.widget.fechaSeleccionada.add(new Duration(days: 1)));
      query = query.orderBy("fechaHora", descending: true);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(this.widget.fechaSeleccionada != null
            ? "Muestras ${DateFormat("yyyy/MM/dd").format(this.widget.fechaSeleccionada)}"
            : "Muestras"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (BuildContext abContext,
                AsyncSnapshot<QuerySnapshot> aSnapshot) {
              if (aSnapshot.hasData && aSnapshot.data != null) {
                List<Widget> childrens;
                if (this.widget.fechaSeleccionada == null) {
                  childrens = groupByDate(aSnapshot.data.documents);
                } else {
                  childrens = aSnapshot.data.documents
                      .map((DocumentSnapshot analisis) =>
                          _buildMuestra(abContext, analisis))
                      .toList();
                }
                return GridView.extent(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  maxCrossAxisExtent: 600,
                  childAspectRatio: 4.8,
                  scrollDirection: Axis.vertical,
                  children: childrens,
                );
              }
              return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
            },
          )
        ],
      ),
      bottomNavigationBar: this._bottomSelectedIndex >= 0
          ? BottomNavigationBar(
              currentIndex: this._bottomSelectedIndex,
              selectedFontSize: 14.0,
              unselectedFontSize: 10.0,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.clipboard), label: "Vacías"),
                BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.solidClipboard),
                    label: "Sin analisis"),
              ],
              onTap: (int bottomSelectedIndex) {
                setState(() {
                  this._bottomSelectedIndex = bottomSelectedIndex;
                });
              },
            )
          : null,
    );
  }
}
