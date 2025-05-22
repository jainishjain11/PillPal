import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import 'edit_medicine_screen.dart'; // Ensure this import is added

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool wasTakenToday(Medicine medicine) {
    final today = DateTime.now();
    return medicine.takenHistory.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PillPal'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Medicine>('medicines').listenable(),
        builder: (context, Box<Medicine> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No medications added yet.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final medicine = box.getAt(index);
              if (medicine == null) return const SizedBox.shrink();

              return Dismissible(
                key: Key(medicine.key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  medicine.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${medicine.name} deleted')),
                  );
                },
                child: ListTile(
                  title: Text(medicine.name),
                  subtitle: Text(
                    'Dosage: ${medicine.dosage}mg\n'
                    'Time: ${medicine.time.hour}:${medicine.time.minute.toString().padLeft(2, '0')}\n'
                    'Pills left: ${medicine.pillCount}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditMedicineScreen(medicine: medicine),
                              ),
                            );
                          }
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(
                          wasTakenToday(medicine)
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: wasTakenToday(medicine)
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          if (!wasTakenToday(medicine)) {
                            medicine.takenHistory.add(DateTime.now());
                            if (medicine.pillCount > 0) {
                              medicine.pillCount -= 1;
                            }
                            medicine.save();

                            if (medicine.pillCount <=
                                medicine.refillThreshold) {
                              // Refill reminder logic
                            }
                          }
                        },
                        tooltip: 'Mark as Taken',
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('${medicine.name} History'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: medicine.takenHistory.isEmpty
                                ? const Text('No doses taken yet.')
                                : ListView(
                                    shrinkWrap: true,
                                    children: medicine.takenHistory
                                        .map((date) => Text(
                                            '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}'))
                                        .toList(),
                                  ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
