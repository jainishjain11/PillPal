import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _pillCountController = TextEditingController();
  final _refillThresholdController = TextEditingController();

  List<String> _reminderTimes = [];
  List<int> _selectedDays = List.generate(7, (index) => index + 1); // Mon-Sun

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _pillCountController.dispose();
    _refillThresholdController.dispose();
    super.dispose();
  }

  void _addTime(TimeOfDay time) {
    setState(() {
      _reminderTimes.add(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
      );
    });
  }

  void _removeTime(int index) {
    setState(() => _reminderTimes.removeAt(index));
  }

  void _toggleDay(int day) {
    setState(() {
      _selectedDays.contains(day)
          ? _selectedDays.remove(day)
          : _selectedDays.add(day);
    });
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate() && _reminderTimes.isNotEmpty) {
      final medicine = Medicine(
        name: _nameController.text,
        time: DateTime.now(), // Deprecated but still required
        dosage: int.tryParse(_dosageController.text) ?? 1, // Ensure int
        pillCount: int.tryParse(_pillCountController.text) ?? 0,
        refillThreshold: int.tryParse(_refillThresholdController.text) ?? 3,
        reminderTimes: _reminderTimes,
        reminderDays: _selectedDays,
        alarmSound: 'default', // Add your sound selection logic here
      );

      final box = Hive.box<Medicine>('medicines');
      await box.add(medicine);

      // Schedule notifications
      await NotificationService.scheduleAllReminders(medicine);

      // Schedule alarms
      for (final day in _selectedDays) {
        for (final time in _reminderTimes) {
          final parts = time.split(':');
          final now = DateTime.now();
          int daysUntil = (day - now.weekday) % 7;
          if (daysUntil < 0) daysUntil += 7;
          
          final scheduledTime = DateTime(
            now.year,
            now.month,
            now.day + daysUntil,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

          await AndroidAlarmManager.oneShotAt(
            scheduledTime,
            medicine.key.hashCode + day.hashCode + time.hashCode,
            alarmCallback,
            exact: true,
            wakeup: true,
          );
        }
      }

      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g., Paracetamol',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dosageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 1 tablet)',
                  hintText: 'Enter number of units',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pillCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Pills',
                  hintText: 'e.g., 30',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _refillThresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Refill Threshold',
                  hintText: 'e.g., 3',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              const Text('Repeat on:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .asMap()
                    .entries
                    .map((entry) {
                  final dayIndex = entry.key + 1;
                  return FilterChip(
                    label: Text(entry.value),
                    selected: _selectedDays.contains(dayIndex),
                    onSelected: (_) => _toggleDay(dayIndex),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const Text('Reminder Times:', style: TextStyle(fontSize: 16)),
              ..._reminderTimes.asMap().entries.map((entry) => ListTile(
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTime(entry.key),
                    ),
                  )),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) _addTime(picked);
                },
                child: const Text('Add Reminder Time'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveMedicine,
                child: const Text('Save Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
