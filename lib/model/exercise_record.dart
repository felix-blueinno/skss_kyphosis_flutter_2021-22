import 'package:hive/hive.dart';

part 'exercise_record.g.dart';

@HiveType(typeId: 1)
class ExerciseRecord extends HiveObject {
  @HiveField(0)
  late bool postureCorrect;

  @HiveField(1)
  late String earShoulderAngle;

  @HiveField(2)
  late String shoulderHipAngle;

  @HiveField(3)
  late String hipAnkleAngle;

  @HiveField(4)
  int exercise1Rounds = 0;

  @HiveField(5)
  int exercise2Rounds = 0;

  // Stopped usage:
//   @HiveField(6)
//   late DateTime date;

  @HiveField(7)
  String? formatedDate;
}
