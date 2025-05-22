import 'package:flutter/material.dart';
import '../models/medicine.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
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

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      // For now, just print the result. We'll save it later!
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
      );
      print('Medicine added: ${medicine.name}, ${medicine.dosage}mg at ${medicine.time}');
      Navigator.pop(context); // Go back to previous screen
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
          child: Column(
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
