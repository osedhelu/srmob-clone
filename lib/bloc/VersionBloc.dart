import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:araee/widget/ToastWidget.dart';
import 'package:oktoast/oktoast.dart';

class VersionBloc {
  PackageInfo packageInfo;

  Future<int> getCurrentBuild() async {
    if (packageInfo == null) {
      packageInfo = await PackageInfo.fromPlatform();
    }
    return int.tryParse(packageInfo.buildNumber);
  }

  Future<String> getCurrentVersion() async {
    if (packageInfo == null) {
      packageInfo = await PackageInfo.fromPlatform();
    }
    return packageInfo.version;
  }

  DocumentSnapshot versionParam;

  Future<String> getLastVersion() async {
    if (versionParam == null) {
      versionParam = await Firestore.instance
          .collection("parametros")
          .document("version")
          .get();
    }
    return versionParam["version"];
  }

  Future<int> getLastBuild() async {
    if (versionParam == null) {
      versionParam = await Firestore.instance
          .collection("parametros")
          .document("version")
          .get();
    }
    return versionParam["buildNumber"];
  }

  Future<void> verifyVersion() async {
    String currentVersion = await this.getCurrentVersion();
    String lastVersion = await this.getLastVersion();
    //
    int currentBuild = await this.getCurrentBuild();
    int lastBuild = await this.getLastBuild();
    //
    if (currentBuild < lastBuild) {
      showToastWidget(
        ToastWidget(
            title: "Versión desactualizada",
            description:
                "Tu versión $currentVersion de Smart RAEE se encuentra desactualizada, ingresa a la tienda y asegurate de instalar la versión $lastVersion"),
        duration: Duration(seconds: 10),
      );
    } else {
      print(
          "Se ha verificado la versión $currentVersion vs $lastVersion y todo marcha bien");
    }
  }
}
