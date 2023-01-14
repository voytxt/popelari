import 'package:http/http.dart' show Client;
import 'package:popelari/api/strava/soaper.dart';
import 'package:xml/xml.dart' show XmlBuilder;

Future<String> logIn(Client client, String canteenId, String username, String password) async {
  final builder = XmlBuilder()
    ..element('Zarizeni', nest: canteenId)
    ..element('Databaze', nest: canteenId)
    ..element('jazyk', nest: 'EN') // CS, SK, EN
    ..element('UZIVATEL', nest: username)
    ..element('Heslo', nest: password)
    ..element('Email');

  final response = await soap(client, 'PrihlaseniUzivatele', builder, canteenId);

  return response.split(';')[0];
}
