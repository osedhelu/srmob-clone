import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:araee/widget/StatefulRaisedButton.dart';
import 'package:flutter/material.dart';

class PasswordChangePage extends StatefulWidget{

    @override
    State<PasswordChangePage> createState() => new _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChangePage>{

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  String newPassword;

  String conPassword;

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) { 
    SecurityBloc securityBloc = AppBlocProvider.securityBlocOf(context);   
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Cambio de clave"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
          shrinkWrap: true,          
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Cambio de clave",style: Theme.of(context).textTheme.display1,),
            ),          
            Divider(),
            GridView.extent(               
              shrinkWrap: true,
              physics: ScrollPhysics(),
              maxCrossAxisExtent: 600,
              childAspectRatio: 4.6,
              children: <Widget>[                
                OutlineLabel(
                  textLabel: "Nueva contraseña",
                  padding: 2.5,
                  child: TextFormField(
                    validator: (value){
                      if( value.isEmpty ){
                        return 'Ingrese un valor';
                      }
                      return null;
                    },
                    onSaved: (String value){
                      this.newPassword = value;
                    },
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                ),
                OutlineLabel(
                  textLabel: "Confirmar contraseña",
                  padding: 2.5,
                  child: TextFormField(
                    validator: (value){
                      if( value.isEmpty ){
                        return 'Ingrese un valor';
                      }
                      return null;
                    },
                    onSaved: (String value){
                      this.conPassword = value;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                ),
              ]
            ),
            StatefulRaisedButton(
              child: Text("Cambiar contraseña", style: Theme.of(context).textTheme.button,),
              onPressed: () async{              
                if(_formKey.currentState.validate()){
                  _formKey.currentState.save();  
                  if( newPassword == conPassword ){                    
                    securityBloc.updatePassword(newPassword)
                      .then(
                        (_){
                          setState(() {
                            newPassword = "";
                            conPassword = "";                            
                          });
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(
                                "Su contraseña ha sido actualizada correctamente", 
                                style: Theme.of(context).textTheme.body1.copyWith(color: Theme.of(context).accentColor),
                                textAlign: TextAlign.justify,
                              ),
                              duration: Duration(seconds: 5),
                            )
                          );
                          Future
                            .delayed(Duration(seconds:5))
                            .then(
                              (_){
                                Navigator.of(context).pop();
                              }
                            );
                        }
                      )
                      .catchError(
                        (error){
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(
                                "Ocurrio un error inesperado en el cambio de contraseña: $error", 
                                style: Theme.of(context).textTheme.body1.copyWith(color: Theme.of(context).errorColor),
                                textAlign: TextAlign.justify,
                              ),
                              duration: Duration(seconds: 5),
                            )
                          );
                        }
                      );                                        
                  }                
                  else{
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(
                          "La contraseña no coincide con la confirmación.", 
                          style: Theme.of(context).textTheme.body1.copyWith(color: Theme.of(context).errorColor),
                          textAlign: TextAlign.justify,
                        ),
                        duration: Duration(seconds: 5),
                      )
                    );
                  }                  
                }
              },
            )
          ],
        ),
      ) 
    );
  }

}