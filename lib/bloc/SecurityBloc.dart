import 'package:araee/main.dart';
import 'package:araee/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityBloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Usuario usuario;

  Future<Usuario> login(String username, String password) async {
    AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: username, password: password);
    if (authResult.user != null) {
      return this._getUser(authResult.user);
    }
    return null;
  }

  Future<void> updatePassword(String newPassword) async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      firebaseUser.updatePassword(newPassword);
    }
  }

  Future<bool> getPpmBr() async {
    FirebaseUser firebaseUser = await _auth.currentUser();

    final userBr = await Firestore.instance
        .collection("usuario")
        .document(firebaseUser.uid)
        .get();

    final ppmBr = userBr.data['ppmBr'] ?? false;
    return ppmBr;
  }

  Future<Usuario> getUser() async {
    if (this.usuario == null) {
      FirebaseUser firebaseUser = await _auth.currentUser();
      if (firebaseUser != null) {
        return this._getUser(firebaseUser);
      }
    }
    return this.usuario;
  }

  Future<Usuario> _getUser(FirebaseUser firebaseUser) async {
    IdTokenResult idTokenResult = await firebaseUser.getIdToken();

    if (idTokenResult.claims["fcmKey"] != fcmKey) {
      idTokenResult.claims["fcmKey"] = fcmKey;
    }

    await Firestore.instance
        .collection("usuario")
        .document(firebaseUser.uid)
        .setData({"fcmKey": fcmKey}, merge: true);

    DocumentSnapshot gestor;
    if (idTokenResult.claims.containsKey("gestor") &&
        idTokenResult.claims["gestor"].isNotEmpty) {
      gestor = await Firestore.instance
          .collection("gestor")
          .document(idTokenResult.claims["gestor"])
          .get();
    }

    this.usuario = new Usuario(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      rol: idTokenResult.claims["rol"],
      ppmBr: idTokenResult.claims["ppmBr"],
      gestor: gestor,
    );
    return this.usuario;
  }

  Future<Usuario> logout() async {
    await _auth.signOut();
    this.usuario = null;
    return this.usuario;
  }
}
