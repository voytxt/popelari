import 'package:flutter/material.dart';
import 'package:popelari/screens/dev_drawer.dart';
import 'package:popelari/screens/grades.dart';
import 'package:popelari/screens/overview.dart';
import 'package:popelari/screens/strava.dart';
import 'package:popelari/screens/strava/auth.dart';
import 'package:popelari/screens/strava/food.dart';
import 'package:popelari/screens/timetable.dart';

void main() {
  runApp(MaterialApp(
    title: 'Popeláři',
    initialRoute: '/',
    routes: {
      '/': (context) => const Main(),
      '/strava/auth': (context) => const Auth(),
      '/strava/food': (context) => const Food(),
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
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Popeláři ~ ${['Overview', 'Strava', 'Timetable', 'Grades'][_currentPageIndex]}',
        ),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: [
            const Overview(),
            const Strava(),
            const Timetable(),
            const Grades(),
          ][_currentPageIndex],
        ),
      ),

      // TODO: move dev drawer to settings, have an actual navigation drawer instead
      drawer: const DevDrawer(),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
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
