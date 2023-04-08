import 'package:flutter/material.dart';
import 'package:popelari/screens/common/space.dart';

class Error extends StatelessWidget {
  const Error({required this.error, required this.stackTrace, super.key});

  final String error;
  final String stackTrace;

  @override
  Widget build(BuildContext context) {
    TextStyle red(TextStyle textStyle) => textStyle.copyWith(color: Theme.of(context).colorScheme.error);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: spaceBetween(10, [
            Text('Error', style: red(Theme.of(context).textTheme.headlineLarge!)),
            Text(error, style: red(Theme.of(context).textTheme.bodyLarge!)),
            Text(stackTrace, style: red(Theme.of(context).textTheme.bodySmall!)),
          ]),
        ),
      ),
    );
  }
}
