import 'package:http/http.dart' show Client;
import 'package:popelari/api/strava/auth.dart';
import 'package:popelari/api/strava/get_food.dart';
import 'package:popelari/api/strava/order_food.dart';
import 'package:popelari/common/logger.dart';
import 'package:popelari/common/storage.dart';

Future<Food> fetch(String canteenId, {String? username, String? password, String? sessionId}) async {
  final client = Client();
  Food? food;

  try {
    await storage.write(key: 'canteenId', value: canteenId);

    if (sessionId == null) {
      sessionId = await logIn(client, canteenId, username!, password!);

      await storage.write(key: 'sessionId', value: sessionId);
    }

    food = await getFood(client, canteenId, sessionId);
  } catch (error) {
    logger.e(error);
    rethrow;
  } finally {
    client.close();
  }

  return food;
}

void order(String canteenId, String sessionId, List<Day> orderedFood) async {
  final client = Client();

  try {
    orderFood(client, canteenId, sessionId, orderedFood);
  } catch (error) {
    logger.e(error);
    rethrow;
  } finally {
    client.close();
  }
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
  final DateTime date;
  final int? index;
  final String allergens;
  final DateTime? orderDeadline;

  Course(this.type, this.name, this.date, this.index, this.allergens, this.orderDeadline);
}
