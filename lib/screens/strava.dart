import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:popelari/api/common/error.dart';
import 'package:popelari/api/strava.dart' as strava;

class Strava extends StatefulWidget {
  const Strava({super.key, required this.data});

  final Future<strava.Food>? data;

  @override
  State<Strava> createState() => _StravaState();
}

class _StravaState extends State<Strava> {
  List<int> _groupValues = [];

  final storage = const FlutterSecureStorage();
  Future<strava.Food>? futureFood;

  @override
  void initState() {
    super.initState();
    futureFood = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    if (futureFood == null) {
      log('User isn\'t logged in', name: 'STRAVA');

      return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30.0)),
          onPressed: () async {
            strava.Food? food = await Navigator.pushNamed(context, '/auth') as strava.Food;

            setState(() {
              futureFood = Future<strava.Food>.value(food);
            });
          },
          child: const Text('Log in'),
        ),
      );
    } else {
      return FutureBuilder(
        future: futureFood,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_groupValues.isEmpty) _groupValues = List.generate(snapshot.data!.days.length, (index) => 0);

            return RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () {
                // TODO: implement refresh (probably by having List<Widget> _tiles = [])
                return Future.delayed(const Duration(seconds: 1));
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: snapshot.data!.days.length,
                  itemBuilder: (context, index) => _buildTile(snapshot.data!, context, index),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Error(error: snapshot.error.toString(), stackTrace: snapshot.stackTrace.toString());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }

  Card _buildTile(strava.Food data, BuildContext context, int index) {
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
  }
}
