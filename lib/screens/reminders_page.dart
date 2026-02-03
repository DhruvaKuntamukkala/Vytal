import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final List<String> medicineSuggestions = [
  'Paracetamol',
  'Ibuprofen',
  'Aspirin',
  'Amoxicillin',
  'Azithromycin',
  'Metformin',
  'Atorvastatin',
  'Levothyroxine',
  'Omeprazole',
  'Lisinopril',
  'Amlodipine',
  'Simvastatin',
  'Losartan',
  'Salbutamol',
  'Ciprofloxacin',
  'Cetrizine',
  'Dolo 650',
  'Pantoprazole',
  'Ranitidine',
  'Dexamethasone',
  'Insulin',
  'Prednisolone',
  'Clopidogrel',
  'Warfarin',
  'Tramadol',
  'Diclofenac',
  'Hydrochlorothiazide',
  'Tamsulosin',
  'Fluoxetine',
  'Sertraline',
  'Loratadine',
  'Famotidine',
  'Naproxen',
  'Gabapentin',
  'Meloxicam',
  'Esomeprazole',
  'Nitroglycerin',
  'Codeine',
  'Morphine',
  'Metoprolol',
  'Propranolol',
  'Bisoprolol',
  'Furosemide',
  'Spironolactone',
  'Risperidone',
  'Olanzapine',
  'Alprazolam',
  'Diazepam',
  'Midazolam',
  'Clonazepam',
  'Zolpidem',
  'Loperamide',
  'Ondansetron',
  'Domperidone',
  'Budesonide',
  'Montelukast',
  'Formoterol',
  'Tiotropium',
  'Ipratropium',
  'Cetirizine',
  'Levocetirizine',
  'Mometasone',
  'Hydrocortisone',
  'Betamethasone',
  'Erythromycin',
  'Linezolid',
  'Vancomycin',
  'Tobramycin',
  'Clindamycin',
  'Ketorolac',
  'Lidocaine',
  'Adrenaline',
  'Noradrenaline',
  'Theophylline',
  'Acyclovir',
  'Oseltamivir',
  'Ivermectin',
  'Albendazole',
  'Mebendazole',
  'Chlorpheniramine',
  'Neomycin',
  'Cefixime',
  'Ceftriaxone',
  'Cefuroxime',
  'Amikacin',
  'Gentamicin',
  'Tetracycline',
  'Doxycycline',
  'Rifampicin',
  'Pyrazinamide',
  'Ethambutol',
  'Isoniazid',
  'Vitamin C',
  'Vitamin D3',
  'Calcium',
  'Zinc',
  'Folic Acid',
  'Iron',
  'Magnesium',
];

class Reminder {
  String name;
  TimeOfDay time;
  bool repeatDaily;
  bool isEnabled;

  Reminder({
    required this.name,
    required this.time,
    required this.repeatDaily,
    required this.isEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'repeatDaily': repeatDaily,
      'isEnabled': isEnabled,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      name: map['name'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      repeatDaily: map['repeatDaily'],
      isEnabled: map['isEnabled'],
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }
}

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('reminders') ?? [];
    setState(() {
      _reminders = data
          .map((jsonStr) => Reminder.fromMap(json.decode(jsonStr)))
          .toList();
    });
  }

  Future<void> saveNextReminder(String medicine, String time) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('nextMedicine', medicine);
    prefs.setString('nextTime', time);
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _reminders.map((r) => json.encode(r.toMap())).toList();
    await prefs.setStringList('reminders', data);
  }

  void _addReminder() {
    String name = '';
    TimeOfDay selectedTime = TimeOfDay.now();
    bool repeat = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Reminder',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return medicineSuggestions.where(
                        (option) => option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            onChanged: (val) => name = val,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                            decoration: InputDecoration(
                              labelText: 'Medicine Name',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                    onSelected: (String selection) {
                      name = selection;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Time: ${selectedTime.format(context)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.access_time,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.tealAccent,

                                    // Purple accent for selected time
                                    onPrimary: Colors.black,
                                    surface:
                                        Colors.black, // Dark surface background
                                    onSurface: Colors.white,
                                  ),
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: Colors.grey[800],
                                    dialHandColor: Colors.tealAccent,
                                    hourMinuteTextColor: Colors.white,
                                    dialBackgroundColor: Colors.black,
                                    entryModeIconColor: Colors.white,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                  textTheme: ThemeData.dark().textTheme
                                      .copyWith(
                                        bodyLarge: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        bodyMedium: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        bodySmall: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        titleLarge: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        titleMedium: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        titleSmall: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        labelLarge: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        labelMedium: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        labelSmall: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setInnerState(() => selectedTime = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Repeat Daily",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Checkbox(
                        value: repeat,
                        onChanged: (val) => setInnerState(() => repeat = val!),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    _reminders.add(
                      Reminder(
                        name: name,
                        time: selectedTime,
                        repeatDaily: repeat,
                        isEnabled: true,
                      ),
                    );
                  });
                  _saveReminders();
                  saveNextReminder(name, selectedTime.format(context));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleReminder(int index, bool value) {
    setState(() => _reminders[index].isEnabled = value);
    _saveReminders();
  }

  void _deleteReminder(int index) {
    setState(() => _reminders.removeAt(index));
    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.teal,
        foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.black,
        title: const Text("Reminders", style: TextStyle(fontFamily: 'Poppins')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Text(
                "No reminders yet. Tap + to add one.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: theme.textTheme.bodyMedium?.color ?? Colors.white70,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final r = _reminders[index];
                return Card(
                  color: theme.cardColor,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      "${r.name} - ${r.formattedTime}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      r.repeatDaily ? "Repeats Daily" : "One Time",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color:
                            theme.textTheme.bodySmall?.color ?? Colors.white70,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.isEnabled,
                          onChanged: (val) => _toggleReminder(index, val),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteReminder(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent[700],
        onPressed: _addReminder,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
