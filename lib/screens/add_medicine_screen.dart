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
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _pillCountController.dispose();
    _refillThresholdController.dispose();
    super.dispose();
  }

  void _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      final medicine = Medicine(
        name: _nameController.text,
        time: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        dosage: int.tryParse(_dosageController.text) ?? 1,
        pillCount: int.tryParse(_pillCountController.text) ?? 0,
        refillThreshold: int.tryParse(_refillThresholdController.text) ?? 3,
      );

      final box = Hive.box<Medicine>('medicines');
      await box.add(medicine);

      // Schedule notification for medication time
      await NotificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Time to take ${medicine.name}!',
        body: 'Dosage: ${medicine.dosage}mg',
        scheduledTime: medicine.time,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
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
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter medication name' : null,
              ),
              TextFormField(
                controller: _dosageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Dosage (mg)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter dosage' : null,
              ),
              ListTile(
                title: const Text('Time to Take'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _pickTime(context),
                ),
              ),
              TextFormField(
                controller: _pillCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Pills (for refill reminder)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter total pills' : null,
              ),
              TextFormField(
                controller: _refillThresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Refill Reminder Threshold (e.g., 3)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter threshold' : null,
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
