import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleAllReminders(Medicine medicine) async {
    await cancelReminders(medicine);

    final now = tz.TZDateTime.now(tz.local);

    for (final day in medicine.reminderDays) {
      for (final time in medicine.reminderTimes) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final scheduledDate = _nextOccurrence(day, hour, minute, now);
        final notifId = medicine.key.hashCode + day.hashCode + time.hashCode;

        await _notificationsPlugin.zonedSchedule(
          notifId,
          'Time to take ${medicine.name}',
          'Dosage: ${medicine.dosage}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'pillpal_channel',
              'PillPal Reminders',
              channelDescription: 'Channel for medication reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  // --- THIS METHOD WAS MISSING ---
  static Future<void> cancelReminders(Medicine medicine) async {
    for (final day in medicine.reminderDays) {
      for (final time in medicine.reminderTimes) {
        final notifId = medicine.key.hashCode + day.hashCode + time.hashCode;
        await _notificationsPlugin.cancel(notifId);
      }
    }
  }
  // --- END OF cancelReminders ---

  // --- THIS METHOD WAS MISSING ---
  static tz.TZDateTime _nextOccurrence(
      int targetDay, int hour, int minute, tz.TZDateTime now) {
    int daysUntil = (targetDay - now.weekday) % 7;
    if (daysUntil < 0) daysUntil += 7;

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntil,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
  // --- END OF _nextOccurrence ---
}
