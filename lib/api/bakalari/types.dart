class GradesApi {
  GradesApi(this.subjects);

  GradesApi.fromJson(dynamic json) {
    final gradesJson = json as Map<String, dynamic>;

    final subjectsJson = gradesJson['Subjects'] as List<dynamic>;

    subjects = subjectsJson.map((subject) => Subject.fromJson(subject as Map<String, dynamic>)).toList();
  }

  late List<Subject> subjects;
}

class Subject {
  Subject(this.averageGrade, this.name);

  Subject.fromJson(Map<String, dynamic> json) {
    averageGrade = (json['AverageText'] as String).trim();

    name = (json['Subject'] as Map<String, dynamic>)['Name'] as String;
  }

  late String averageGrade;
  late String name;
}
