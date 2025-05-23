import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';

class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;
  const EditMedicineScreen({super.key, required this.medicine});

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _pillCountController;
  late final TextEditingController _refillThresholdController;
  late List<String> _reminderTimes;
  late List<int> _selectedDays;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage.toString());
    _pillCountController = TextEditingController(text: widget.medicine.pillCount.toString());
    _refillThresholdController = TextEditingController(text: widget.medicine.refillThreshold.toString());
    
    // Initialize reminder times and days
    _reminderTimes = List.from(widget.medicine.reminderTimes);
    _selectedDays = List.from(widget.medicine.reminderDays);
  }

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
      _selectedDays.sort();
    });
  }

  void _saveEdits() async {
  if (_formKey.currentState!.validate() && _reminderTimes.isNotEmpty) {
    widget.medicine
      ..name = _nameController.text
      ..dosage = int.parse(_dosageController.text)
      ..pillCount = int.parse(_pillCountController.text)
      ..refillThreshold = int.parse(_refillThresholdController.text)
      ..reminderTimes = _reminderTimes
      ..reminderDays = _selectedDays;

    await widget.medicine.save();

    // Update notifications
    await NotificationService.scheduleAllReminders(widget.medicine); // <-- Add this line

    if (context.mounted) Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              // Dosage Field
              TextFormField(
                controller: _dosageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Dosage (mg)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              // Pill Count Field
              TextFormField(
                controller: _pillCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Pills'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              // Refill Threshold Field
              TextFormField(
                controller: _refillThresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Refill Threshold'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              // Days of Week Selector
              const SizedBox(height: 16),
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

              // Reminder Times Section
              const SizedBox(height: 16),
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

              // Save Button
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveEdits,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
