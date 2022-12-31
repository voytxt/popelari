import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:popelari/api/common/error.dart';
import 'package:popelari/api/strava.dart' as strava;

class Strava extends StatefulWidget {
  const Strava({super.key});

  @override
  State<Strava> createState() => _StravaState();
}

class _StravaState extends State<Strava> {
  List<int> _groupValues = [];

  late Future<strava.Food?> _futureFood;

  @override
  void initState() {
    super.initState();
    _futureFood = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureFood,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error!, snapshot.stackTrace!);
        }

        if (snapshot.hasData) {
          return _buildData(snapshot.data!);
        }

        return Center(child: _buildLogInButton(context));
      },
    );
  }

  Future<strava.Food?> _getData() async {
    log('Started', name: 'STRAVA');

    const storage = FlutterSecureStorage();
    final canteenId = await storage.read(key: 'canteenId');
    final sessionId = await storage.read(key: 'sessionId');

    if (canteenId == null || sessionId == null) {
      log('Finished, session id (or canteen id) is null', name: 'STRAVA');
      return null;
    }

    try {
      return await strava.fetch(canteenId, sessionId: sessionId);
    } catch (_) {
      log('Invalid session id (or canteen id), generating a new one', name: 'STRAVA');

      final username = await storage.read(key: 'username');
      final password = await storage.read(key: 'password');

      if (username == null || password == null) return null;

      try {
        return await strava.fetch(canteenId, username: username, password: password);
      } catch (_) {
        log('Finished, invalid credentials', name: 'STRAVA');
        return null;
      }
    }
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(Object error, StackTrace stackTrace) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Error(error: error.toString(), stackTrace: stackTrace.toString()),
        _buildLogInButton(context),
      ],
    );
  }

  Widget _buildData(strava.Food data) {
    if (_groupValues.isEmpty) {
      _groupValues = List.generate(data.days.length, (index) => 0);
    }

    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () {
        // TODO: implement refresh (probably by having List<Widget> _tiles = [])
        return Future.delayed(const Duration(seconds: 1));
      },
      child: Scrollbar(
        child: ListView.builder(
          itemCount: data.days.length,
          itemBuilder: (context, index) {
            final day = data.days[index];

            final tiles = day.courses.mapIndexed((courseIndex, course) {
              return RadioListTile(
                key: GlobalKey(),
                title: Text(course.name),
                subtitle: Text(course.type),
                value: courseIndex,
                groupValue: _groupValues[index],
                onChanged: (value) {
                  setState(() {
                    _groupValues[index] = courseIndex;
                  });
                },
              );
            }).toList();

            return Card(
              child: Column(children: [
                Text(
                  DateFormat('EEEE d. M.').format(day.date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Column(children: tiles),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogInButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30.0)),
      onPressed: () async {
        strava.Food? food = await Navigator.pushNamed(context, '/auth') as strava.Food?;

        if (food != null) {
          setState(() {
            _futureFood = Future<strava.Food>.value(food);
          });
        }
      },
      child: const Text('Log in'),
    );
  }
}
