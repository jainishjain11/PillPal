import 'package:hive/hive.dart';

part 'medicine.g.dart';
@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime time;

  @HiveField(2)
  int dosage;

  @HiveField(3)
  List<DateTime> takenHistory;

  @HiveField(4)
  int pillCount;

  @HiveField(5)
  int refillThreshold;

  Medicine({
    required this.name,
    required this.time,
    required this.dosage,
    required this.pillCount,
    required this.refillThreshold,
    List<DateTime>? takenHistory,
  }) : takenHistory = takenHistory ?? [];
}
