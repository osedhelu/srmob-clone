import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/bloc/VersionBloc.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:araee/widget/StatefulRaisedButton.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{

    @override
    State<LoginPage> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  String username;

  String password;

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) { 
    SecurityBloc securityBloc = AppBlocProvider.securityBlocOf(context);   
    VersionBloc versionBloc = AppBlocProvider.versionBlocOf(context);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Smart RAEE")
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
          shrinkWrap: true,          
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Ingreso",style: Theme.of(context).textTheme.display1,),
            ),  
            Divider(),                       
            GridView.extent(               
              shrinkWrap: true,
              physics: ScrollPhysics(),
              maxCrossAxisExtent: 500,
              childAspectRatio: 4.6,
              children: <Widget>[                                                       
                OutlineLabel(
                  textLabel: "Usuario",
                  padding: 2.5,
                  child: TextFormField(              
                    validator: (value){
                      if( value.isEmpty ){
                        return 'Ingrese un valor';
                      }
                      return null;
                    },
                    onSaved: (String value){
                      this.username = value;
                    },
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                OutlineLabel(
                  textLabel: "Contraseña",
                  padding: 2.5,
                  child: TextFormField(
                    validator: (value){
                      if( value.isEmpty ){
                        return 'Ingrese un valor';
                      }
                      return null;
                    },
                    onSaved: (String value){
                      this.password = value;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                ),
              ]
            ),
            StatefulRaisedButton(
              child: Text("Ingresar", style: Theme.of(context).textTheme.button,),
              onPressed: () async{              
                if(_formKey.currentState.validate()){
                  _formKey.currentState.save();                  
                  securityBloc.login(username, password).catchError(
                    ( error ){
                      print("Error... $error");
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                            "El usuario o la contraseña son incorrectos, revise estos datos y el estado de la conexión a internet e intente nuevamente.", 
                            style: Theme.of(context).textTheme.body1.copyWith(color: Theme.of(context).errorColor),
                            textAlign: TextAlign.justify,
                          ),
                          duration: Duration(seconds: 5),
                        )
                      );
                    }
                  ); 
                }
              },
            ),
            FutureBuilder<String>(
              future: versionBloc.getCurrentVersion(), 
              builder: (BuildContext cvContext, AsyncSnapshot<String> cvSnapshot) {
                if( cvSnapshot.hasData && cvSnapshot.data != null ){
                  return Text("Version: ${cvSnapshot.data}", textAlign: TextAlign.right,);
                }
                return Text("");
              }
            ),
          ],
        ),
      ) 
    );
  }

}