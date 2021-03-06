import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_application_1/helper/logger.dart';
import 'package:flutter_application_1/singletons/cameras.dart';
import 'package:flutter_application_1/singletons/pose_marks.dart';
import 'package:flutter_application_1/singletons/record.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
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
                  return snapshot.connectionState == ConnectionState.done
                      ? Center(
                          child: SizedBox(
                              height: double.infinity,
                              child: CameraPreview(_cameraController)))
                      : const Center(child: CircularProgressIndicator());
                },
              )
            : resultDrawingDialog(context),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Pick image for detection:
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                // Pick an image
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  List<Pose> poses = await analyzePose(image.path);

                  _landmarks.clear();
                  for (Pose pose in poses) {
                    // to access all landmarks
                    pose.landmarks.forEach((_, landmark) {
                      _landmarks.add(landmark);
                    });
                  }
                  setState(() {});
                }
              },
              child: const Icon(Icons.photo),
            ),
            const SizedBox(height: 16),

            // Take picture in 3 sec count down:
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;
                int countdown = 3;
                showAnimatedDialog(
                    context: context,
                    builder: (context) =>
                        StatefulBuilder(builder: ((context, innerSetState) {
                          Timer.periodic(const Duration(seconds: 1),
                              (timer) async {
                            innerSetState(() => countdown >= 0
                                ? countdown -= 1
                                : timer.cancel());

                            if (countdown == 0) {
                              timer.cancel();

                              Navigator.of(context).pop();

                              final image =
                                  await _cameraController.takePicture();
                              List<Pose> poses = await analyzePose(image.path);

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

                          return AlertDialog(title: Text('$countdown'));
                        })));
              },
              child: const Icon(Icons.camera),
            ),
          ],
        ),
      );
    }
  }

  Center resultDrawingDialog(BuildContext context) {
    return Center(
      child: VisibilityDetector(
        key: const Key('posture_check_key'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0) return;

          double earShoulder = PoseMarks.instance.earShoulderAngle;
          double shoulderHip = PoseMarks.instance.shoulderHipAngle;
          double hipAnkle = PoseMarks.instance.hipAnkleAngle;

          if (earShoulder != 360 && shoulderHip != 360 && hipAnkle != 360) {
            // Decides displaying messages:
            String title = (earShoulder > 20) ? '???????????????' : '????????????';

            String content = '''
????????????????????????????????? ${earShoulder.toStringAsFixed(2)}??,
????????????????????????????????? ${shoulderHip.toStringAsFixed(2)}??,
????????????????????????????????? ${hipAnkle.toStringAsFixed(2)}??
''';
            Record.instance.postureCorrect = (earShoulder > 20);
            Record.instance.earShoulder = earShoulder.toStringAsFixed(2);
            Record.instance.shoulderHip = shoulderHip.toStringAsFixed(2);
            Record.instance.hipAnkle = hipAnkle.toStringAsFixed(2);
            Logger.log(Record.instance.hipAnkle);

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
                            child: const Text('??????')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(innerContext).pop();
                              setState(() => _landmarks.clear());
                            },
                            child: const Text('??????')),
                        ElevatedButton(
                            onPressed: () {
                              Stages.currentStage = Stages.exercise1Instruction;
                              Navigator.of(innerContext).pushReplacementNamed(
                                  Routes.exerciseInstruction);
                            },
                            child: const Text('??????'))
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
      title: const Text("????????????"),
      centerTitle: true,
      actions: [
        DropdownButton(
          dropdownColor: Colors.blue[600],
          items: List.generate(
              Cameras.instance.cams.length,
              (index) => DropdownMenuItem(
                  value: index,
                  child: Center(
                      child: Text("?????? ${index + 1}",
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
        "????????????",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("1.??????????????????????????????"),
          SizedBox(height: 8),
          Text("2.????????????????????????????????????????????????"),
        ],
      ),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.of(context)
                .popUntil(ModalRoute.withName(Routes.dashboard)),
            child: const Text("??????")),
        ElevatedButton(
            onPressed: () => setState(() => Stages.currentStage = Stages.check),
            child: const Text("??????")),
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

  Future<List<Pose>> analyzePose(String path) async {
    InputImage inputImage = InputImage.fromFilePath(path);
    imgFile = File(path);
    final decodedImage = await decodeImageFromList(imgFile.readAsBytesSync());

    imgHeight = decodedImage.height.toDouble();
    imgWidth = decodedImage.width.toDouble();

    PoseDetector poseDetector = GoogleMlKit.vision.poseDetector();
    return poseDetector.processImage(inputImage);
  }
}
