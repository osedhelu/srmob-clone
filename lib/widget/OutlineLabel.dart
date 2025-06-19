import 'package:flutter/material.dart';

class OutlineLabel extends StatelessWidget {
  final String textLabel;
  final Widget child;
  final double padding;
  final Color backgroundColor;

  OutlineLabel(
      {Key key, this.textLabel, this.child, this.padding, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget retValue = Stack(
      children: <Widget>[
        Positioned(
            right: 1,
            bottom: 0,
            left: 1,
            top: 5,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).textTheme.bodyText1.color),
                ),
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                child: this.child)),
        Positioned(
            left: 5,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              child: this.textLabel != null ? Text(this.textLabel) : null,
            )),
      ],
    );
    if (((this.padding ?? 0.0) > 0.0) || this.backgroundColor != null) {
      return Container(
        margin: this.padding != null ? EdgeInsets.all(this.padding / 2) : null,
        padding: this.padding != null ? EdgeInsets.all(this.padding / 2) : null,
        color: this.backgroundColor != null ? this.backgroundColor : null,
        child: retValue,
      );
    } else {
      return retValue;
    }
  }
}
