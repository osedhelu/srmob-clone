import 'package:araee/widget/FirebaseTypeAheadField.dart';
import 'package:araee/widget/OutlineLabel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_color/random_color.dart';

class EditarFraccionPage extends StatefulWidget{    
    
    final DocumentSnapshot aparato;
    
    final DocumentSnapshot analisis;
    
    final DocumentSnapshot fraccion;

    EditarFraccionPage({Key key, this.aparato, this.analisis, this.fraccion}) : super(key: key);

    @override
    State<EditarFraccionPage> createState() => new _EditarFraccionPageState();
}

class _EditarFraccionPageState extends State<EditarFraccionPage>{

  final _formKey = GlobalKey<FormState>();

  bool editable;
    
  Map<String,dynamic> _fraccion;

  final RandomColor _randomColor = RandomColor();

  bool _saving = false;
  
  @override
  void initState() {  
    _fraccion = new Map<String,dynamic>();        
    _fraccion['color'] = this.widget.fraccion['color'];
    _fraccion['plastico'] = this.widget.fraccion['plastico'];    
    _fraccion['peso'] = this.widget.fraccion['peso'];
    super.initState();
  }  

  Color _getColor( String grupo ){
    switch( grupo ){
      case 'LIBRE':{
        return Colors.green;
      }break;
      case 'SOSPECHOSO':{
        return Colors.blue;
      }break;
      case 'CONTAMINADO':{
        return Colors.red;
      }break;
      default:{
        return Colors.grey;
      }break;
    }
  } 

  @override
  Widget build(BuildContext context) {
    String grupo  = this.widget.aparato.data['grupos'][this.widget.analisis.data['color']];
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.fraccion['id']),
      ),
      backgroundColor: _getColor( grupo ),
      body: ModalProgressHUD(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(2.5),
            children: <Widget>[
              GridView.extent(               
                shrinkWrap: true,
                physics: ScrollPhysics(),
                maxCrossAxisExtent: 600,
                childAspectRatio: 4.6,
                children: <Widget>[            
                  OutlineLabel(
                    textLabel: "Tipo de plástico",
                    padding: 2.5,
                    child: FirebaseTypeAheadField(   
                      canAdd: false,
                      initialValue: '${_fraccion['plastico']??''}',
                      coleccion: "plasticos",          
                      validator: (String value){                             
                        return null;
                      },                      
                      onSaved: (String value){
                        _fraccion['plastico'] = value;
                      },          
                    ),
                  ),
                  OutlineLabel(
                    textLabel: "Color",
                    padding: 2.5,
                    child: DropdownButtonFormField<String>(                 
                        isDense: true,
                        value: _fraccion['color'],
                        items: ["BLANCO","NEGRO","OTROS"].map(
                          (String color) {
                            return DropdownMenuItem<String>(
                              value: color,
                              child: Text( color, ),
                            );
                          }
                        ).toList(),            
                        validator: (value){                                
                          return null;
                        },
                        onSaved: (String value){
                          _fraccion['color'] = value;
                        },         
                        onChanged: (String newValue){
                          setState(() {
                            _fraccion['color'] = newValue;
                          });                  
                        },
                      )
                  ),
                  OutlineLabel(
                    textLabel: "Peso (g)",
                    padding: 2.5,
                    child: TextFormField(   
                        initialValue: '${_fraccion['peso'] ?? ''}',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"(\d+)([.]?\d*)?")),
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return null;
                          }
                          num numValue = num.tryParse(value);
                        if( num.tryParse(value) == null ){
                          return 'Ingrese un número valido';
                        }
                        if( numValue < 0 ){
                          return 'Ingrese un número valido';
                        }                      
                        return null;
                      },
                      onSaved: (String value){
                        _fraccion['peso'] = num.tryParse(value);
                      },
                      keyboardType: TextInputType.numberWithOptions(signed:false, decimal:false),
                      autofocus: true,
                    ),
                  ),                                                
                ],
              ),
              RaisedButton(
                child: Text("Guardar"),
                onPressed: () async {
                  if( _formKey.currentState.validate() ){
                    setState(() {
                      _saving = true;
                    });
                    _formKey.currentState.save();
                    await this.widget.fraccion.reference.updateData(_fraccion);
                    //setState(() {
                    //  _saving = false;
                    //});
                    Navigator.of(context).pop("Se han almacenado los datos de la fracción");
                  }
                },
              )
            ],
          )
        ),
        inAsyncCall: _saving,
        color: _randomColor.randomColor(),
        progressIndicator: SpinKitWave(color: _randomColor.randomColor(), size: 75,),
      ),      
    );
  }

}