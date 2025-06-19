import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CargandoPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Raee - Cargando"),),
      body: Center(
        child: SpinKitThreeBounce(color: Theme.of(context).primaryColor,),
      ),
    );
  }

}