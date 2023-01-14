import 'package:http/http.dart' show Client;
import 'package:popelari/api/strava.dart';
import 'package:popelari/api/strava/soaper.dart';
import 'package:xml/xml.dart';

Future<Food> getFood(Client client, String canteenId, String sessionId) async {
  final builder = XmlBuilder()
    ..element('Konto', nest: canteenId)
    ..element('Jazyk');

  final response = await soap(client, 'RozpisJObjednavek', builder, canteenId, sessionId: sessionId);
  final responseXml = XmlDocument.parse(response);

  final coursesXml = responseXml.getElement('VFPData')?.findElements('rozpisobjednavek');

  if (coursesXml == null) {
    throw Exception('Failed to parse food, invalid xml: $responseXml');
  }

  Food food = Food([]);

  for (final courseXml in coursesXml) {
    final date = DateTime.parse(courseXml.getElement('datum')!.innerText);
    final type = courseXml.getElement('popisdruhu')!.innerText;
    final name = courseXml.getElement('nazevjidelnicku')!.innerText;
    final index = int.tryParse(courseXml.getElement('druh')!.innerText); // null if food can't be ordered
    final isOrdered = courseXml.getElement('pocet')!.innerText == '1';

    final course = Course(type, name, index);

    final dayIndex = food.days.indexWhere((element) => element.date == date);

    if (dayIndex == -1) {
      food.days.add(Day(date, [course], -1));
    } else {
      food.days[dayIndex].courses.add(course);
    }

    if (isOrdered) food.days[dayIndex].orderedFoodIndex = index!;
  }

  return food;
}
