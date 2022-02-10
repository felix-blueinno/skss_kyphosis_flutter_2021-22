import 'package:flutter/material.dart';
import 'package:flutter_application_1/constant/routes.dart';
import 'package:flutter_application_1/constant/stages.dart';

class ExerciseInstruction extends StatelessWidget {
  const ExerciseInstruction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appBarTitle = '';
    String imgSrc = '';
    String instruction = '';
    String referenceTxt = '圖源: https://wppc.hk/zh-hant/topics/detail/0/15/';

    if (Stages.currentStage == Stages.exercise1Instruction) {
      appBarTitle = '動作一 (教學)';
      imgSrc = 'assets/instruction1.jpeg';
      instruction = '伸展上背： 雙手扣指伸直，慢慢向上舉高，頸伸直，停留10秒後放鬆，重覆5-8次';
    }
    /* Stages.currentStage == Stages.exercise2Instruction */
    else {
      appBarTitle = '動作二 (教學)';
      imgSrc = 'assets/instruction2.jpeg';
      instruction = '俯臥背伸： 躺下俯臥，手放肩旁，然後手慢慢伸直，將上半身橕起，腰背要放鬆，停留2秒後放鬆，重覆5-10次';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
              onPressed: () {
                Stages.currentStage =
                    Stages.currentStage == Stages.exercise1Instruction
                        ? Stages.exercise1
                        : Stages.exercise2;
                Navigator.pushReplacementNamed(context, Routes.exercise);
              },
              icon: const Icon(Icons.arrow_forward))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(instruction, style: const TextStyle(fontSize: 20)),
            ),
            Expanded(flex: 10, child: Image.asset(imgSrc, fit: BoxFit.contain)),
            Flexible(
              child: Text(referenceTxt,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
