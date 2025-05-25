import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime time; // Will be deprecated

  @HiveField(2)
  int dosage;

  @HiveField(3)
  List<DateTime> takenHistory;

  @HiveField(4)
  int pillCount;

  @HiveField(5)
  int refillThreshold;

  @HiveField(6)
  List<String> reminderTimes;

  @HiveField(7)
  List<int> reminderDays;

  @HiveField(8)
  String? alarmSound;

  Medicine({
    required this.name,
    required this.time,
    required this.dosage,
    required this.pillCount,
    required this.refillThreshold,
    this.takenHistory = const [],
    required this.reminderTimes,
    required this.reminderDays,
    this.alarmSound,
  });
}
