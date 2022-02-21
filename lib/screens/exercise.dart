import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/constant/routes.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../constant/stages.dart';
import '../singletons/cameras.dart';
import 'stage_painter.dart';

class Exercise extends StatefulWidget {
  const Exercise({Key? key}) : super(key: key);

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  int cameraIndex = 0;
  late CameraController _cameraController;

  late double imgHeight;
  late double imgWidth;
  final List<PoseLandmark> _landmarks = [];
  bool _imgProcessing = false;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initCamera(cameraIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.blue[600],
      body: _cameraInitialized
          ? Center(
              child: SizedBox(
                height: double.infinity,
                child: CustomPaint(
                  foregroundPainter: PosePainter(
                      context,
                      Cameras.instance.cams[cameraIndex],
                      imgHeight,
                      imgWidth,
                      _landmarks),
                  child: CameraPreview(_cameraController),
                ),
              ),
            )
          : const Center(child: SpinKitCubeGrid(color: Colors.blue)),
    );
  }

  AppBar buildAppBar() {
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text("相機 ${index + 1}",
                            style: const TextStyle(color: Colors.white))),
                  ))),
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
              if (Stages.currentStage == Stages.exercise1) {
                Stages.currentStage = Stages.exercise2Instruction;
                Navigator.pushReplacementNamed(
                    context, Routes.exerciseInstruction);
              } else if (Stages.currentStage == Stages.exercise2) {
                Navigator.pushReplacementNamed(context, Routes.complete);
              }
            },
            icon: const Icon(Icons.arrow_forward))
      ],
    );
  }

  void initCamera(int cameraIndex) {
    _cameraController = CameraController(
        Cameras.instance.cams[cameraIndex], ResolutionPreset.max);

    _cameraController.initialize().then((_) {
      _cameraInitialized = true;
      return _cameraController.startImageStream(processCameraImage);
    });
  }

  void processCameraImage(CameraImage cameraImage) async {
    if (_imgProcessing) {
      return;
    }
    _imgProcessing = true;

    final camera = Cameras.instance.cams[cameraIndex]; // your camera instance
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    imgHeight = cameraImage.height.toDouble();
    imgWidth = cameraImage.width.toDouble();

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.NV21;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    final poseDetector = GoogleMlKit.vision.poseDetector(
        poseDetectorOptions: PoseDetectorOptions(
            model: PoseDetectionModel.accurate,
            mode: PoseDetectionMode.streamImage));
    final List<Pose> poses = await poseDetector.processImage(inputImage);
//     print('poses.length: ${poses.length}');

    _landmarks.clear();
    for (Pose pose in poses) {
      // to access all landmarks
      pose.landmarks.forEach((_, landmark) {
        _landmarks.add(landmark);
      });
    }

    _imgProcessing = false;

    if (Stages.currentStage == Stages.exercise1Completed) {
      Stages.currentStage = Stages.exercise2Instruction;
      Navigator.pushReplacementNamed(context, Routes.exerciseInstruction);
    } else if (Stages.currentStage == Stages.exercise2Completed) {
      Stages.currentStage = Stages.sessionCompleted;
      Navigator.pushReplacementNamed(context, Routes.complete);
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();

    _cameraController.dispose();
  }
}
