import 'dart:developer';

import 'package:popelari/api/strava/auth.dart' as auth;
import 'package:popelari/api/strava/get_food.dart' as get_food;

Future<Food> fetch(String kitchenId, String username, String password) async {
  final stopwatch = Stopwatch()..start();

  log('Logging in', name: 'STRAVA');
  final sessionId = await auth.logIn(kitchenId, username, password);

  log('Getting food', name: 'STRAVA');
  final foodMap = await get_food.getFood(kitchenId, sessionId);

  log('Finished in ${stopwatch.elapsed.inMilliseconds} ms', name: 'STRAVA');

  return foodMap;
}

class Food {
  final List<Day> days;

  Food(this.days);
}

class Day {
  final DateTime date;
  final List<Course> courses;

  Day(this.date, this.courses);
}

class Course {
  final String type;
  final String name;

  Course(this.type, this.name);
}
