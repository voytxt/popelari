import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:popelari/api/bakalari/types.dart';

Future<GradesApi> getGrades() async {
  final client = Client();

  // TODO: implement auth
  final response = await client.get(
    Uri.https('<school url>', 'api/3/marks'),
    headers: {'Authorization': 'Bearer <token>'},
  );

  client.close();

  if (response.statusCode == 401) {
    throw Exception('Unauthorized');
  }

  final json = jsonDecode(response.body);

  final grades = GradesApi.fromJson(json);

  return grades;
}
