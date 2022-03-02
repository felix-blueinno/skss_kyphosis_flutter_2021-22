// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseRecordAdapter extends TypeAdapter<ExerciseRecord> {
  @override
  final int typeId = 1;

  @override
  ExerciseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseRecord()
      ..postureCorrect = fields[0] as bool
      ..earShoulderAngle = fields[1] as String
      ..shoulderHipAngle = fields[2] as String
      ..hipAnkleAngle = fields[3] as String
      ..exercise1Rounds = fields[4] as int
      ..exercise2Rounds = fields[5] as int
      ..formatedDate = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, ExerciseRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.postureCorrect)
      ..writeByte(1)
      ..write(obj.earShoulderAngle)
      ..writeByte(2)
      ..write(obj.shoulderHipAngle)
      ..writeByte(3)
      ..write(obj.hipAnkleAngle)
      ..writeByte(4)
      ..write(obj.exercise1Rounds)
      ..writeByte(5)
      ..write(obj.exercise2Rounds)
      ..writeByte(7)
      ..write(obj.formatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
