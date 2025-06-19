import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoDisponiblePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart RAEE - No disponible"),
      ),
      body: ListView(
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          Text(
            "Uppps!!",
            style: Theme.of(context).textTheme.headline4,
          ),
          Divider(
            height: 50,
          ),
          Text(
            "Su perfil de usuario no fue diseñado para la aplicación movil, debe acceder por medio de la web. Contacte a su administrador para más información",
            textAlign: TextAlign.justify,
          ),
          Divider(),
          RaisedButton(
            child: Text("Salir",
                style: Theme.of(context).textTheme.button.copyWith(
                      color: Colors.white,
                    )),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
    );
  }
}
