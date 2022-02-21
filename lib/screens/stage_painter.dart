import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/singletons/pose_marks.dart';
import 'package:flutter_application_1/singletons/exercise_supervisor.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../constant/stages.dart';
import '../helper/logger.dart';

class PosePainter extends CustomPainter {
  late Paint paintL;

  late Paint paintR;

  // Constructor:
  PosePainter(
    this.context,
    this.camera,
    this.cameraImgHeight,
    this.cameraImgWidth,
    this.landmarks,
  );

  // Requried constructor parameters:
  BuildContext context;
  CameraDescription camera;
  double cameraImgHeight;
  double cameraImgWidth;
  List<PoseLandmark> landmarks;

  // States to be draw on screen:
  final List<Offset> _leftPoints = [];
  final List<Offset> _rightPoints = [];

  Offset? leftEar;
  Offset? leftShoulder;
  Offset? leftElbow;
  Offset? leftWrist;
  Offset? leftThumb;
  Offset? leftPinky;
  Offset? leftHip;
  Offset? leftKnee;
  Offset? leftAnkle;

  Offset? rightEar;
  Offset? rightShoulder;
  Offset? rightElbow;
  Offset? rightWrist;
  Offset? rightThumb;
  Offset? rightPinky;
  Offset? rightHip;
  Offset? rightKnee;
  Offset? rightAnkle;

  @override
  void paint(Canvas canvas, Size size) {
    // Prepare pen for drawing left & right parts:
    paintL = _initPaint(Colors.green);
    paintR = _initPaint(Colors.red);

    // Refresh the point lists:
    _leftPoints.clear();
    _rightPoints.clear();

    // Parameters to correct drawing points:
    double widthRatio = cameraImgHeight / size.width;
    double heightRatio = cameraImgWidth / size.height;

    // Process each landmark:
    for (PoseLandmark landmark in landmarks) {
      double x = landmark.x / widthRatio;
      double y = landmark.y / heightRatio;

      // Compensate the mirror effect:
      if (Stages.currentStage != Stages.check &&
          camera.lensDirection == CameraLensDirection.front) {
        x = size.width - x;
      }

      // Refresh the point lists:
      updateStates(landmark.type, x, y);
    }

    // Logic for different stages:
    switch (Stages.currentStage) {
      case Stages.check:
        checkStandPose(canvas);
        break;
      case Stages.exercise1:
        checkExercise1(canvas, size);
        break;
      case Stages.exercise2:
        checkExercise2(canvas, size);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void updateStates(PoseLandmarkType type, double x, double y) {
    // https://developers.google.com/ml-kit/images/vision/pose-detection/landmarks-fixed.png

    // Update lists:
    switch (type) {
      case PoseLandmarkType.leftEyeInner:
      case PoseLandmarkType.leftEye:
      case PoseLandmarkType.leftEyeOuter:
      case PoseLandmarkType.leftEar:
      case PoseLandmarkType.leftShoulder:
      case PoseLandmarkType.leftElbow:
      case PoseLandmarkType.leftWrist:
      case PoseLandmarkType.leftPinky:
      case PoseLandmarkType.leftIndex:
      case PoseLandmarkType.leftThumb:
      case PoseLandmarkType.leftHip:
      case PoseLandmarkType.leftKnee:
      case PoseLandmarkType.leftAnkle:
      case PoseLandmarkType.leftHeel:
      case PoseLandmarkType.leftFootIndex:
        _leftPoints.add(Offset(x, y));
        break;

      case PoseLandmarkType.rightEyeInner:
      case PoseLandmarkType.rightEye:
      case PoseLandmarkType.rightEyeOuter:
      case PoseLandmarkType.rightEar:
      case PoseLandmarkType.rightShoulder:
      case PoseLandmarkType.rightElbow:
      case PoseLandmarkType.rightWrist:
      case PoseLandmarkType.rightPinky:
      case PoseLandmarkType.rightIndex:
      case PoseLandmarkType.rightThumb:
      case PoseLandmarkType.rightHip:
      case PoseLandmarkType.rightKnee:
      case PoseLandmarkType.rightAnkle:
      case PoseLandmarkType.rightHeel:
      case PoseLandmarkType.rightFootIndex:
        _rightPoints.add(Offset(x, y));
        break;
      // Ignore these:
      case PoseLandmarkType.nose:
      case PoseLandmarkType.leftMouth:
      case PoseLandmarkType.rightMouth:
        break;
    }

    // Update points:
    switch (type) {
      case PoseLandmarkType.leftEar:
        leftEar = Offset(x, y);
        break;
      case PoseLandmarkType.leftShoulder:
        leftShoulder = Offset(x, y);
        break;
      case PoseLandmarkType.leftElbow:
        leftElbow = Offset(x, y);
        break;
      case PoseLandmarkType.leftWrist:
        leftWrist = Offset(x, y);
        break;
      case PoseLandmarkType.leftThumb:
        leftThumb = Offset(x, y);
        break;
      case PoseLandmarkType.leftPinky:
        leftPinky = Offset(x, y);
        break;
      case PoseLandmarkType.leftHip:
        leftHip = Offset(x, y);
        break;
      case PoseLandmarkType.leftKnee:
        leftKnee = Offset(x, y);
        break;
      case PoseLandmarkType.leftAnkle:
        leftAnkle = Offset(x, y);
        break;

      case PoseLandmarkType.rightEar:
        rightEar = Offset(x, y);
        break;
      case PoseLandmarkType.rightShoulder:
        rightShoulder = Offset(x, y);
        break;
      case PoseLandmarkType.rightElbow:
        rightElbow = Offset(x, y);
        break;
      case PoseLandmarkType.rightWrist:
        rightWrist = Offset(x, y);
        break;
      case PoseLandmarkType.rightPinky:
        rightPinky = Offset(x, y);
        break;
      case PoseLandmarkType.rightThumb:
        rightThumb = Offset(x, y);
        break;
      case PoseLandmarkType.rightHip:
        rightHip = Offset(x, y);
        break;
      case PoseLandmarkType.rightKnee:
        rightKnee = Offset(x, y);
        break;
      case PoseLandmarkType.rightAnkle:
        rightAnkle = Offset(x, y);
        break;
      case PoseLandmarkType.nose:
      case PoseLandmarkType.leftEyeInner:
      case PoseLandmarkType.leftEye:
      case PoseLandmarkType.leftEyeOuter:
      case PoseLandmarkType.rightEyeInner:
      case PoseLandmarkType.rightEye:
      case PoseLandmarkType.rightEyeOuter:
      case PoseLandmarkType.leftMouth:
      case PoseLandmarkType.rightMouth:
      case PoseLandmarkType.leftIndex:
      case PoseLandmarkType.rightIndex:
      case PoseLandmarkType.leftHeel:
      case PoseLandmarkType.rightHeel:
      case PoseLandmarkType.leftFootIndex:
      case PoseLandmarkType.rightFootIndex:
        break;
    }
  }

  Paint _initPaint(MaterialColor color) {
    Paint paint = Paint();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = color;
    return paint;
  }

  void checkStandPose(Canvas canvas) {
    Logger.log('checking stand pose');

    if (leftEar != null) {
      // Draw lines:
      canvas.drawLine(leftEar!, leftShoulder!, paintL);
      canvas.drawLine(leftShoulder!, leftHip!, paintL);
      canvas.drawLine(leftHip!, leftAnkle!, paintL);

      // Draw points:
      Paint paint = Paint();
      paint.style = PaintingStyle.fill;
      paint.strokeWidth = 2;
      paint.color = Colors.red;
      canvas.drawCircle(leftEar!, 6, paint);
      canvas.drawCircle(leftShoulder!, 6, paint);
      canvas.drawCircle(leftHip!, 6, paint);
      canvas.drawCircle(leftAnkle!, 6, paint);

      final leftEarShoulderAngle = _angleBetween(leftEar!, leftShoulder!);
      final leftShoulderHipAngle = _angleBetween(leftShoulder!, leftHip!);
      final leftHipAnkleAngle = _angleBetween(leftHip!, leftAnkle!);

      PoseMarks.instance.setAngles(
          leftEarShoulderAngle, leftShoulderHipAngle, leftHipAnkleAngle);
    }
  }

  void checkExercise1(Canvas canvas, Size size) {
    _drawLines(canvas);

    ExerciseSupervisor supervisor = ExerciseSupervisor.instance;

    int remainingTime =
        supervisor.exercise1MaxTime - supervisor.stopwatchElapsedSeconds;

    drawText('請維持$remainingTime秒', 24, Colors.green, canvas, size);
    drawText(
        '已完成${supervisor.exercise1Round} / ${supervisor.exercise1MaxRounds} 次',
        24,
        Colors.green,
        canvas,
        size,
        offset: const Offset(0, 50));

    bool correctPose = _correctExercise1Pose();
    int elapsedSecond = supervisor.stopwatchElapsedSeconds;
    int maxTime = supervisor.exercise1MaxTime;
    bool stopwatchIsRunning = supervisor.stopwatchIsRunning;
    int exercise1MaxCount = supervisor.exercise1MaxRounds;

    if (correctPose && !stopwatchIsRunning && elapsedSecond < maxTime) {
      supervisor.startStopwatch();
    } else if (elapsedSecond >= maxTime) {
      supervisor.reset();
      supervisor.exercise1Round += 1;

      if (supervisor.exercise1Round == exercise1MaxCount) {
        Stages.currentStage = Stages.exercise1Completed;
        Logger.log('currentStage: ${Stages.currentStage}');
      }
    } else if (!correctPose) {
      supervisor.pauseStopwatch();
    }
  }

  void checkExercise2(Canvas canvas, Size size) {
    if (leftShoulder == null) return;

    _drawLines(canvas);

    ExerciseSupervisor supervisor = ExerciseSupervisor.instance;

    double elbowShoulderAngle = _angleBetween(leftShoulder!, leftElbow!);
    double elbowWristAngle = _angleBetween(leftElbow!, leftWrist!);

    double elbowAngle = 180 - (elbowShoulderAngle + elbowWristAngle);
    drawText(
        "已完成 ${supervisor.exercise2Count.toString()}/${supervisor.exercise2MaxCount}",
        24,
        Colors.white,
        canvas,
        size);

    if (elbowAngle > 90 && !supervisor.counted) {
      supervisor.exercise2Count += 1;
      supervisor.counted = true;
    } else if (elbowAngle < 80 && supervisor.counted) {
      supervisor.counted = false;
    }

    if (supervisor.exercise2Count == supervisor.exercise2MaxCount) {
      Stages.currentStage = Stages.exercise2Completed;
    }
  }

  void drawText(
      String msg, double fontSize, Color color, Canvas canvas, Size size,
      {Offset offset = Offset.zero, bool centerText = false}) {
    final textStyle = TextStyle(
        color: color, fontSize: fontSize, backgroundColor: Colors.black);
    final textSpan = TextSpan(text: msg, style: textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    if (centerText) {
      final xCenter = (size.width - textPainter.width) / 2;
      final yCenter = (size.height - textPainter.height) / 2;
      final center = Offset(xCenter, yCenter);

      textPainter.paint(canvas, center);
    } else {
      textPainter.paint(canvas, offset);
    }
  }

  bool _correctExercise1Pose() {
    if (leftWrist == null) return false;

    final wristElbowAngle = _angleBetween(leftWrist!, leftElbow!);
    final elbowShoulderAngle = _angleBetween(leftElbow!, leftShoulder!);
    final shoulderHipAngle = _angleBetween(leftShoulder!, leftHip!);

    return (wristElbowAngle < 30 &&
        elbowShoulderAngle < 30 &&
        shoulderHipAngle < 30 &&
        leftWrist!.dy < leftEar!.dy);
  }

  double _angleBetween(Offset p1, Offset p2) {
    double opp = (p1.dx - p2.dx).abs();
    double adj = (p1.dy - p2.dy).abs();
    double rad = atan(opp / adj);
    final angle = rad * 180 / pi;
    return angle;
  }

  void _drawLines(Canvas canvas) {
    canvas.drawLine(leftWrist!, leftElbow!, paintL);
    canvas.drawLine(leftElbow!, leftShoulder!, paintL);
    canvas.drawLine(leftShoulder!, leftHip!, paintL);
    canvas.drawLine(leftHip!, leftKnee!, paintL);
    canvas.drawLine(leftKnee!, leftAnkle!, paintL);

    canvas.drawLine(rightWrist!, rightElbow!, paintR);
    canvas.drawLine(rightElbow!, rightShoulder!, paintR);
    canvas.drawLine(rightShoulder!, rightHip!, paintR);
    canvas.drawLine(rightHip!, rightKnee!, paintR);
    canvas.drawLine(rightKnee!, rightAnkle!, paintR);
  }
}
