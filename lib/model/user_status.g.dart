// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 0;

  @override
  UserStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStatus()
      ..gender = fields[0] as String
      ..age = fields[1] as int
      ..symptoms = (fields[2] as List).cast<String>()
      ..exerciseFrequency = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.gender)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.exerciseFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
