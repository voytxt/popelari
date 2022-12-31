import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:popelari/screens/auth.dart';
import 'package:popelari/screens/dev_drawer.dart';
import 'package:popelari/screens/grades.dart';
import 'package:popelari/screens/overview.dart';
import 'package:popelari/screens/strava.dart';
import 'package:popelari/screens/timetable.dart';

void main() {
  runApp(MaterialApp(
    title: 'Popeláři',
    initialRoute: '/',
    routes: {
      '/': (context) => const Main(),
      '/auth': (context) => const Auth(),
    },
    theme: ThemeData(
      useMaterial3: true,
      // brightness: Brightness.dark,
      colorSchemeSeed: Colors.amber,
    ),
  ));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    log('Rebuilding UI', name: 'FLUTTER');

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPageIndex.toString()),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: [
            const Overview(),
            const Strava(),
            const Timetable(),
            const Grades(),
          ][currentPageIndex],
        ),
      ),

      // M2 for now, M3: https://github.com/flutter/flutter/issues/103551
      drawer: const DevDrawer(),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(label: 'Overview', icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home)),
          NavigationDestination(label: 'Food', icon: Icon(Icons.fastfood_outlined), selectedIcon: Icon(Icons.fastfood)),
          NavigationDestination(label: 'Timetable', icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard)),
          NavigationDestination(label: 'Grades', icon: Icon(Icons.looks_one_outlined), selectedIcon: Icon(Icons.looks_one)),
        ],
      ),
    );
  }
}
