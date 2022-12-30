import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<String> logIn(String canteenId, String username, String password) async {
  final url = Uri.parse('https://www.strava.cz/istravne/WSiStravneSSL/WSiStravneSSL.WSDL');
  final headers = {
    'content-type': 'text/xml; charset=UTF-8',
    'soapaction': 'http://tempuri.org/WSiStravne/action/istravne.WSPrihlaseniUzivatele',
  };

  final builder = xml.XmlBuilder();
  builder.element('soap:Envelope', nest: () {
    builder.attribute('xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
    builder.element('soap:Body', nest: () {
      builder.element('SOAPSDK4:WSPrihlaseniUzivatele', nest: () {
        builder.attribute('xmlns:SOAPSDK4', 'http://tempuri.org/WSiStravne/message/');
        builder.element('Zarizeni', nest: canteenId);
        builder.element('UZIVATEL', nest: username);
        builder.element('Heslo', nest: password);
        builder.element('AutUzivatelWS', nest: 'STRAVAAPLIKACE');
        builder.element('AutHesloSW', nest: 'yEslwqyotmns8Xgf');
        builder.element('Email');
      });
    });
  });
  final body = builder.buildDocument().toXmlString();

  final response = await http.post(url, body: body, headers: headers);
  if (response.statusCode != 200) throw Exception('Failed to log in to Strava, status code: ${response.statusCode}');

  final responseXml = xml.XmlDocument.parse(response.body)
      .getElement('SOAP-ENV:Envelope')!
      .getElement('SOAP-ENV:Body')!
      .getElement('SOAPSDK4:WSPrihlaseniUzivateleResponse')!;

  final sessionId = responseXml.getElement('Result')!.innerText.split(';')[0];

  if (sessionId.isEmpty) {
    final error = responseXml.getElement('Vysledek')!.innerText;
    throw Exception('Failed to log in to Strava, $error');
  }

  return sessionId;
}
