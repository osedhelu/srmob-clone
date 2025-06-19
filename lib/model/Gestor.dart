

import 'package:cloud_firestore/cloud_firestore.dart';

class Gestor{

  String id;

  String nit;

  String razonSocial;  

  Gestor({this.id, this.nit, this.razonSocial});

  factory Gestor.fromDocumentSnapshot( DocumentSnapshot documentSnapshot ){
    return Gestor(
      id: documentSnapshot['id'],
      nit: documentSnapshot['nit'],
      razonSocial: documentSnapshot['razonSocial']      
    );
  }

}