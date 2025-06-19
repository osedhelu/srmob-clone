import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String id;

  String email;

  String rol;

  bool ppmBr;

  DocumentSnapshot gestor;

  Usuario({
    this.id,
    this.email,
    this.rol,
    this.gestor,
    this.ppmBr,
  });
}
