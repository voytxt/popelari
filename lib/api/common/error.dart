import 'dart:developer';

import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  const Error({super.key, required this.error, required this.stackTrace});

  final String error;
  final String stackTrace;

  @override
  Widget build(BuildContext context) {
    TextStyle red(TextStyle textStyle) => textStyle.copyWith(color: Theme.of(context).errorColor);

    log(stackTrace);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Error', style: red(Theme.of(context).textTheme.headlineLarge!)),
        const SizedBox(height: 10.0),
        Text(error, style: red(Theme.of(context).textTheme.bodyLarge!)),
        const SizedBox(height: 8.0),
        Text(stackTrace, style: red(Theme.of(context).textTheme.bodySmall!)),
      ],
    );
  }
}
