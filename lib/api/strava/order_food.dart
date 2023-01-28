import 'package:http/http.dart' show Client;
import 'package:intl/intl.dart' show DateFormat;
import 'package:popelari/api/strava.dart';
import 'package:popelari/api/strava/soaper.dart';
import 'package:popelari/common/logger.dart';
import 'package:xml/xml.dart' show XmlBuilder;

void orderFood(Client client, String canteenId, String sessionId, List<Day> orderedFood) async {
  if (orderedFood.isEmpty) return;

  logger.d(orderedFood.map((e) => '${e.date.day}.${e.date.month}. - ${e.orderedFoodIndex}').join(' | '));

  final builder = XmlBuilder();
  builder.element('VFPData', nest: () {
    // bruh
    builder.text(
        '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" id="VFPData"><xsd:element name="VFPData" msdata:IsDataSet="true"><xsd:complexType><xsd:choice maxOccurs="unbounded"><xsd:element name="RozpisObjednavek2" minOccurs="0" maxOccurs="unbounded"><xsd:complexType><xsd:sequence><xsd:element name="datum" type="xsd:date" /><xsd:element name="druh"><xsd:simpleType><xsd:restriction base="xsd:string"><xsd:maxLength value="1" /></xsd:restriction></xsd:simpleType></xsd:element><xsd:element name="pocet"><xsd:simpleType><xsd:restriction base="xsd:decimal"><xsd:totalDigits value="5" /><xsd:fractionDigits value="0" /></xsd:restriction></xsd:simpleType></xsd:element></xsd:sequence></xsd:complexType></xsd:element></xsd:choice><xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax" /></xsd:complexType></xsd:element></xsd:schema>');

    for (final day in orderedFood) {
      for (final course in day.courses) {
        if (course.index == null) continue;

        builder.element('RozpisObjednavek2', nest: () {
          builder.element('datum', nest: DateFormat('y-MM-dd').format(day.date));
          builder.element('druh', nest: course.index);
          builder.element('pocet', nest: day.orderedFoodIndex == course.index ? '1' : '0');
        });
      }
    }
  });

  final orders = builder.buildDocument().toXmlString().replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  builder
    ..element('Konto', nest: canteenId)
    ..element('Vysledek')
    ..element('XMLObjednavky', nest: orders);

  await soap(client, 'UlozeniObjednavek', builder, canteenId, sessionId: sessionId);
}
