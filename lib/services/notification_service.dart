import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/medicine.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    // Optionally request permission for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  static Future<void> scheduleAllReminders(Medicine medicine) async {
    // Cancel previous notifications for this medicine (optional: implement cancel logic)
    await cancelReminders(medicine);

    for (final day in medicine.reminderDays) {
      for (final time in medicine.reminderTimes) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        // Calculate the next occurrence for the selected day
        final now = DateTime.now();
        int weekday = now.weekday; // 1=Mon, 7=Sun
        int daysUntil = (day - weekday) % 7;
        if (daysUntil < 0) daysUntil += 7;

        DateTime scheduled = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        ).add(Duration(days: daysUntil));

        // Use a unique ID for each notification (e.g., medicine.key + day*100 + index)
        int notifId = medicine.key.hashCode + day * 100 + medicine.reminderTimes.indexOf(time);

        await _notificationsPlugin.zonedSchedule(
          notifId,
          'Time to take ${medicine.name}',
          'Dosage: ${medicine.dosage}mg',
          tz.TZDateTime.from(scheduled, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'pillpal_channel',
              'PillPal Reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  // Optionally, cancel all notifications for a medicine (by ID pattern)
  static Future<void> cancelReminders(Medicine medicine) async {
    for (final day in medicine.reminderDays) {
      for (final time in medicine.reminderTimes) {
        int notifId = medicine.key.hashCode + day * 100 + medicine.reminderTimes.indexOf(time);
        await _notificationsPlugin.cancel(notifId);
      }
    }
  }
}
