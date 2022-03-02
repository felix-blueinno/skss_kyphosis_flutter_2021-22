import 'package:flutter/material.dart';
import 'package:flutter_application_1/constant/routes.dart';
import 'package:flutter_application_1/model/exercise_record.dart';
import 'package:flutter_application_1/singletons/exercise_supervisor.dart';
import 'package:flutter_application_1/singletons/record.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../constant/hive_keys.dart';

class Complete extends StatelessWidget {
  const Complete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final instance = Record.instance;

    final box = Hive.box(MyHive.exerciseRecord);
    ExerciseRecord exerciseRecord = ExerciseRecord();

    exerciseRecord.postureCorrect = instance.postureCorrect;
    exerciseRecord.earShoulderAngle = instance.earShoulder;
    exerciseRecord.shoulderHipAngle = instance.shoulderHip;
    exerciseRecord.hipAnkleAngle = instance.hipAnkle;
    exerciseRecord.exercise1Rounds = instance.exercise1Rounds;
    exerciseRecord.exercise2Rounds = instance.exercise2Count;

    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    exerciseRecord.formatedDate = dateFormat.format(DateTime.now());

    Future future = box.add(exerciseRecord);

    String content = '''
完成時間： ${exerciseRecord.formatedDate}
耳朵與肩膀之間的角度： ${instance.earShoulder}
肩膀與臀部之間的角度： ${instance.shoulderHip}
臀部與腳踝之間的角度： ${instance.hipAnkle}
運動一紀錄：${instance.exercise1Rounds} / ${ExerciseSupervisor.instance.exercise1MaxRounds}
運動二紀錄：${instance.exercise2Count} / ${ExerciseSupervisor.instance.exercise2MaxCount}
''';

    return Scaffold(
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String content = '''
完成時間： ${exerciseRecord.formatedDate}
耳朵與肩膀之間的角度： ${instance.earShoulder}
肩膀與臀部之間的角度： ${instance.shoulderHip}
臀部與腳踝之間的角度： ${instance.hipAnkle}
運動一 紀錄：${instance.exercise1Rounds} / ${ExerciseSupervisor.instance.exercise1MaxRounds}
運動二 紀錄：${instance.exercise2Count} / ${ExerciseSupervisor.instance.exercise2MaxCount}
''';

            instance.reset();
            return AlertDialog(
              title: const Text("完成"),
              content: Text(content),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(Routes.dashboard),
                      );
                    },
                    child: const Text('回到主頁'))
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
