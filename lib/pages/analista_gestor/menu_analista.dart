import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/model/Usuario.dart';
import 'package:araee/pages/password.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuAnalistaPage extends StatelessWidget {
  final Usuario usuario;

  MenuAnalistaPage({Key key, this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SecurityBloc securityBloc = AppBlocProvider.securityBlocOf(context);
    return Drawer(
        child: ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            "${usuario.gestor['razonSocial']} (${usuario.rol})",
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
          accountEmail: Text(usuario.email),
        ),
        ListTile(
          leading: new Icon(FontAwesomeIcons.listAlt),
          title: new Text('Analisis'),
          onTap: () {
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
          },
        ),
        ListTile(
          leading: new Icon(FontAwesomeIcons.key),
          title: new Text('Cambio de contraseña'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PasswordChangePage()),
            );
          },
        ),
        ListTile(
          leading: new Icon(Icons.exit_to_app),
          title: new Text('Cerrar sesión'),
          onTap: () async {
            await securityBloc.logout();
            Navigator.popUntil(context, ModalRoute.withName("/"));
          },
        ),
        Divider(),
        AboutListTile(
          icon: Icon(Icons.info_outline),
          applicationLegalese: 'EcoComputo',
          applicationIcon: Image(
            image: AssetImage('assets/icons/icon.png'),
            width: 60.0,
            height: 60.0,
            color: null,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
          ),
          applicationVersion: '3.0.3',
        )
      ],
    ));
  }
}
