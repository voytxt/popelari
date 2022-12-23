import 'package:flutter/material.dart';

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  State<Timetable> createState() => TimetableState();
}

class TimetableState extends State<Timetable> {
  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center, child: const Text('Timetable'));
  }
}
