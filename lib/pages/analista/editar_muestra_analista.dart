import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/analista/listado_fracciones.dart';
import 'package:araee/widget/FirebaseTypeAheadField.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_color/random_color.dart';

class EditarMuestraAnalistaPage extends StatefulWidget {
  final Usuario usuario;
  final DocumentSnapshot aparato;
  final DocumentSnapshot muestra;
  final bool eliminable;

  EditarMuestraAnalistaPage(
      {Key key,
      this.usuario,
      this.aparato,
      this.muestra,
      this.eliminable = true})
      : super(key: key);

  @override
  State<EditarMuestraAnalistaPage> createState() =>
      new _EditarMuestraAnalistaState();
}

class _EditarMuestraAnalistaState extends State<EditarMuestraAnalistaPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _muestra = Map<String, dynamic>();

  int deleteCount = 3;

  final RandomColor _randomColor = RandomColor();

  bool _saving = false;

  @override
  void initState() {
    _muestra["marca"] = this.widget.muestra["marca"];
    _muestra["pais"] = this.widget.muestra["pais"];
    _muestra["anio"] = this.widget.muestra["anio"];
    _muestra["peso"] = this.widget.muestra["peso"];
    _muestra["pprBr"] = this.widget.muestra["pprBr"];
    _muestra["estado"] = this.widget.muestra["estado"];
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

  Widget _buildIdCard(BuildContext context) {
    return Card(
        child: Stack(
      children: <Widget>[
        Positioned(
          left: 10, top: 5, //"# Muestra", this.widget.muestra.data['id']
          child: Text(
            "# Muestra",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        Positioned(
          right: 10.0,
          bottom: 3.0,
          left: 0,
          top: 18,
          child: StreamBuilder<DocumentSnapshot>(
            stream: this.widget.muestra.reference.snapshots(),
            builder: (BuildContext mContext, AsyncSnapshot mSnapshot) {
              if (mSnapshot.hasData && mSnapshot.data != null) {
                return AutoSizeText("${mSnapshot.data['id'] ?? ''}",
                    style: Theme.of(context).textTheme.display1,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    softWrap: true);
              }
              return Text("Cargando...");
              //
            },
          ),
        )
      ],
    ));
  }

  List<Widget> _buildLegacyFields(
      List<Widget> beforeList, BuildContext context, List<Widget> afterList) {
    List<Widget> retValue = new List<Widget>();
    retValue.addAll(beforeList);
    if (this.widget.muestra['version'] != 3) {
      retValue.add(OutlineLabel(
          textLabel: "Marca *",
          padding: 2.5,
          child: FirebaseTypeAheadField(
            canAdd: false,
            coleccion: "marcas",
            validator: (String value) {
              if (value == null || value.isEmpty) {
                return "Seleccione una marca";
              }
              return null;
            },
            initialValue: this._muestra['marca'],
            onSaved: (String value) {
              this._muestra['marca'] = value;
            },
          )));
      retValue.add(OutlineLabel(
          textLabel: "País de fabricación *",
          padding: 2.5,
          child: FirebaseTypeAheadField(
            canAdd: false,
            coleccion: "paises",
            validator: (String value) {
              if (value == null || value.isEmpty) {
                return "Seleccione una país";
              }
              return null;
            },
            initialValue: this._muestra['pais'] ?? '',
            onSaved: (String value) {
              this._muestra['pais'] = value;
            },
          )));
      retValue.add(OutlineLabel(
        textLabel: "Año *",
        padding: 5.0,
        child: TextFormField(
          validator: (value) {
            num numValue = num.tryParse(value);
            if (numValue == null) {
              return 'Ingrese un número valido';
            }
            if (numValue != 0 && numValue < 1900) {
              return 'Ingrese un año que sea valido';
            }
            if (numValue > DateTime.now().year) {
              return 'Ingrese un año valido valido que no sea en el futuro';
            }
            return null;
          },
          initialValue: "${this._muestra['anio'] ?? ''}",
          onSaved: (String value) {
            _muestra['anio'] = num.tryParse(value);
          },
          keyboardType:
              TextInputType.numberWithOptions(signed: false, decimal: false),
        ),
      ));
    }
    retValue.addAll(afterList);
    return retValue;
  }

  @override
  Widget build(BuildContext context) {
    String grupo = this.widget.aparato != null
        ? this.widget.aparato.data['grupos'][this.widget.muestra.data['color']]
        : "SOSPECHOSO";
    String nombre = this.widget.aparato != null
        ? this.widget.aparato.data['nombre']
        : '...';
    bool isFracciones =
        _isFracciones(this.widget.muestra.data['version'], grupo);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "$nombre",
          ),
        ),
        backgroundColor: _getColor(grupo),
        body: ModalProgressHUD(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(2.5),
              shrinkWrap: true,
              children: <Widget>[
                GridView.extent(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    maxCrossAxisExtent: 600,
                    childAspectRatio: 4.6,
                    children: this._buildLegacyFields(
                      <Widget>[
                        _buildIdCard(context),
                      ],
                      context,
                      <Widget>[
                        OutlineLabel(
                          textLabel: "Peso (Kg) *",
                          padding: 2.5,
                          child: TextFormField(
                            initialValue: '${this._muestra['peso'] ?? ''}',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"(\d+)([.]?\d*)?")),
                            ],
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Ingrese un valor';
                              }
                              num numValue = num.tryParse(value);
                              if (num.tryParse(value) == null) {
                                return 'Ingrese un número valido';
                              }
                              if (numValue < 0) {
                                return 'Ingrese un número valido';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              this._muestra['peso'] = num.tryParse(value);
                            },
                            keyboardType: TextInputType.numberWithOptions(
                                signed: false, decimal: true),
                          ),
                        ),
                        isFracciones
                            ? Divider(
                                height: 1,
                              )
                            : OutlineLabel(
                                textLabel: "ppm (Br) *",
                                padding: 2.5,
                                child: TextFormField(
                                  initialValue:
                                      '${this._muestra['pprBr'] ?? ''}',
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Ingrese un valor';
                                    }
                                    num numValue = num.tryParse(value);
                                    if (num.tryParse(value) == null) {
                                      return 'Ingrese un número valido';
                                    }
                                    if (numValue < 0) {
                                      return 'Ingrese un número valido';
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    this._muestra['pprBr'] =
                                        num.tryParse(value);
                                  },
                                  autofocus: true,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: false, decimal: false),
                                ),
                              ),
                        isFracciones
                            ? Container(
                                width: 0,
                              )
                            : OutlineLabel(
                                textLabel: "Incertidumbre *",
                                padding: 2.5,
                                child: TextFormField(
                                  initialValue:
                                      '${this._muestra['incertidumbre'] ?? ''}',
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter(
                                        RegExp(r"(\d+)([.]?\d*)?"))
                                  ],
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Ingrese un valor';
                                    }
                                    num numValue = num.tryParse(value);
                                    if (num.tryParse(value) == null) {
                                      return 'Ingrese un número valido';
                                    }
                                    if (numValue < 0) {
                                      return 'Ingrese un número valido';
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    this._muestra['incertidumbre'] =
                                        num.tryParse(value);
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: false, decimal: true),
                                ),
                              ),
                      ],
                    )),
                isFracciones
                    ? RaisedButton(
                        child: Text(
                          "Fracciones",
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (this._formKey.currentState.validate()) {
                            setState(() {
                              _saving = true;
                            });
                            this._formKey.currentState.save();
                            this._muestra["estado"] =
                                this._muestra["estado"] == 0
                                    ? 1
                                    : this._muestra["estado"];
                            await this
                                .widget
                                .muestra
                                .reference
                                .setData(this._muestra, merge: true);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListadoFraccionesPage(
                                        usuario: this.widget.usuario,
                                        aparato: this.widget.aparato,
                                        muestra: this.widget.muestra,
                                        eliminable: this.widget.eliminable,
                                      )),
                            );
                            setState(() {
                              _saving = false;
                            });
                            Navigator.of(context).pop(
                                "Se ha actualizado la muestra y/o sus fracciones");
                          }
                        },
                      )
                    : RaisedButton(
                        child: Text(
                          "Guardar",
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (this._formKey.currentState.validate()) {
                            setState(() {
                              _saving = true;
                            });
                            this._formKey.currentState.save();
                            this._muestra["estado"] = 2;
                            await this
                                .widget
                                .muestra
                                .reference
                                .setData(this._muestra, merge: true);
                            setState(() {
                              _saving = false;
                            });
                            Navigator.of(context)
                                .pop("Se ha actualizado la muestra");
                          }
                        },
                      ),
                this.widget.eliminable
                    ? RaisedButton(
                        child: Text(
                          deleteCount == 3
                              ? "Eliminar"
                              : (deleteCount == 2
                                  ? "¿Seguro?"
                                  : "¿Seguro seguro?"),
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        color: Colors.red,
                        onPressed: () async {
                          if (deleteCount > 1) {
                            setState(() {
                              deleteCount -= 1;
                            });
                          } else {
                            await this.widget.muestra.reference.delete();
                            Navigator.of(context)
                                .pop("Se ha eliminado la muestra");
                          }
                        },
                      )
                    : Divider()
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
