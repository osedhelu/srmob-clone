
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FirebaseTypeAheadField extends StatefulWidget{

  final String initialValue;

  final String coleccion;
  
  final bool canAdd;

  final FormFieldSetter<String> onSaved;

  final FormFieldValidator<String> validator;

  FirebaseTypeAheadField({Key key, this.initialValue, this.coleccion, this.canAdd = true, this.onSaved, this.validator}) : super(key: key);

  @override
  State<FirebaseTypeAheadField> createState() => new _FirebaseTypeAheadFieldState();
}

class _FirebaseTypeAheadFieldState extends State<FirebaseTypeAheadField>{ 

  final TextEditingController _typeAheadController = TextEditingController();

  final TextEditingController _dialogTextController = TextEditingController();

  bool isValidated = false;

  @override
  void initState(){    
    this._dialogTextController.text = widget.initialValue;
    this._typeAheadController.text = widget.initialValue;
    isValidated = false;
    super.initState();
  }

  Future<String> _showAddDialog(BuildContext context){    
    return showDialog<String>(
      context: context,
      builder: (BuildContext dContext){
        return AlertDialog(
          title: Text("Agregar al listado"),
          content: TextField(
            controller: _dialogTextController,            
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text("Guardar", style: Theme.of(context).textTheme.button,),
              color: Theme.of(dContext).primaryColor,
              onPressed: (){
                if( _dialogTextController.text.isNotEmpty ){                  
                  Firestore.instance.collection(widget.coleccion).add({
                    'nombre': _dialogTextController.text
                  });
                  setState(() {
                    this._typeAheadController.text = _dialogTextController.text;
                    _dialogTextController.text = '';
                  });
                }
                Navigator.of(dContext).pop();                
              },
            ),            
            RaisedButton(
              child: Text("Cancelar", style: Theme.of(context).textTheme.button,),
              onPressed: (){
                Navigator.of(dContext).pop();                
              },
            ),            
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(widget.coleccion).orderBy("nombre").snapshots(),
      builder: (BuildContext cContext, AsyncSnapshot<QuerySnapshot> cSnapshot) {
        if( cSnapshot.hasData && cSnapshot.data != null ){          
          String value = ( _typeAheadController.value == TextEditingValue.empty ) ? null : _typeAheadController.text;
          if( !isValidated ){
            if( value != null && cSnapshot.data.documents.where((DocumentSnapshot item) {return item['nombre'] == value;}).length != 1 ){
              value = null;
            }
            isValidated = true;
          }          
          DropdownButtonFormField<String> dropDownField = DropdownButtonFormField<String>(  
            decoration: InputDecoration(
              errorStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.red),
            ),            
            isDense: true,                        
            value: value,
            items: cSnapshot.data.documents.map(
              (DocumentSnapshot documentSnapshot) {
                return DropdownMenuItem<String>(
                  value: documentSnapshot['nombre'],
                  child: Text( documentSnapshot['nombre'], softWrap: true),
                );
              }
            ).toList(),
            validator: (String value){
              print("validatoooor.... $value");
              if( this.widget.validator != null ){
                print("validatoooor....2 $value");
                return this.widget.validator(value);
              }
              return null;
            },
            onSaved: (String value){
              if( this.widget.onSaved != null ){
                this.widget.onSaved(value);
              }
            },
            onChanged: (String newValue){
              print("xxxxxx.... $newValue");
              setState(() {
                this._typeAheadController.text = newValue;
              });                  
            },
          );
          if( this.widget.canAdd ){
            return Stack(              
              fit: StackFit.loose,
              children: <Widget>[
                dropDownField,              
                Positioned(
                  right: -10,
                  bottom: 16,
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.plus, size: 24.0,),
                    onPressed: (){
                      _showAddDialog(cContext);
                    },
                  ),
                )
              ],
            );
          }
          else{
            return dropDownField;
          }
          
        }
        return SpinKitThreeBounce(color: Theme.of(context).primaryColor);
      },
    );
  }
  
}