import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popelari/api/strava.dart';

class Food extends StatelessWidget {
  const Food({super.key});

  @override
  Widget build(BuildContext context) {
    // https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
    final course = ModalRoute.of(context)!.settings.arguments as Course;

    return Scaffold(
      appBar: AppBar(title: const Text('Popeláři ~ Strava ~ Food')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: Column(
            children: [
              Text(
                '${DateFormat('EEEE d. M.').format(course.date)} - ${course.type}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                course.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (course.orderDeadline != null) ...[
                const Divider(height: 40.0, indent: 50.0, endIndent: 50.0),
                Text('Order deadline: ${DateFormat('EEEE d. M. kk:mm').format(course.orderDeadline!)}')
              ],
              const Divider(height: 40.0, indent: 50.0, endIndent: 50.0),
              Text(course.allergens == '' ? 'No allergens' : course.allergens),
            ],
          ),
        ),
      ),
    );
  }
}
