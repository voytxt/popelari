import 'package:http/http.dart' show Client;
import 'package:popelari/common/logger.dart';
import 'package:xml/xml.dart' show XmlBuilder, XmlDocument;

Future<String> soap(Client client, String action, XmlBuilder body, String canteenId, {String? sessionId}) async {
  logger.i('Soaping $action 🧼');

  final builder = XmlBuilder();
  builder.element('soap:Envelope', nest: () {
    builder.attribute('xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
    builder.element('soap:Body', nest: () {
      builder.element('SOAPSDK4:WS$action', nest: () {
        builder
          ..attribute('xmlns:SOAPSDK4', 'http://tempuri.org/WSiStravne/message/')
          ..element('AutUzivatelWS', nest: 'STRAVAAPLIKACE')
          ..element('AutHesloSW', nest: 'yEslwqyotmns8Xgf')
          ..element('SID', nest: sessionId)
          ..xml(body.buildDocument().toXmlString()); // couldn't find a more efficient solution D:
      });
    });
  });

  final response = await client.post(
    Uri.https('www.strava.cz', 'istravne/WSiStravneSSL/WSiStravneSSL.WSDL'),
    headers: {
      'content-type': 'text/xml; charset=UTF-8',
      'soapaction': 'http://tempuri.org/WSiStravne/action/istravne.WS$action',
    },
    body: builder.buildDocument().toXmlString(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to soap $action, status code: ${response.statusCode}');
  }

  final data = XmlDocument.parse(response.body)
      .getElement('SOAP-ENV:Envelope')
      ?.getElement('SOAP-ENV:Body')
      ?.getElement('SOAPSDK4:WS${action}Response');

  final status = data?.getElement('Vysledek')?.innerText;
  final result = data?.getElement('Result')?.innerText;

  if (status == null || result == null) {
    throw Exception('Failed to soap $action, invalid xml: ${response.body}');
  }

  if (status != '0;') {
    throw Exception('Failed to soap $action, status: $status');
  }

  return result;
}
