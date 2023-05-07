import 'package:flutter/material.dart';
import 'package:popelari/api/bakalari.dart';
import 'package:popelari/api/bakalari/types.dart';
import 'package:popelari/screens/common/error.dart';

class Grades extends StatefulWidget {
  const Grades({super.key});

  @override
  State<Grades> createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  late Future<GradesApi> _futureGrades;

  @override
  void initState() {
    super.initState();
    _futureGrades = getGrades();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureGrades,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Error(error: snapshot.error.toString(), stackTrace: snapshot.stackTrace.toString());
        }

        if (snapshot.hasData) {
          return _buildData(snapshot.data!);
        }

        return Center(child: _buildLogInButton(context));
      },
    );
  }

  Widget _buildData(GradesApi data) {
    return Scrollbar(
      child: ListView(
        children: [
          for (final subject in data.subjects)
            Card(
              child: ListTile(
                title: Text(subject.name),
                trailing: Text(subject.averageGrade, style: Theme.of(context).textTheme.titleLarge),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildLogInButton(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30)),
      onPressed: () {},
      child: const Text('Log in'),
    );
  }
}
