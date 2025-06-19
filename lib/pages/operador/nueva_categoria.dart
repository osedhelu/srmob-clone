import 'package:araee/model/Usuario.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_color/random_color.dart';

class NuevoAparatoPage extends StatefulWidget {
  final Usuario usuario;
  final DocumentSnapshot gestor;

  NuevoAparatoPage({Key key, this.usuario, this.gestor}) : super(key: key);

  @override
  State<NuevoAparatoPage> createState() => new _NuevoAparatoPageState();
}

class _NuevoAparatoPageState extends State<NuevoAparatoPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  final RandomColor _randomColor = RandomColor();

  String _nombre = "";

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Solicitar nuevo RAEE"),
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
                        textLabel: "Nombre *",
                        child: TextFormField(
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
                    "Enviar solicitud",
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
                    await Firestore.instance
                        .collection("solicitudes")
                        .document()
                        .setData({
                      "nombre": this._nombre,
                      "gestor": this.widget.gestor.documentID,
                      "solicita": this.widget.usuario.id,
                      'fechaHora': DateTime.now(),
                      'estado': 'creada'
                    });
                    setState(() {
                      _saving = false;
                    });
                    var message =
                        "Se ha envíado su solicitud de adición de nuevo RAEE";
                    Navigator.of(context).pop(message);
                  },
                ),
                RaisedButton(
                  elevation: 5,
                  color: Theme.of(context).primaryColor,
                  child: AutoSizeText(
                    "Cancelar",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
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
