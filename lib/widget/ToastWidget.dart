import 'package:flutter/material.dart';

class ToastWidget extends StatelessWidget {
  final String title;
  final String description;

  const ToastWidget({this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Card(
        elevation: 10.0,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: EdgeInsets.all(7.5),
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.black),
                    softWrap: true,
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyText1,
                  softWrap: true,
                )),
          ],
        ),
      ),
    );
    /*
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            /*width: 300.0,
            height: 300.0,*/
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.display1.copyWith(color: Colors.black),                  ,
                  softWrap: true,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.body1.copyWith(color: Colors.black),
                  softWrap: true,
                )
              ],
            ),
          ),
        ),
      ),
    );*/
  }
}
