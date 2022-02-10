import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_application_1/singletons/cameras.dart';
import 'package:flutter_application_1/singletons/pose_marks.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../constant/routes.dart';
import '../constant/stages.dart';
import 'stage_painter.dart';

class PostureDetection extends StatefulWidget {
  const PostureDetection({Key? key}) : super(key: key);

  @override
  _PostureDetectionState createState() => _PostureDetectionState();
}

class _PostureDetectionState extends State<PostureDetection> {
  int cameraIndex = 0;

  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  final List<PoseLandmark> _landmarks = [];
  late double imgHeight;
  late double imgWidth;
  late File imgFile;

  @override
  Widget build(BuildContext context) {
    if (Stages.currentStage == Stages.checkInstruction) {
      return buildInstructionWidget(context);
    } else {
      return Scaffold(
        appBar: buildAppBar(context),
        backgroundColor: Colors.blue[100],
        body: _landmarks.isEmpty
            ? FutureBuilder(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Center(
                      child: SizedBox(
                          height: double.infinity,
                          child: CameraPreview(_cameraController)),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            : resultDrawingDialog(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
            int countdown = 3;
            showAnimatedDialog(
                context: context,
                builder: (context) =>
                    StatefulBuilder(builder: ((context, innerSetState) {
                      Timer.periodic(const Duration(seconds: 1), (timer) async {
                        innerSetState(() =>
                            countdown >= 0 ? countdown -= 1 : timer.cancel());

                        if (countdown == 0) {
                          timer.cancel();
                          Navigator.of(context).pop();
                          final image = await _cameraController.takePicture();

                          InputImage inputImage =
                              InputImage.fromFilePath(image.path);
                          imgFile = File(image.path);
                          final decodedImage = await decodeImageFromList(
                              imgFile.readAsBytesSync());

                          imgHeight = decodedImage.height.toDouble();
                          imgWidth = decodedImage.width.toDouble();

                          PoseDetector poseDetector =
                              GoogleMlKit.vision.poseDetector();
                          List<Pose> poses =
                              await poseDetector.processImage(inputImage);

                          _landmarks.clear();
                          for (Pose pose in poses) {
                            // to access all landmarks
                            pose.landmarks.forEach((_, landmark) {
                              _landmarks.add(landmark);
                            });
                          }
                          setState(() {});
                        }
                      });

                      return AlertDialog(
                        title: Text('$countdown'),
                      );
                    })));
          },
          child: const Icon(Icons.camera),
        ),
      );
    }
  }

  Center resultDrawingDialog(BuildContext context) {
    return Center(
      child: VisibilityDetector(
        key: const Key('posture_check_key'),
        onVisibilityChanged: (visibilityInfo) {
          log('visibilityInfo: ${visibilityInfo.visibleFraction} of child widget is visible');

          if (visibilityInfo.visibleFraction == 0) return;

          double earShoulder = PoseMarks.instance.earShoulderAngle;
          double shoulderHip = PoseMarks.instance.shoulderHipAngle;
          double hipAnkle = PoseMarks.instance.hipAnkleAngle;

          String title = '姿勢正確';
          String content = '''
耳朵與肩膀之間的角度： ${earShoulder.toStringAsFixed(2)}°,
肩膀與臀部之間的角度： ${shoulderHip.toStringAsFixed(2)}°,
臀部與腳踝之間的角度： ${hipAnkle.toStringAsFixed(2)}°
''';

          if (earShoulder != 360 && shoulderHip != 360 && hipAnkle != 360) {
            // Decides displaying messages:
            if (earShoulder > 20) {
              title = '姿勢不正確';
            } else if (earShoulder <= 10 && shoulderHip < 10) {
              title = '姿勢正確';
            }
            showAnimatedDialog(
                context: context,
                builder: (innerContext) => AlertDialog(
                      title: Text(title),
                      content: Text(content),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(innerContext)
                                .popUntil(
                                    ModalRoute.withName(Routes.dashboard)),
                            child: const Text('返回')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(innerContext).pop();
                              setState(() => _landmarks.clear());
                            },
                            child: const Text('重試')),
                        ElevatedButton(
                            onPressed: () {
                              Stages.currentStage = Stages.exercise1Instruction;
                              Navigator.of(innerContext).pushReplacementNamed(
                                  Routes.exerciseInstruction);
                            },
                            child: const Text('運動'))
                      ],
                    ));
          }
        },
        child: CustomPaint(
            child: Image.file(imgFile),
            foregroundPainter: PosePainter(
              context,
              Cameras.instance.cams[cameraIndex],
              imgWidth,
              imgHeight,
              _landmarks,
            )),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("偵測站姿"),
      centerTitle: true,
      actions: [
        DropdownButton(
          dropdownColor: Colors.blue[600],
          items: List.generate(
              Cameras.instance.cams.length,
              (index) => DropdownMenuItem(
                  value: index,
                  child: Center(
                      child: Text("相機 ${index + 1}",
                          style: const TextStyle(color: Colors.white))))),
          onChanged: (newValue) {
            cameraIndex = newValue as int;
            initCamera(cameraIndex);
            setState(() {});
          },
          value: cameraIndex,
          icon: const Icon(
            Icons.arrow_drop_down_outlined,
            color: Colors.white,
          ),
        ),
        IconButton(
            onPressed: () {
              Stages.currentStage = Stages.exercise1Instruction;
              Navigator.of(context)
                  .pushReplacementNamed(Routes.exerciseInstruction);
            },
            icon: const Icon(Icons.arrow_forward))
      ],
    );
  }

  Scaffold buildInstructionWidget(BuildContext context) {
    return Scaffold(
        body: AlertDialog(
      title: const Text(
        "寒背評估",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("1.放鬆雙臂，垂直站立。"),
          SizedBox(height: 8),
          Text("2.使用者與手機鏡頭保持約兩米距離。"),
        ],
      ),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.of(context)
                .popUntil(ModalRoute.withName(Routes.dashboard)),
            child: const Text("返回")),
        ElevatedButton(
            onPressed: () => setState(() => Stages.currentStage = Stages.check),
            child: const Text("繼續")),
      ],
    ));
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initCamera(cameraIndex);
  }

  @override
  void dispose() {
    super.dispose();

    _cameraController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  initCamera(int cameraIndex) {
    _cameraController = CameraController(
        Cameras.instance.cams[cameraIndex], ResolutionPreset.max);

    _initializeControllerFuture = _cameraController.initialize();
  }
}
