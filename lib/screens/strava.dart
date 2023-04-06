import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:popelari/api/strava.dart' as strava;
import 'package:popelari/common/logger.dart';
import 'package:popelari/common/storage.dart';
import 'package:popelari/screens/common/error.dart';

class Strava extends StatefulWidget {
  const Strava({super.key});

  @override
  State<Strava> createState() => _StravaState();
}

class _StravaState extends State<Strava> {
  List<strava.Day> _initialDays = [];
  List<int> _groupValues = [];
  bool _showFab = false;

  late Future<strava.Food?> _futureFood;

  @override
  void initState() {
    super.initState();
    _futureFood = _getFood();
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

  Future<strava.Food?> _getFood() async {
    final canteenId = await storage.read(key: 'canteenId');
    final sessionId = await storage.read(key: 'sessionId');

    if (canteenId == null || sessionId == null) return null;

    try {
      return await strava.fetch(canteenId, sessionId: sessionId);
    } catch (_) {
      logger.e('Invalid session id (or canteen id), generating a new one');

      final username = await storage.read(key: 'username');
      final password = await storage.read(key: 'password');

      if (username == null || password == null) return null;

      try {
        return await strava.fetch(canteenId, username: username, password: password);
      } catch (_) {
        logger.e('Invalid credentials');
        return null;
      }
    }
  }

  Future<void> _orderFood() async {
    final canteenId = await storage.read(key: 'canteenId');
    final sessionId = await storage.read(key: 'sessionId');

    final orderedFood = <strava.Day>[];

    _initialDays.forEachIndexed((index, day) {
      if (_groupValues[index] != day.orderedFoodIndex) {
        orderedFood.add(strava.Day(day.date, day.courses, _groupValues[index]));
      }
    });

    try {
      await strava.order(canteenId!, sessionId!, orderedFood);
    } catch (error) {
      logger.e(error);
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Food ordered'),
        content: const Text('Your food was ordered successfully'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final food = await _getFood();

              setState(() {
                _futureFood = Future.value(food);
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    if (const DeepCollectionEquality().equals(_initialDays, data.days) == false) {
      _initialDays = data.days;
      _groupValues = data.days.map((day) => day.orderedFoodIndex).toList();
      _showFab = false;
    }

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            final food = await _getFood();

            setState(() {
              _futureFood = Future.value(food);
            });
          },
          child: Scrollbar(
            child: ListView.builder(
              itemCount: data.days.length,
              itemBuilder: (context, index) {
                final day = data.days[index];

                final tiles = day.courses.map((course) {
                  void handleTap() => Navigator.pushNamed(context, '/strava/food', arguments: course);

                  return GestureDetector(
                    onLongPress: handleTap,
                    child: (course.index == null || course.orderDeadline!.isBefore(DateTime.now()))
                        ? ListTile(
                            title: Text(course.name),
                            subtitle: Text(course.type),
                            leading: const SizedBox.shrink(),
                            onTap: handleTap,
                          )
                        : RadioListTile(
                            title: Text(course.name),
                            subtitle: Text(course.type),
                            value: course.index!,
                            groupValue: _groupValues[index],
                            toggleable: true,
                            onChanged: (value) {
                              setState(() {
                                _groupValues[index] = value ?? -1;
                                _showFab = true;
                              });
                            },
                          ),
                  );
                }).toList();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      Text(
                        DateFormat('EEEE d. M.').format(day.date),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Column(children: tiles),
                    ]),
                  ),
                );
              },
            ),
          ),
        ),
        if (_showFab)
          FloatingActionButton.extended(
            label: const Text('Send'),
            icon: const Icon(Icons.check),
            onPressed: _orderFood,
          ),
      ],
    );
  }

  Widget _buildLogInButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30)),
      onPressed: () async {
        final food = await Navigator.pushNamed(context, '/strava/auth') as strava.Food?;

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
