import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/listado_aparatos.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'editar_muestra_analista.dart';

class ListadoMuestrasPage extends StatefulWidget {
  final Usuario usuario;

  final DocumentSnapshot gestor;

  final DateTime fechaSeleccionada;

  final int selectedIndex;

  ListadoMuestrasPage(
      {Key key,
      this.usuario,
      this.gestor,
      this.fechaSeleccionada,
      this.selectedIndex})
      : super(key: key);

  @override
  State<ListadoMuestrasPage> createState() => new _ListadoMuestrasPageState();
}

class _ListadoMuestrasPageState extends State<ListadoMuestrasPage> {
  SharedPreferences _sharedPreferences;

  int _bottomSelectedIndex = -1;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    if (this.widget.selectedIndex != null) {
      this._bottomSelectedIndex = this.widget.selectedIndex;
    } else {
      SharedPreferences.getInstance()
          .then((SharedPreferences sharedPreferences) {
        this._sharedPreferences = sharedPreferences;
        return;
      }).then((_) {
        if (this._sharedPreferences.containsKey("lmBottomSelectedIndex")) {
          setState(() {
            this._bottomSelectedIndex =
                this._sharedPreferences.getInt("lmBottomSelectedIndex");
            print(
                "lmBottomSelectedIndex :: get :: ${this._bottomSelectedIndex}");
          });
        } else {
          this._bottomSelectedIndex = 0;
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (this._sharedPreferences != null) {
      this
          ._sharedPreferences
          .setInt("lmBottomSelectedIndex", this._bottomSelectedIndex)
          .then((bool result) {
        print("lmBottomSelectedIndex :: set :: ${this._bottomSelectedIndex}");
      });
    }
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
            trailing: Container(
              width: 60,
              height: 40,
              color: _getColor(aSnapshot.hasData && aSnapshot.data != null
                  ? aSnapshot.data['grupos'][muestra['color']]
                  : null),
              padding: EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 4),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AutoSizeText(
                    _isFracciones(
                            muestra['version'],
                            aSnapshot.hasData && aSnapshot.data != null
                                ? aSnapshot.data['grupos'][muestra['color']]
                                : null)
                        ? "${muestra['fraccion'] != null ? muestra['fraccion']['total'] ?? '' : ''}"
                        : "${muestra['pprBr'] ?? ''}",
                    softWrap: false,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontSize: 16),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 1,
                    child: Text(
                      _isFracciones(
                              muestra['version'],
                              aSnapshot.hasData && aSnapshot.data != null
                                  ? aSnapshot.data['grupos'][muestra['color']]
                                  : null)
                          ? 'fracciones'
                          : 'ppr Br ',
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 10, color: Colors.white54),
                    ),
                  )
                ],
              ),
            ),
            onTap: () async {
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditarMuestraAnalistaPage(
                        usuario: this.widget.usuario,
                        aparato: aSnapshot.data,
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
        return Colors.deepOrangeAccent;
      case 2:
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
                      builder: (context) => ListadoMuestrasPage(
                            usuario: this.widget.usuario,
                            gestor: this.widget.gestor,
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
        .where("gestor", isEqualTo: this.widget.gestor.documentID)
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
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: () async {
              String message = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListadoAparatosPage(
                          usuario: widget.usuario,
                          gestor: widget.gestor,
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
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Hero(
                    tag: '${widget.gestor.documentID}Hero',
                    child: AutoSizeText(
                      widget.gestor['razonSocial'],
                      softWrap: true,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline4,
                    )),
                Positioned(
                  bottom: 0,
                  right: 1,
                  child: Text(widget.gestor['sede']),
                )
              ],
            ),
          ),
          Divider(),
          this._bottomSelectedIndex >= 0
              ? StreamBuilder<QuerySnapshot>(
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
                    return SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor);
                  },
                )
              : Center(
                  child:
                      SpinKitThreeBounce(color: Theme.of(context).accentColor),
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
                BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.clipboardCheck),
                    label: "Completas"),
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
