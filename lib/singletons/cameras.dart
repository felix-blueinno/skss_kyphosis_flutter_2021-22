import 'package:camera/camera.dart';

class Cameras {
  Cameras._privateConstructor();
  static final Cameras _instance = Cameras._privateConstructor();

  List<CameraDescription> _cams = [];

  static Cameras get instance => _instance;

  get cams => _cams;
  set cams(cams) => _cams = cams;
}
