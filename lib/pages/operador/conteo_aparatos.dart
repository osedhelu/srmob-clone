import 'dart:math';

import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/operador/listado_muestras.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_color/random_color.dart';

class ConteoAparatosPage extends StatefulWidget {
  final Usuario usuario;
  final DocumentSnapshot gestor;
  final DocumentSnapshot aparato;
  final String color;
  final String numeroSeguimiento;
  final Random random = Random();

  ConteoAparatosPage(
      {Key key,
      this.usuario,
      this.gestor,
      this.aparato,
      this.color,
      this.numeroSeguimiento})
      : super(key: key);

  @override
  State<ConteoAparatosPage> createState() => new _ConteoAparatosPageState();
}

class _ConteoAparatosPageState extends State<ConteoAparatosPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  final HttpsCallable getSampleId =
      CloudFunctions.instance.getHttpsCallable(functionName: 'getSampleId');

  final RandomColor _randomColor = RandomColor();

  int _sliderValue = 1;

  bool _saving = false;

  num _totalMuestras;

  @override
  void initState() {
    this
        .widget
        .aparato
        .reference
        .collection("muestras")
        .document(this.widget.color)
        .get()
        .then((DocumentSnapshot muestras) {
      this._totalMuestras = muestras.exists ? muestras["totalMuestras"] : 0;
    });
    super.initState();
  }

  num _getSample() {
    return ((1 / 300) + (9 / (300 * (this._totalMuestras + 1))));
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
          print("Llego un valor raro: $grupo");
          return Colors.grey;
        }
        break;
    }
  }

  Future<void> _showSampleDialog(
      BuildContext context, String conteo, int numeroMuestras) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext dContext) {
          return AlertDialog(
            title: Text(
              "Muestreo",
              style: Theme.of(context).textTheme.headline,
            ),
            content: Text(
              'Recuerde que debe separar $numeroMuestras muestra${numeroMuestras > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.display1,
              softWrap: true,
            ),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  "Ver muestras",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListadoMuestrasPage(
                            usuario: this.widget.usuario,
                            gestor: this.widget.gestor,
                            aparato: this.widget.aparato,
                            color: this.widget.color,
                            numeroSeguimiento: this.widget.numeroSeguimiento,
                            conteo: conteo)),
                  );
                  Navigator.of(dContext).pop();
                },
              ),
              RaisedButton(
                child: Text(
                  "Seguir contando",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () {
                  Navigator.of(dContext).pop();
                },
              ),
            ],
          );
        });
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
                style: Theme.of(context).textTheme.display3,
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
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Ingrese la cantidad"),
        ),
        backgroundColor: _getColor(widget.aparato['grupos'][widget.color]),
        body: ModalProgressHUD(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(15.0),
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: AutoSizeText(
                        widget.aparato['nombre'],
                        maxLines: 1,
                        style: Theme.of(context).textTheme.display2,
                      )),
                ),
                Divider(),
                GridView.extent(
                  shrinkWrap: true,
                  maxCrossAxisExtent: 600,
                  childAspectRatio: 5,
                  children: <Widget>[
                    _buildInfoCard(context, "Color", widget.color),
                    _buildInfoCard(context, "Grupo",
                        widget.aparato['grupos'][widget.color]),
                  ],
                ),
                Divider(),
                GridView.extent(
                  shrinkWrap: true,
                  maxCrossAxisExtent: 600,
                  childAspectRatio: 4.6,
                  children: <Widget>[
                    OutlineLabel(
                      textLabel: "Cantidad *",
                      child: TextFormField(
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Ingrese la cantidad';
                          }
                          int cantidad = int.tryParse(value);
                          if (cantidad == null) {
                            return 'La cantidad no es valida';
                          }
                          if (cantidad <= 0) {
                            return 'La cantidad debe ser positiva';
                          }
                          if (cantidad > 500) {
                            return 'Debe reportar la cantidad en varios conteos';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          this._sliderValue = int.parse(value);
                        },
                        autofocus: true,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Divider(),
                RaisedButton(
                  elevation: 5,
                  color: Theme.of(context).accentColor,
                  child: AutoSizeText(
                    "Contar",
                    style: Theme.of(context)
                        .textTheme
                        .display1
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
                    num prioridad = this._getSample();
                    print("prioridad: $prioridad");
                    int muestras = 0;
                    num sample;
                    for (var index = 0; index < _sliderValue; index++) {
                      sample = this.widget.random.nextDouble();
                      print("prioridad: $prioridad -- sample -- $sample");
                      muestras += (sample <= prioridad ? 1 : 0);
                    }
                    DocumentReference docRef =
                        Firestore.instance.collection("conteo").document();
                    try {
                      num count;
                      if (muestras > 0) {
                        HttpsCallableResult result =
                            await this.getSampleId.call(<String, dynamic>{
                          'aparato': this.widget.aparato.documentID,
                          'color': this.widget.color,
                          'count': muestras
                        });
                        count = result.data;
                      }
                      WriteBatch batch = Firestore.instance.batch();
                      DateTime nowDateTime = DateTime.now();
                      String numeroManifiesto = this.widget.numeroSeguimiento ??
                          '${nowDateTime.year}-${nowDateTime.month}-${nowDateTime.day}';
                      print(
                          "conteo :: gestor ${this.widget.gestor.documentID} :: ${docRef.documentID} :: $numeroManifiesto");
                      batch.setData(docRef, {
                        'gestor': this.widget.gestor.documentID,
                        'numeroManifiesto': numeroManifiesto,
                        'usuario': this.widget.usuario.id,
                        'aparato': this.widget.aparato.documentID,
                        'color': this.widget.color,
                        'cantidad': _sliderValue,
                        'muestras': muestras,
                        'fechaHora': DateTime.now()
                      });
                      if (muestras > 0) {
                        for (var index = 0; index < muestras; index++) {
                          DocumentReference aref = Firestore.instance
                              .collection("analisis")
                              .document();
                          print(
                              "Agregando analisis ... $index de $muestras ${aref.documentID}");

                          batch.setData(aref, {
                            'id': this.widget.aparato["codigo"] +
                                "-" +
                                this.widget.color.substring(0, 3) +
                                "-${count + index}",
                            'gestor': this.widget.gestor.documentID,
                            'numeroManifiesto': numeroManifiesto,
                            'usuario': this.widget.usuario.id,
                            'aparato': this.widget.aparato.documentID,
                            'color': this.widget.color,
                            'conteo': docRef.documentID,
                            'version': 3,
                            'estado': 0,
                            'fechaHora': DateTime.now()
                                .add(new Duration(milliseconds: index))
                          });
                        }
                      }
                      await batch.commit();
                      setState(() {
                        _saving = false;
                      });
                      var message;
                      if (muestras > 0) {
                        message =
                            "Ha agregado $_sliderValue elementos de tipo ${this.widget.aparato.data['nombre']} y debe separar $muestras para analisis";
                        await _showSampleDialog(
                            context, docRef.documentID, muestras);
                      } else {
                        message =
                            "Ha agregado $_sliderValue elementos de tipo ${this.widget.aparato.data['nombre']}";
                      }
                      Navigator.of(context).pop(message);
                    } catch (error) {
                      print("Error $error");
                      setState(() {
                        _saving = false;
                      });
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
                  },
                ),
                RaisedButton(
                  elevation: 5,
                  color: Theme.of(context).primaryColor,
                  child: AutoSizeText(
                    "Cancelar",
                    style: Theme.of(context)
                        .textTheme
                        .display1
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
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
