import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime time; // Original time (now optional in UI)

  @HiveField(2)
  int dosage;

  @HiveField(3)
  List<DateTime> takenHistory;

  @HiveField(4)
  int pillCount;

  @HiveField(5)
  int refillThreshold;

  @HiveField(6)
  List<String> reminderTimes; // Stores times as "HH:mm" strings

  @HiveField(7)
  List<int> reminderDays; // 1=Monday to 7=Sunday

  Medicine({
    required this.name,
    required this.time,
    required this.dosage,
    required this.pillCount,
    required this.refillThreshold,
    List<DateTime>? takenHistory,
    List<String>? reminderTimes,
    List<int>? reminderDays,
  })  : takenHistory = takenHistory ?? [],
        reminderTimes = reminderTimes ?? 
          ["${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"],
        reminderDays = reminderDays ?? List.generate(7, (i) => i + 1); // Default: daily
}
