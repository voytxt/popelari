import 'package:http/http.dart' as http;
import 'package:popelari/api/strava.dart' as strava;
import 'package:xml/xml.dart' as xml;

Future<strava.Food> getFood(String canteenId, String sessionId) async {
  final url = Uri.parse('https://www.strava.cz/istravne/WSiStravneSSL/WSiStravneSSL.WSDL');
  final headers = {
    'content-type': 'text/xml; charset=UTF-8',
    'soapaction': 'http://tempuri.org/WSiStravne/action/istravne.WSRozpisJObjednavek',
  };

  final builder = xml.XmlBuilder();
  builder.element('soap:Envelope', nest: () {
    builder.attribute('xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
    builder.element('soap:Body', nest: () {
      builder.element('SOAPSDK4:WSRozpisJObjednavek', nest: () {
        builder.attribute('xmlns:SOAPSDK4', 'http://tempuri.org/WSiStravne/message/');
        builder.element('AutUzivatelWS', nest: 'STRAVAAPLIKACE');
        builder.element('AutHesloSW', nest: 'yEslwqyotmns8Xgf');
        builder.element('SID', nest: sessionId);
        builder.element('Konto', nest: canteenId);
        builder.element('Jazyk');
      });
    });
  });
  final body = builder.buildDocument().toXmlString();

  final response = await http.post(url, body: body, headers: headers);
  if (response.statusCode != 200) throw Exception('Failed to fetch food from Strava');

  final rawXml = xml.XmlDocument.parse(response.body)
      .getElement('SOAP-ENV:Envelope')!
      .getElement('SOAP-ENV:Body')!
      .getElement('SOAPSDK4:WSRozpisJObjednavekResponse')!
      .getElement('Result')!
      .innerText;

  final coursesXml = xml.XmlDocument.parse(rawXml).getElement('VFPData')!.findElements('rozpisobjednavek');

  strava.Food food = strava.Food([]);

  for (final courseXml in coursesXml) {
    final date = DateTime.parse(courseXml.getElement('datum')!.innerText);
    final type = courseXml.getElement('popisdruhu')!.innerText;
    final name = courseXml.getElement('nazevjidelnicku')!.innerText;
    final index = int.tryParse(courseXml.getElement('druh')!.innerText); // null if food can't be ordered
    final isOrdered = courseXml.getElement('pocet')!.innerText == '1';

    final course = strava.Course(type, name, index);

    final dayIndex = food.days.indexWhere((element) => element.date == date);

    if (dayIndex == -1) {
      food.days.add(strava.Day(date, [course], -1));
    } else {
      food.days[dayIndex].courses.add(course);
    }

    if (isOrdered) food.days[dayIndex].orderedFoodIndex = index!;
  }

  return food;
}
