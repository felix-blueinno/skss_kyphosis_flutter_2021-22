import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_application_1/constant/hive_keys.dart';
import 'package:flutter_application_1/constant/routes.dart';
import 'package:flutter_application_1/model/user_status.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _boxFound = false;
  String? _gender;
  int? _age;

  String _symptom = "";
  String _exerciseFrequency = "";

  @override
  void initState() {
    super.initState();
    initStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(FontAwesomeIcons.addressCard),
        title: const Text("個人資料"),
        actions: [
          IconButton(
              onPressed: () {
                showAnimatedDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("是否希望刪除以下資料？"),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("否")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, ModalRoute.withName(Routes.dashboard));
                            Box box = Hive.box(MyHive.userStatus);
                            box.deleteAt(0);
                          },
                          child: const Text("是")),
                    ],
                  ),
                  animationType: DialogTransitionType.size,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(seconds: 1),
                );
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _boxFound
            ? buildPage(context)
            : SpinKitFadingCube(
                color: Colors.blue[100],
              ),
      ),
    );
  }

  initStatus() {
    // Get user's questionaire inputs from local storage:
    Box box = Hive.box(MyHive.userStatus);
    UserStatus userStatus = box.getAt(0);

    // Update fields for UI:
    _boxFound = true;
    _gender = userStatus.gender;
    _age = userStatus.age;

    for (String item in userStatus.symptoms) {
      // example: "腰痛 😢"
      if (item == userStatus.symptoms.last) {
        _symptom = _symptom + item;
      } else {
        _symptom = _symptom + item + ", ";
      }
    }

    switch (userStatus.exerciseFrequency) {
      case UserStatus.frequentExercise:
        _exerciseFrequency = "一星期三次或以上";
        break;
      case UserStatus.someExercise:
        _exerciseFrequency = "一星期二至三次";
        break;
      case UserStatus.noExercise:
        _exerciseFrequency = "幾乎沒有";
        break;
    }
  }

  buildPage(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    late Icon genderIcon;
    switch (_gender) {
      case UserStatus.male:
        genderIcon = Icon(
          FontAwesomeIcons.mars,
          size: screenWidth * 0.1,
          color: Colors.blueAccent,
        );
        break;
      case UserStatus.female:
        genderIcon = Icon(
          FontAwesomeIcons.venus,
          size: screenWidth * 0.1,
          color: Colors.redAccent,
        );
        break;
      case UserStatus.other:
        genderIcon = Icon(
          FontAwesomeIcons.venusMars,
          size: screenWidth * 0.1,
          color: Colors.greenAccent,
        );
        break;
    }

    Icon ageIcon =
        Icon(FontAwesomeIcons.hourglass, color: Colors.green[400], size: 32);
    Icon symptomIcon =
        Icon(FontAwesomeIcons.tired, color: Colors.green[400], size: 32);
    Icon exerciseIcon =
        Icon(FontAwesomeIcons.running, color: Colors.green[400], size: 32);

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Column(
        children: [
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            minRadius: screenWidth * 0.1,
            child: genderIcon,
          ),
          const SizedBox(height: 48),
          buildCard(ageIcon, "年齡", _age.toString()),
          const SizedBox(height: 16),
          buildCard(symptomIcon, "症狀", _symptom),
          const SizedBox(height: 16),
          buildCard(exerciseIcon, "運動頻率", _exerciseFrequency),
          const Spacer(),
        ],
      ),
    );
  }

  Card buildCard(Icon icon, String title, String content) => Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
        ),
      );
}
