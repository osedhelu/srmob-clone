import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class StatefulRaisedButton extends StatefulWidget{

  final double elevation;
  final Color color;
  final Widget child;
  final VoidCallback onPressed;

  StatefulRaisedButton({Key key, this.child, this.onPressed, this.elevation, this.color}) : super(key: key);

  @override
  State<StatefulRaisedButton> createState() => new _StatefulRaisedButtonState();
}

class _StatefulRaisedButtonState extends State<StatefulRaisedButton>/* with TickerProviderStateMixin*/{

  bool loading = false;

  @override
  void initState(){    
    super.initState();
  }

  @override
  void dispose(){
    this.loading = false;
    super.dispose();
  }

  void _onPressed() async{
    setState(() {
      print("setting to true");
      this.loading = true; 
    });
    Future.delayed(const Duration(milliseconds: 400), (){
      try{
        this.widget.onPressed();
        Future.delayed(const Duration(milliseconds: 600), (){
          if(this.loading){
            setState(() {
              print("setting to false");
              this.loading = false;
            });
          }        
        });
      }
      catch(e){
        setState(() {
          print("setting to false because $e");
          this.loading = false;
        });
      }
    });        
    
  }

  Widget _buildChild(){
    return ( 
      this.loading 
      ? SpinKitThreeBounce(color: Colors.white, size: 25,) 
      : this.widget.child 
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build with $loading");
    return RaisedButton(
      elevation: widget.elevation,
      color: widget.color,
      child: _buildChild(),
      onPressed: () => _onPressed(),
    );
  }

}