// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String,
      time: fields[1] as DateTime,
      dosage: fields[2] as int,
      pillCount: fields[4] as int,
      refillThreshold: fields[5] as int,
      takenHistory: (fields[3] as List?)?.cast<DateTime>(),
      reminderTimes: (fields[6] as List?)?.cast<String>(),
      reminderDays: (fields[7] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.takenHistory)
      ..writeByte(4)
      ..write(obj.pillCount)
      ..writeByte(5)
      ..write(obj.refillThreshold)
      ..writeByte(6)
      ..write(obj.reminderTimes)
      ..writeByte(7)
      ..write(obj.reminderDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
