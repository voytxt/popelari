import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popelari/api/strava.dart' as strava;

class Strava extends StatefulWidget {
  const Strava({super.key, required this.data});

  final Future<strava.Food> data;

  @override
  State<Strava> createState() => _StravaState();
}

class _StravaState extends State<Strava> {
  List<int> _groupValues = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.data,
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
          return Text(
            snapshot.error.toString(),
            style: TextStyle(color: Theme.of(context).errorColor),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
