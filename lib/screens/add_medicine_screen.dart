import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';

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
  List<int> _selectedDays = List.generate(7, (index) => index + 1);

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

  void _saveMedicine() async {
    if (_formKey.currentState!.validate() && _reminderTimes.isNotEmpty) {
      final medicine = Medicine(
        name: _nameController.text,
        time: DateTime.now(), // Original time (deprecated)
        dosage: int.tryParse(_dosageController.text) ?? 1,
        pillCount: int.tryParse(_pillCountController.text) ?? 0,
        refillThreshold: int.tryParse(_refillThresholdController.text) ?? 3,
        reminderTimes: _reminderTimes,
        reminderDays: _selectedDays,
      );

      final box = Hive.box<Medicine>('medicines');
      await box.add(medicine);
      await NotificationService.scheduleAllReminders(medicine);

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
              // Medication Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g., Paracetamol',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 1 tablet, 5mg',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Total Pills
              TextFormField(
                controller: _pillCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Pills',
                  hintText: 'e.g., 30',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Refill Threshold
              TextFormField(
                controller: _refillThresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Refill Reminder When Left',
                  hintText: 'e.g., 3',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Days of Week Selector
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

              // Reminder Times
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

              // Save Button
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
