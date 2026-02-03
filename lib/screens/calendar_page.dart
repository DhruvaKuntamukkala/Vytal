import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Map<DateTime, List<String>> _notes = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _addNoteForDate(DateTime date, String note) {
    setState(() {
      final key = DateTime(date.year, date.month, date.day);
      if (_notes[key] != null) {
        _notes[key]!.add(note);
      } else {
        _notes[key] = [note];
      }
    });
  }

  List<String> _getNotesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _notes[key] ?? [];
  }

  void _showAddNoteDialog(DateTime selectedDate) {
    String note = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Add Note',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
          content: TextField(
            onChanged: (value) => note = value,
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            decoration: const InputDecoration(
              hintText: 'Enter note',
              hintStyle: TextStyle(
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
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
                if (note.trim().isNotEmpty) {
                  _addNoteForDate(selectedDate, note.trim());
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.tealAccent[700],
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                defaultTextStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Poppins',
                ),
                weekendTextStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontFamily: 'Poppins',
                ),
                outsideTextStyle: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade500,
                  fontFamily: 'Poppins',
                ),
              ),
              eventLoader: (day) => _getNotesForDay(day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showAddNoteDialog(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return const Positioned(
                      bottom: 1,
                      child: Icon(
                        Icons.circle,
                        size: 6.0,
                        color: Colors.redAccent,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _notes.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${entry.key.day}/${entry.key.month}/${entry.key.year}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...entry.value.map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '- $note',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      Divider(color: isDark ? Colors.grey : Colors.black26),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
