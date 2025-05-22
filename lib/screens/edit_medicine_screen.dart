import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/medicine.dart';

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
  late TimeOfDay _selectedTime;
  final _formKey = GlobalKey<FormState>(); // Added form key

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage.toString());
    _pillCountController = TextEditingController(text: widget.medicine.pillCount.toString());
    _refillThresholdController = TextEditingController(text: widget.medicine.refillThreshold.toString());
    _selectedTime = TimeOfDay.fromDateTime(widget.medicine.time);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _pillCountController.dispose();
    _refillThresholdController.dispose();
    super.dispose();
  }

  void _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveEdits() async {
    if (_formKey.currentState!.validate()) { // Added validation check
      widget.medicine
        ..name = _nameController.text
        ..dosage = int.parse(_dosageController.text)
        ..pillCount = int.parse(_pillCountController.text)
        ..refillThreshold = int.parse(_refillThresholdController.text)
        ..time = DateTime(
          widget.medicine.time.year,
          widget.medicine.time.month,
          widget.medicine.time.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

      await widget.medicine.save();
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
          key: _formKey, // Added form key
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dosageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Dosage (mg)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
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
                decoration: const InputDecoration(labelText: 'Total Pills'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _refillThresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Refill Threshold'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
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
