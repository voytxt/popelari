import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  const Error({required this.error, required this.stackTrace, super.key});

  final String error;
  final String stackTrace;

  @override
  Widget build(BuildContext context) {
    TextStyle red(TextStyle textStyle) => textStyle.copyWith(color: Theme.of(context).colorScheme.error);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Error', style: red(Theme.of(context).textTheme.headlineLarge!)),
        const SizedBox(height: 10),
        Text(error, style: red(Theme.of(context).textTheme.bodyLarge!)),
        const SizedBox(height: 8),
        Text(stackTrace, style: red(Theme.of(context).textTheme.bodySmall!)),
      ],
    );
  }
}
