import 'package:araee/pages/analista/listado_gestores.dart';
import 'package:araee/pages/analista_gestor/listado_muestras.dart';
import 'package:araee/pages/login.dart';
import 'package:araee/pages/operador/listado_aparatos.dart';
import 'package:araee/pages/otro/no_disponible.dart';
import 'package:araee/provider/AppBlocProvider.dart';
import 'package:araee/widget/WaitingWidget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:araee/widget/ToastWidget.dart';
import 'package:oktoast/oktoast.dart';

String fcmKey;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
// 0xFF067a82
//Verde oscuro 0xFF296f37
//Verde claro  0xFF8FC73E
//Azul         0xFF3C8291 0xFF067a82

class MyApp extends StatelessWidget {
  final noDisponiblePage = NoDisponiblePage();
  final loginPage = LoginPage();

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  MyApp({Key key}) : super(key: key) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => _onMessage(message),
      onResume: (Map<String, dynamic> message) => _onMessage(message),
      onLaunch: (Map<String, dynamic> message) => _onMessage(message),
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      fcmKey = token;
    });
  }

  _onMessage(Map<String, dynamic> message) {
    print("Llego un mensaje: $message");
    showToastWidget(
        ToastWidget(
            title: message['notification']['title'],
            description: message['notification']['body']),
        duration: Duration(seconds: 5));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: AppBlocProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart RAEE',
          locale: Locale('es', ''),
          theme: ThemeData(
              primaryColor: Color(0xFF3C8291),
              buttonColor: Color(0xFF067a82),
              accentColor: Color(0xFFb0b5a4), //Este es el que no gusto!!
              fontFamily: 'Helvetica Neue',
              textTheme: TextTheme(
                headline1: Theme.of(context)
                    .textTheme
                    .headline1
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                headline2: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                headline3: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                headline4: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                headline5: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                headline6: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                bodyText1: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                bodyText2: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 20.0),
                caption: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontWeight: FontWeight.w500),
                button: Theme.of(context).textTheme.button.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                    color: Colors.white),
              )),
          home: StreamBuilder<FirebaseUser>(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder:
                (BuildContext uContext, AsyncSnapshot<FirebaseUser> uSnapshot) {
              //
              if (uSnapshot.hasData && uSnapshot.data != null) {
                return FutureBuilder<IdTokenResult>(
                  future: uSnapshot.data.getIdToken(),
                  builder: (BuildContext u2Context,
                      AsyncSnapshot<IdTokenResult> u2Snapshot) {
                    if (u2Snapshot.hasData && u2Snapshot.data != null) {
                      try {
                        AppBlocProvider.versionBlocOf(u2Context)
                            .verifyVersion();
                      } catch (_) {
                        print("is not working!!!");
                      }
                      switch (u2Snapshot.data.claims['rol']) {
                        case 'OPERADOR':
                          {
                            return new ListadoAparatosPage();
                          }
                          break;
                        case 'ANALISTA':
                          {
                            if (u2Snapshot.data.claims.containsKey("gestor") &&
                                u2Snapshot.data.claims['gestor'] != null &&
                                u2Snapshot.data.claims['gestor'].isNotEmpty) {
                              return ListadoMuestrasPage();
                            }
                            return new ListadoGestoresPage();
                          }
                          break;
                        default:
                          {
                            return noDisponiblePage;
                          }
                      }
                    }
                    return WaitingWidget(message: "Cargando perfil de usuario");
                  },
                );
              }
              if (uSnapshot.connectionState != ConnectionState.active) {
                return WaitingWidget(
                    message: "Cargando información de usuario");
              } else {
                return loginPage;
              }
            },
          ),
          initialRoute: "/",
        ),
      ),
    );
  }
}
