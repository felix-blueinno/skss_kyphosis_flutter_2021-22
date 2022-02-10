import 'package:hive/hive.dart';

part 'user_status.g.dart';

@HiveType(typeId: 0)
class UserStatus extends HiveObject {
  @HiveField(0)
  late String gender;

  @HiveField(1)
  late int age;

  @HiveField(2)
  List<String> symptoms = [];

  @HiveField(3)
  late int exerciseFrequency;

  static const int noExercise = 0;
  static const int someExercise = 1;
  static const int frequentExercise = 2;

  static const String male = "male";
  static const String female = "female";
  static const String other = "others";
}
