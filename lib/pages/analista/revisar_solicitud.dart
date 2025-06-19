import 'package:araee/model/Usuario.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_color/random_color.dart';

class RevisarSolicitudPage extends StatefulWidget {
  final Usuario usuario;

  final DocumentSnapshot solicitud;

  RevisarSolicitudPage({Key key, this.usuario, this.solicitud})
      : super(key: key);

  @override
  State<RevisarSolicitudPage> createState() => new _RevisarSolicitudPageState();
}

class _RevisarSolicitudPageState extends State<RevisarSolicitudPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  final _formKey2 = GlobalKey<FormState>();

  final RandomColor _randomColor = RandomColor();

  String _codigo = "";

  String _nombre = "";

  String _equivalente;

  bool _saving = false;

  Future<bool> _showRejectDialog(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext dContext) {
          return StatefulBuilder(builder: (sbContext, setState2) {
            return AlertDialog(
              title: Text(
                "Rechazar solicitud",
                style: Theme.of(sbContext).textTheme.headline5,
              ),
              content: Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Para rechazar la solicitud de nuevo raee "${this.widget.solicitud["nombre"]}", selecciona el raee equivalente.',
                        style: Theme.of(sbContext).textTheme.bodyText1,
                        textAlign: TextAlign.justify,
                        softWrap: true,
                      ),
                      Divider(),
                      /*OutlineLabel(
                        textLabel: "Categoria equivalente",
                        padding: 2.5,
                        child: */
                      FutureBuilder(
                          future: Firestore.instance
                              .collection("aparato")
                              .orderBy("nombre")
                              .getDocuments(),
                          builder: (BuildContext abContext,
                              AsyncSnapshot<QuerySnapshot> aSnapshot) {
                            if (aSnapshot.hasData && aSnapshot.data != null) {
                              return DropdownButtonFormField<String>(
                                isDense: true,
                                value: this._equivalente,
                                items: aSnapshot.data.documents
                                    .map((DocumentSnapshot aparato) {
                                  return DropdownMenuItem<String>(
                                    value: aparato.data["nombre"],
                                    child: Text(
                                      aparato.data["nombre"],
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'seleccione un valor';
                                  }
                                  return null;
                                },
                                onSaved: (String newValue) {
                                  setState2(() {
                                    this._equivalente = newValue;
                                  });
                                },
                                onChanged: (String newValue) {
                                  setState2(() {
                                    this._equivalente = newValue;
                                  });
                                },
                              );
                            }
                            return Text("...");
                          }
                          /*)*/
                          ),
                    ],
                  )),
              actions: <Widget>[
                RaisedButton(
                  child: Text(
                    "Rechazar",
                    style: Theme.of(sbContext).textTheme.button,
                  ),
                  onPressed: () {
                    if (!_formKey2.currentState.validate()) {
                      return;
                    }
                    _formKey2.currentState.save();
                    Navigator.of(sbContext).pop(true);
                  },
                ),
                RaisedButton(
                  color: Theme.of(sbContext).accentColor,
                  child: Text(
                    "Cancelar",
                    style: Theme.of(sbContext).textTheme.button,
                  ),
                  onPressed: () {
                    Navigator.of(sbContext).pop(false);
                  },
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Revisar solicitud"),
        ),
        body: ModalProgressHUD(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(10.0),
              shrinkWrap: true,
              children: <Widget>[
                GridView.extent(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    maxCrossAxisExtent: 600,
                    childAspectRatio: 4.6,
                    children: <Widget>[
                      OutlineLabel(
                        textLabel: "Código *",
                        child: TextFormField(
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return 'Ingrese el código';
                            } else if (value.length > 5) {
                              return 'El código debe tener maximo 5 caracteres';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            this._codigo = value.trim().toUpperCase();
                          },
                          autofocus: false,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      OutlineLabel(
                        textLabel: "Nombre *",
                        child: TextFormField(
                          initialValue: this.widget.solicitud["nombre"],
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingrese el nombre';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            this._nombre = value;
                          },
                          autofocus: false,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ]),
                RaisedButton(
                  elevation: 5,
                  color: Theme.of(context).accentColor,
                  child: AutoSizeText(
                    "Aceptar solicitud",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    setState(() {
                      _saving = true;
                    });
                    _formKey.currentState.save();
                    await this.widget.solicitud.reference.setData({
                      "aprueba": this.widget.usuario.id,
                      "fechaHoraSolucion": DateTime.now(),
                      "nombre": this._nombre,
                      "estado": "aprobada"
                    }, merge: true);
                    await Firestore.instance
                        .collection("aparato")
                        .document()
                        .setData({
                      "codigo": this._codigo,
                      "nombre": this._nombre,
                      "grupos": {
                        "BLANCO": "SOSPECHOSO",
                        "NEGRO": "SOSPECHOSO",
                        "OTROS": "SOSPECHOSO",
                      }
                    });
                    setState(() {
                      _saving = false;
                    });
                    var message =
                        "Se ha aceptado la solicitud de adición de nuevo raee";
                    Navigator.of(context).pop(message);
                  },
                ),
                RaisedButton(
                  elevation: 5,
                  color: Theme.of(context).primaryColor,
                  child: AutoSizeText(
                    "Rechazar",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (await _showRejectDialog(context)) {
                      setState(() {
                        _saving = true;
                      });
                      await this.widget.solicitud.reference.setData({
                        "aprueba": this.widget.usuario.id,
                        "fechaHoraSolucion": DateTime.now(),
                        "equivalente": this._equivalente,
                        "estado": "rechazada"
                      }, merge: true);
                      setState(() {
                        _saving = false;
                      });
                      var message =
                          "Se ha rechazado la solicitud de adición de nuevo raee";
                      Navigator.of(context).pop(message);
                    }
                  },
                ),
              ],
            ),
          ),
          inAsyncCall: _saving,
          color: _randomColor.randomColor(),
          progressIndicator: SpinKitWave(
            color: _randomColor.randomColor(),
            size: 75,
          ),
        ));
  }
}
