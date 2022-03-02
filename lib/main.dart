import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/model/exercise_record.dart';
import 'package:flutter_application_1/screens/complete.dart';
import 'package:flutter_application_1/screens/exercise.dart';
import 'package:flutter_application_1/screens/exercise_history.dart';
import 'package:flutter_application_1/screens/exercise_instructions.dart';
import 'package:flutter_application_1/singletons/cameras.dart';
import 'package:flutter_application_1/screens/questionaire.dart';
import 'package:flutter_application_1/model/user_status.dart';
import 'package:flutter_application_1/screens/user_profile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'constant/hive_keys.dart';
import 'constant/routes.dart';
import 'screens/dashboard.dart';
import 'screens/posture_detect.dart';

String logoUrl = "assets/SKSS_logo.jpeg";

String appTitle = "家居治療APP";
String hintText = "一按螢幕任意地方開始一";

main() async {
  // Init local database:
  await Hive.initFlutter();
  Hive.registerAdapter(UserStatusAdapter());
  Hive.registerAdapter(ExerciseRecordAdapter());
  await Hive.openBox(MyHive.userStatus);
  await Hive.openBox(MyHive.exerciseRecord);

  // Find all available cameras:
  Cameras.instance.cams = await availableCameras();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      Routes.dashboard: (context) => const DashBoard(),
      Routes.questionaire: (context) => const QuestionairePage(),
      Routes.userProfile: (context) => const UserProfile(),
      Routes.postureDetection: (context) => const PostureDetection(),
      Routes.exercise: (context) => const Exercise(),
      Routes.exerciseInstruction: (context) => const ExerciseInstruction(),
      Routes.complete: (context) => const Complete(),
      Routes.exerciseHistory: (context) => const ExerciseHistory(),
    },
    home: const SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _txtOpacity = 1;
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Repeating fade in/out animation:
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() => _txtOpacity = _txtOpacity == 1 ? 0.4 : 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, Routes.dashboard),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Center(child: Image.asset(logoUrl, fit: BoxFit.fill)),
              Positioned(
                bottom: 36,
                left: 24,
                right: 24,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 1000),
                  opacity: _txtOpacity,
                  curve: Curves.linear,
                  child: Text(
                    hintText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Positioned(
                top: 36,
                left: 24,
                right: 24,
                child: Text(
                  appTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
