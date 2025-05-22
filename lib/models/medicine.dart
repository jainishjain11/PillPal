import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime time;

  @HiveField(2)
  final int dosage;

  Medicine({
    required this.name,
    required this.time,
    required this.dosage,
  });
}
