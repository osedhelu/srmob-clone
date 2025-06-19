import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitingWidget extends StatelessWidget{

  final String message;

  WaitingWidget({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C8B99),
            Color(0xFF067A82)
          ]
        )
      ), 
      child: Center(
        child: Container(
          width: 300,
          height: 200,
          child: Stack(        
            overflow: Overflow.clip,
            children: <Widget>[          
              Positioned(
                top: 5,            
                left: 0,
                right: 15,            
                child: Text(              
                  message, 
                  style: Theme.of(context).textTheme.display1.copyWith(
                    color: Color(0xFF92C83E),      
                  ),
                  softWrap: true,
                  textAlign: TextAlign.right,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 110,
                child: SpinKitWave(color: Color(0x9900323b), size: 75,),
              )
            ],
          ),
        ),
      )
    );
  }

}