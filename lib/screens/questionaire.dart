import 'package:flutter/material.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_1/constant/hive_keys.dart';
import 'package:flutter_application_1/constant/routes.dart';
import 'package:flutter_application_1/model/user_status.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:hive/hive.dart';

class QuestionairePage extends StatefulWidget {
  const QuestionairePage({Key? key}) : super(key: key);

  @override
  _QuestionairePageState createState() => _QuestionairePageState();
}

class _QuestionairePageState extends State<QuestionairePage> {
  String _genderSelection = "";

  int _currentStep = 0;

  List<String> symptoms = ["่ฐ็ ๐ข", "้ ธ็ ๐", "้ ญ็ ๐ค", "ๅถไป ๐ฎ"];
  List<bool> step3Checks = [false, false, false, false];
  List<bool> step4Checks = [false, false, false];

  final TextEditingController ageController = TextEditingController();
  final TextEditingController symptomController = TextEditingController();

  int _exerciseFrequency = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ๅฏ่ๆฒป็")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    "ๅจ้ๅงๅฏ่ๆฒป็ไนๅ๏ผ\n่ซๅๅฎๆไปฅไธๅๅท",
                    speed: const Duration(milliseconds: 90),
                    textStyle: const TextStyle(fontSize: 24),
                  )
                ],
                isRepeatingAnimation: false,
              ),
              Stepper(
                // Customize the step buttons to Chinese:
                controlsBuilder: (context, details) => Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text("็นผ็บ")),
                      const SizedBox(width: 8),
                      if (details.currentStep != 0)
                        TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text("่ฟๅ")),
                    ],
                  ),
                ),

                // Keep track of current step:
                currentStep: _currentStep,

                // Update current step:
                onStepTapped: (value) => setState(() => _currentStep = value),

                // Increment current step or check questionaire completion:
                onStepContinue: () {
                  if (_currentStep != 3) {
                    setState(() => _currentStep++);
                  } else if (_currentStep == 3) {
                    int? age = int.tryParse(ageController.text);

                    if (_genderSelection == "") {
                      setState(() => _currentStep = 0);
                      showAlertDialog(context, "ๅๅทๆชๅฎๆ", "่ซ้ธๆไฝ ็ๆงๅฅ");
                    } else if (ageController.text.isEmpty) {
                      setState(() => _currentStep = 1);
                      showAlertDialog(context, "ๅๅทๆชๅฎๆ", "่ซๅกซๅฏซไฝ ็ๅนด้ฝก");
                    } else if (age == null || age.isNegative || age == 0) {
                      setState(() => _currentStep = 1);
                      showAlertDialog(context, "ๅๅทๆชๅฎๆ", "่ซๅกซๅฏซๆญฃ็ขบ็ๅนด้ฝก");
                    } else if (_exerciseFrequency == -1) {
                      setState(() => _currentStep = 3);
                      showAlertDialog(context, "ๅๅทๆชๅฎๆ", "่ซๅกซๅฏซไฝ ้ๅ็้ ป็");
                    } else {
                      // User finishes the questionaire without error:
                      UserStatus userStatus = UserStatus();
                      userStatus.gender = _genderSelection;
                      userStatus.age = age;
                      userStatus.exerciseFrequency = _exerciseFrequency;
                      for (var i = 0; i < step3Checks.length; i++) {
                        if (step3Checks[i]) {
                          userStatus.symptoms.add(symptoms[i]);
                        }
                      }

                      final box = Hive.box(MyHive.userStatus);
                      box.add(userStatus);

                      Navigator.pushReplacementNamed(
                          context, Routes.postureDetection);
                    }
                  }
                },
                onStepCancel: () {
                  if (_currentStep != 0) setState(() => _currentStep--);
                },
                physics: const BouncingScrollPhysics(),
                steps: [
                  buildStep1(),
                  buildStep2(),
                  buildStep3(),
                  buildStep4(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Object?> showAlertDialog(BuildContext context, title, content) =>
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"))
          ],
        ),
        animationType: DialogTransitionType.size,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(seconds: 1),
      );

  Step buildStep4() => Step(
        isActive: _currentStep == 3,
        title: const Text("ๅ้กๅ"),
        subtitle: const Text("ไฝ ๅนณๆ้ๅ็้ ป็๏ผ"),
        content: Column(
          children: [
            RadioListTile(
              title: const Text("ไธๆๆไธๆฌกๆไปฅไธ ๐ช"),
              value: UserStatus.frequentExercise,
              groupValue: _exerciseFrequency,
              onChanged: (onChangedStr) => setState(
                  () => _exerciseFrequency = UserStatus.frequentExercise),
            ),
            RadioListTile(
              title: const Text("ไธๆๆไบ่ณไธๆฌก ๐"),
              value: UserStatus.someExercise,
              groupValue: _exerciseFrequency,
              onChanged: (onChangedStr) =>
                  setState(() => _exerciseFrequency = UserStatus.someExercise),
            ),
            RadioListTile(
              title: const Text("ๅนพไนๆฒๆ ๐ง"),
              value: UserStatus.noExercise,
              groupValue: _exerciseFrequency,
              onChanged: (onChangedStr) =>
                  setState(() => _exerciseFrequency = UserStatus.noExercise),
            ),
          ],
        ),
      );

  Step buildStep3() => Step(
        isActive: _currentStep == 2,
        title: const Text("ๅ้กไธ"),
        subtitle: const Text("ไฝ ๅนณๆๆฏๅฆๆๅบ็พไปฅไธ็็๏ผ"),
        content: Column(
          children: [
            CheckboxListTile(
              enableFeedback: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: step3Checks[0],
              onChanged: (onChanged) => setState(() {
                if (onChanged != null) step3Checks[0] = onChanged;
              }),
              title: Text(symptoms[0]),
            ),
            CheckboxListTile(
              enableFeedback: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: step3Checks[1],
              onChanged: (onChanged) => setState(() {
                if (onChanged != null) step3Checks[1] = onChanged;
              }),
              title: Text(symptoms[1]),
            ),
            CheckboxListTile(
              enableFeedback: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: step3Checks[2],
              onChanged: (onChanged) => setState(() {
                if (onChanged != null) step3Checks[2] = onChanged;
              }),
              title: Text(symptoms[2]),
            ),
            CheckboxListTile(
              enableFeedback: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: step3Checks[3],
              onChanged: (onChanged) => setState(() {
                if (onChanged != null) step3Checks[3] = onChanged;
              }),
              title: Text(symptoms[3]),
            ),
            if (step3Checks[3])
              TextField(
                controller: symptomController,
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                  label: Row(
                    children: const [
                      Icon(Icons.edit_rounded),
                      SizedBox(width: 8),
                      Text("่ซๅๆ"),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );

  Step buildStep2() => Step(
        isActive: _currentStep == 1,
        title: const Text("ๅ้กไบ"),
        subtitle: const Text("ๅนด้ฝก"),
        content: TextField(
          controller: ageController,
          maxLength: 3,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: const InputDecoration(
            labelText: "่ซ่ผธๅฅไฝ ็ๅนด้ฝก",
            icon: Icon(Icons.timelapse_rounded),
          ),
        ),
      );

  Step buildStep1() => Step(
        isActive: _currentStep == 0,
        title: const Text("ๅ้กไธ"),
        subtitle: const Text("ๆงๅฅ"),
        content: Column(
          children: [
            RadioListTile(
              title: const Text("็ท"),
              value: UserStatus.male,
              groupValue: _genderSelection,
              onChanged: (onChangedStr) =>
                  setState(() => _genderSelection = UserStatus.male),
            ),
            RadioListTile(
              title: const Text("ๅฅณ"),
              value: UserStatus.female,
              groupValue: _genderSelection,
              onChanged: (onChangedStr) =>
                  setState(() => _genderSelection = UserStatus.female),
            ),
            RadioListTile(
              title: const Text("ๅถไป"),
              value: UserStatus.other,
              groupValue: _genderSelection,
              onChanged: (onChangedStr) =>
                  setState(() => _genderSelection = UserStatus.other),
            ),
          ],
        ),
      );
}
