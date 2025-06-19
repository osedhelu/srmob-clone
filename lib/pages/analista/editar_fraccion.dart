import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:araee/widget/FirebaseTypeAheadField.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_color/random_color.dart';

class EditarFraccionPage extends StatefulWidget {
  final DocumentSnapshot aparato;
  final DocumentSnapshot analisis;
  final DocumentSnapshot fraccion;
  final bool eliminable;

  EditarFraccionPage(
      {this.aparato, this.analisis, this.fraccion, this.eliminable});

  @override
  State<EditarFraccionPage> createState() => new _EditarFraccionPageState();
}

class _EditarFraccionPageState extends State<EditarFraccionPage> {
  final _formKey = GlobalKey<FormState>();

  bool editable;

  Map<String, dynamic> _fraccion;

  int deleteCount = 3;

  final RandomColor _randomColor = RandomColor();

  bool _saving = false;

  @override
  void initState() {
    _fraccion = new Map<String, dynamic>();
    _fraccion['color'] = this.widget.fraccion['color'];
    _fraccion['plastico'] = this.widget.fraccion['plastico'];
    _fraccion['pprBr'] = this.widget.fraccion['pprBr'];
    _fraccion['incertidumbre'] = this.widget.fraccion['incertidumbre'];
    _fraccion['peso'] = this.widget.fraccion['peso'];
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

  @override
  Widget build(BuildContext context) {
    SecurityBloc securityBloc = AppBlocProvider.securityBlocOf(context);

    String grupo =
        this.widget.aparato.data['grupos'][this.widget.analisis.data['color']];

    return Scaffold(
        appBar: AppBar(title: Text(this.widget.fraccion['id'])),
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
                      children: <Widget>[
                        OutlineLabel(
                          textLabel: "Tipo de plástico *",
                          padding: 2.5,
                          child: FirebaseTypeAheadField(
                            canAdd: false,
                            initialValue: '${_fraccion['plastico'] ?? ''}',
                            coleccion: "plasticos",
                            validator: (String value) {
                              print("validator tipo de plastico $value");
                              if (value == null || value.isEmpty) {
                                return 'Seleccione un valor';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              _fraccion['plastico'] = value;
                            },
                          ),
                        ),
                        OutlineLabel(
                            textLabel: "Color *",
                            padding: 2.5,
                            child: DropdownButtonFormField<String>(
                              isDense: true,
                              value: _fraccion['color'],
                              items: ["BLANCO", "NEGRO", "OTROS"]
                                  .map((String color) {
                                return DropdownMenuItem<String>(
                                  value: color,
                                  child: Text(
                                    color,
                                  ),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese un valor';
                                }
                                return null;
                              },
                              onSaved: (String value) {
                                _fraccion['color'] = value;
                              },
                              onChanged: (String newValue) {
                                setState(() {
                                  _fraccion['color'] = newValue;
                                });
                              },
                            )),
                        OutlineLabel(
                          textLabel: "Peso (g) *",
                          padding: 2.5,
                          child: TextFormField(
                            initialValue: '${_fraccion['peso'] ?? ''}',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"(\d+)([.]?\d*)?")),
                            ],
                            validator: (value) {
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
                              _fraccion['peso'] = num.tryParse(value);
                            },
                            keyboardType: TextInputType.numberWithOptions(
                              signed: false,
                              decimal: true,
                            ),
                            autofocus: true,
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: securityBloc.getPpmBr(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final ppmBr = snapshot.data;

                              if (!ppmBr) {
                                return SizedBox.shrink();
                              }

                              return OutlineLabel(
                                textLabel: "ppm (Br) *",
                                padding: 2.5,
                                child: TextFormField(
                                  initialValue: '${_fraccion['pprBr'] ?? ''}',
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
                                    _fraccion['pprBr'] = num.tryParse(value);
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                    signed: false,
                                    decimal: true,
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                        FutureBuilder<bool>(
                          future: securityBloc.getPpmBr(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final ppmBr = snapshot.data;

                              if (!ppmBr) {
                                return SizedBox.shrink();
                              }

                              return OutlineLabel(
                                textLabel: "Incertidumbre *",
                                padding: 2.5,
                                child: TextFormField(
                                  initialValue:
                                      '${_fraccion['incertidumbre'] ?? ''}',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r"(\d+)([.]?\d*)?"),
                                    ),
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
                                    _fraccion['incertidumbre'] =
                                        num.tryParse(value);
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: false, decimal: true),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ]),
                  RaisedButton(
                    child: Text("Guardar"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _saving = true;
                        });
                        _formKey.currentState.save();
                        await this
                            .widget
                            .fraccion
                            .reference
                            .updateData(_fraccion);
                        await this
                            .widget
                            .analisis
                            .reference
                            .updateData({'estado': 2});
                        //setState(() {
                        //  _saving = false;
                        //});
                        Navigator.of(context).pop(
                            "Se ha almacenado la información de la fracción");
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
                              await this.widget.fraccion.reference.delete();
                              Navigator.of(context).pop();
                            }
                          },
                        )
                      : Divider()
                ],
              )),
          inAsyncCall: _saving,
          color: _randomColor.randomColor(),
          progressIndicator: SpinKitWave(
            color: _randomColor.randomColor(),
            size: 75,
          ),
        ));
  }
}
