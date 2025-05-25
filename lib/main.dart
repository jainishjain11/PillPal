import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/medicine.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/add_medicine_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;


// Platform checks for Android-only features
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Only import if on Android
bool get _isAndroid => !kIsWeb && Platform.isAndroid;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MedicineAdapter());
  await Hive.openBox<Medicine>('medicines');
  await NotificationService.initialize();

  // Only initialize alarm manager on Android
  if (!kIsWeb && Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  runApp(const PillPalApp());
}
class PillPalApp extends StatelessWidget {
  const PillPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillPal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/add': (context) => const AddMedicineScreen(),
      },
    );
  }
}
