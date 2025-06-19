import 'package:araee/bloc/SecurityBloc.dart';
import 'package:araee/bloc/VersionBloc.dart';
import 'package:flutter/widgets.dart';


class AppBlocProvider extends InheritedWidget{

  final SecurityBloc securityBloc = new SecurityBloc();

  final VersionBloc   versionBloc = new VersionBloc();

  AppBlocProvider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static SecurityBloc securityBlocOf(BuildContext context) =>(context.dependOnInheritedWidgetOfExactType<AppBlocProvider>()).securityBloc;

  static VersionBloc versionBlocOf(BuildContext context) => (context.dependOnInheritedWidgetOfExactType<AppBlocProvider>()).versionBloc;

}