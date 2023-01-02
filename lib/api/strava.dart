import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:popelari/api/strava/auth.dart' as auth;
import 'package:popelari/api/strava/get_food.dart' as get_food;

Future<Food> fetch(String canteenId, {String? username, String? password, String? sessionId}) async {
  log('Started', name: 'STRAVA API');

  final stopwatch = Stopwatch()..start();

  const storage = FlutterSecureStorage();
  await storage.write(key: 'canteenId', value: canteenId);

  if (sessionId == null) {
    log('Logging in', name: 'STRAVA API');
    sessionId = await auth.logIn(canteenId, username!, password!);

    await storage.write(key: 'sessionId', value: sessionId);
  }

  log('Getting food', name: 'STRAVA API');
  final food = await get_food.getFood(canteenId, sessionId);

  log('Finished in ${stopwatch.elapsed.inMilliseconds} ms', name: 'STRAVA API');

  return food;
}

class Food {
  final List<Day> days;

  Food(this.days);
}

class Day {
  final DateTime date;
  final List<Course> courses;
  late int orderedFoodIndex;

  Day(this.date, this.courses, this.orderedFoodIndex);
}

class Course {
  final String type;
  final String name;
  final int? index;

  Course(this.type, this.name, this.index);
}
