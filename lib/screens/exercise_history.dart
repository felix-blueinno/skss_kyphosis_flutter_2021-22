import 'package:flutter/material.dart';
import 'package:flutter_application_1/constant/hive_keys.dart';
import 'package:flutter_application_1/model/exercise_record.dart';
import 'package:hive/hive.dart';

import '../singletons/exercise_supervisor.dart';

class ExerciseHistory extends StatelessWidget {
  const ExerciseHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box(MyHive.exerciseRecord);

    return Scaffold(
      appBar: AppBar(
        title: const Text('運動紀錄'),
        actions: [
          IconButton(
            onPressed: () {
              box.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_forever_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: box.length,
        itemBuilder: (context, index) {
          ExerciseRecord record = box.getAt(index);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('完成時間： ${record.formatedDate}'),
                  Text('''
耳-肩角度： ${record.earShoulderAngle}
肩-臀角度： ${record.shoulderHipAngle}
臀-腳角度： ${record.hipAnkleAngle}
運動一 紀錄：${record.exercise1Rounds} / ${ExerciseSupervisor.instance.exercise1MaxRounds}
運動二 紀錄：${record.exercise2Rounds} / ${ExerciseSupervisor.instance.exercise2MaxCount}''')
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
