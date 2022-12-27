import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:popelari/api/strava.dart' as strava;
import 'package:popelari/screens/auth.dart';
import 'package:popelari/screens/grades.dart';
import 'package:popelari/screens/overview.dart';
import 'package:popelari/screens/strava.dart';
import 'package:popelari/screens/timetable.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popeláři',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/auth': (context) => const Auth(),
      },
      theme: ThemeData(
        useMaterial3: true,
        // brightness: Brightness.dark,
        colorSchemeSeed: Colors.amber,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<strava.Food>? stravaData;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getStravaData());
  }

  void getStravaData() async {
    const storage = FlutterSecureStorage();
    final canteenId = await storage.read(key: 'canteenId');
    final username = await storage.read(key: 'username');
    final password = await storage.read(key: 'password');

    if (canteenId != null && username != null && password != null) {
      stravaData = strava.fetch(canteenId, username, password);
    } else {
      stravaData = null;
    }
  }

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
            Strava(data: stravaData),
            const Timetable(),
            const Grades(),
          ][currentPageIndex],
        ),
      ),

      // M2 for now, M3: https://github.com/flutter/flutter/issues/103551
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Popeláři',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),

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
